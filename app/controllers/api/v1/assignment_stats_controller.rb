class Api::V1::AssignmentStatsController < ApplicationController
  before_action -> { authorize_role!("admin") }

  def index
    # クラス別の人数（ソートの関係でgrade、sectionも持たせる）
    total = Child.joins(:class_rooms)
                 .group("class_rooms.grade", "class_rooms.section", "class_rooms.classname")
                 .count

    # クラス別・割り当てられた人数
    assigned = Child.joins(:class_rooms, :assignments)
                    .group("class_rooms.grade", "class_rooms.section", "class_rooms.classname")
                    .distinct
                    .count("children.id")

    # クラス別の割合を計算
    class_rates = total.map { |(grade, section, classname), count|
      {
        grade: grade,
        section: section,
        class_name: classname,
        rate: (assigned[[ grade, section, classname ]] || 0) / count.to_f * 100
      }
    }

    # 割り当てられた数
    assign_count = Child.joins(:class_rooms, :assignments).distinct.count("children.id")

    # 対象児童数
    total_count = Child.joins(:class_rooms).distinct.count("children.id")

    # 全体の割合を計算
    all_rates = assign_count / total_count.to_f * 100

    # 未割り当ての数（全体の人数 - 割り当て人数）
    unassign_count = total_count - assign_count

    # 割り当て済みの児童のIDを取得
    assigned_ids = Child.joins(:assignments).distinct.pluck(:id)

    # 全児童のうち、そのIDに含まれないものが「未割り当て」
    unassigned_children = Child.where.not(id: assigned_ids).includes(:class_rooms)

    render json: {
      siblings_stats: siblings_stats,
      class_rates: class_rates,
      all_rates: all_rates,
      assign_count: assign_count,
      unassign_count: unassign_count,
      total_count: total_count,
      unassigned_children: unassigned_children.as_json(include: :class_rooms)
    }, status: :ok
  end

  private
  def siblings_stats
    siblings_family = Family.includes(children: { assignments: :meeting_slot }).select { |f|f.children.length >= 2 } # 兄弟を持つ家族にしぼる(判定がtrueのものだけ残る)
    # 割り当てられている兄弟を持つ家庭のうち連続しての数を数える
    success = siblings_family.count do |family|
      next false if family.children.any? { |c|c.assignments.empty? } # 割り当てられていない子がいたら失敗
      date = family.children.flat_map { |c| c.assignments }.map { |a| a.meeting_slot.start_at.to_date }
      next false if date.uniq.size > 1 # 同じ日付がない場合、失敗
      times = family.children
              .flat_map { |c| c.assignments }
              .map { |a| a.meeting_slot.start_at }
              .sort # 割り当てられている時刻を並び替える
      next false unless times.each_cons(2).all? { |t1, t2| t2 == t1 + 15.minutes } # 連続していない場合、失敗
      true
    end
    { total: siblings_family.length, success: success }
  end
end
