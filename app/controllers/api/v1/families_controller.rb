class Api::V1::FamiliesController < ApplicationController
  # どのroleでも見られるが、parentだけ制限をかける
  before_action -> { authorize_role!("admin", "teacher", "parent") }
  def show
    # どの家族の情報を取得したいかはフロントから送られてくるidで決まる
    family = Family.find(params[:id])
    # ログイン中のparentでも、自分以外の情報は見られない
    if current_user.role == "parent" && current_user.family != family
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end
    # adminとteacherは取得可能
    render json: { submitted: family.submitted }, status: :ok
  end
end
