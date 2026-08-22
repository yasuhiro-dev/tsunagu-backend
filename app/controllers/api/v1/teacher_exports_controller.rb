class Api::V1::TeacherExportsController < ActionController::Base
    include Authentication
    before_action -> { authorize_role!("teacher") }

    def index
       @assignment = Assignment.includes(:meeting_slot, :child).joins(:meeting_slot).where(meeting_slots: { teacher_id: current_user.teacher.id })
       @group_time = @assignment.group_by { |a|a.meeting_slot.start_at.strftime("%H時%M分") }
       @group_day = @group_time.transform_values { |t|t.group_by { |a|a.meeting_slot.start_at.strftime("%m月%d日") } }
       @group_child = @group_day.transform_values { |day|day.transform_values { |assignments|assignments.map { |assignment|assignment.child.name } } }
       @date_list = @group_child.values.first.keys
       # viewファイルからhtmlを文字列として取得する（PDF変換の材料として使うため）
       html = render_to_string("api/v1/teacher_exports/index", formats: [ :html ], layout: false)
       pdf = Grover.new(html, wait_until: "networkidle0").to_pdf
       send_data pdf, filename: "schedule.pdf", type: "application/pdf"
       nil
    end
end
