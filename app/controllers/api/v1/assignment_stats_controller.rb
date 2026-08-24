class Api::V1::AssignmentStatsController < ApplicationController
    before_action -> { authorize_role!("admin") }
    def index
        # クラス別の人数（ソートの関係でgrade、sectionも持たせる）
        total=Child.joins(:class_rooms).group("class_rooms.grade", "class_rooms.section", "class_rooms.classname").count
        # クラス別・割り当てられた人数
        assigned=Child.joins(:class_rooms, :assignments).group("class_rooms.grade", "class_rooms.section", "class_rooms.classname").distinct.count("children.id")
        # クラス別の割合を計算
        class_rates = total.map { |(grade, section, classname), count|
        { grade: grade, section: section, class_name: classname, rate: (assigned[[ grade, section, classname ]] || 0) / count.to_f * 100 }}
        # 全体の割合を計算
        all_rates = Child.joins(:assignments).distinct.count("children.id") / Child.count.to_f * 100

        render json: { class_rates: class_rates, all_rates: all_rates }, status: :ok
    end
end
