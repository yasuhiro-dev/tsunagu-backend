class Api::V1::TeacherExportsController < ActionController::Base
    include Authentication
    before_action -> { authorize_role!("teacher") }

    def index
       @assignment = Assignment.includes(:meeting_slot, :child).joins(:meeting_slot).where(meeting_slots: { teacher_id: current_user.teacher.id })
       @teacher_name = current_user.teacher.name
       @class_name = current_user.teacher.class_rooms.map { |c|c.classname }.join("、")
       # 割り当てデータの集まりを、時間ごとにグループ分け
       @group_time = @assignment.group_by { |a|a.meeting_slot.start_at.strftime("%H時%M分") }
       # 時間ごとの中身を、さらに日付でグループ分け
       @group_day = @group_time.transform_values { |t|t.group_by { |a|a.meeting_slot.start_at.strftime("%m月%d日") } }
       # 日付・時間毎に児童を入れる
       @group_child = @group_day.transform_values { |day|day.transform_values { |assignments|assignments.map { |assignment|assignment.child.name } } }
       # 重複なく日付を並べる
       @date_list = MeetingSlot.where(teacher_id: current_user.teacher.id)
                         .pluck(:start_at)
                         .map { |t| t.strftime("%m月%d日") }
                         .uniq
                         .sort

       # viewファイルからhtmlを文字列として取得する（PDF変換の材料として使うため）
       html = render_to_string("api/v1/teacher_exports/index", formats: [ :html ], layout: false)
       pdf = Grover.new(html, wait_until: "networkidle0").to_pdf
       send_data pdf, filename: "schedule.pdf", type: "application/pdf"
       nil
    end
end
