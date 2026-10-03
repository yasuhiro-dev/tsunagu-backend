class Api::V1::TeachersController < ApplicationController
    before_action -> { authorize_role!("teacher") }, only: [ :capacity ]

    # クラスに所属する児童数を返す（必要な面談の枠を確認するため）
    def capacity
        # ログイン中の先生を取得
        teacher = current_user.teacher
        # 先生のクラスから児童を取得
        children = teacher.class_rooms.flat_map { |cr| cr.children }.length
        # フロントへ返す
        render json: { children_count: children }
    end
end
