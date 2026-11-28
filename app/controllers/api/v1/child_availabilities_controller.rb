module Api
  module V1
    class ChildAvailabilitiesController < ApplicationController
    # 権限チェック（担任のみ）
    before_action -> { authorize_role!("teacher") }
    # ログインしている担任が持つクラスの情報を取得する。

    def index
        # ログイン中の担任からクラスのidを取得する
        class_room_ids = current_user.teacher.class_rooms.ids
        # 担任のクラスに所属する児童を、中間テーブル（child_class_rooms）を通して取得する
        children = Child.where(id: ChildClassRoom
                        .where(class_room_id: class_room_ids) # 担任の学級に所属する児童のIDを、child_class_roomsから探す(行)
                        .select(:child_id)) # child_idを集める（列）
                        .includes(
        # 保護者の来校できる日・兄弟が割り当てられているslot・特別支援学級で割り当てられているslotを先読みしておく
        class_rooms: :teacher,
        assignments: :meeting_slot, # 自分の割り当て（特支の判定用）
        family: [
            { family_availabilities: :meeting_slot },                          # 家庭の希望日
            { children: [ :class_rooms, { assignments: :meeting_slot } ] }        # 兄弟の割り当て
        ]
        )
        result = children.to_h do |child|
            # 兄弟（自分以外の、同じ家庭の子）
            siblings = child.family.children.reject { |c| c.id == child.id }
            # 兄弟それぞれの割り当てから、面談枠のIDを集める
            siblings_start_at = siblings.flat_map { |s| s.assignments.map { |a| a.meeting_slot.start_at } }

            # 兄弟の情報
            siblings_info = siblings.map do |s|
            sibling_class_room = s.class_rooms.find { |r| r.room_type != "support" }&.classname
            { name: s.name, class_room: sibling_class_room, child_id: s.id }
            end

            # 特別支援の面談
            support_room = child.class_rooms.find { |r|r.room_type == "support" } # 特別支援の児童だけ取り出す
            own_support_start_at =
            if support_room # 特別支援の面談表を取得(通常級でエラーになるため分岐)
                child.assignments
                    .select { |a|a.meeting_slot.teacher_id == support_room.teacher_id } # 児童が割り当てられている面談表から、特支の面談表を選ぶ
                    .map { |a| a.meeting_slot.start_at }  # 割り当てられているidを取得
            else
                []
            end
            # 特支の情報
            support_info =
             if support_room
                support_class_room = support_room.classname
                support_teacher = support_room.teacher.name
                { class_room: support_class_room, teacher: support_teacher }
             else
                nil
             end
            # 保護者の希望日取得
            available_start_at = child.family.family_availabilities.map { |a| a.meeting_slot.start_at }
            [ child.id, { siblings_start_at: siblings_start_at,
            own_support_start_at: own_support_start_at,
            available_start_at: available_start_at,
            support_info: support_info,
            siblings_info: siblings_info,
            submitted: child.family.submitted
            } ] # ハッシュとキーと値
        end
        render json: result
    end
    end
  end
end
