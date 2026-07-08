class Api::V1::AssignmentStatsController < ApplicationController
    def index
        # クラス別の人数
        total=Child.joins(:class_rooms).group("class_rooms.grade", "class_rooms.section").count
        # クラス別・割り当てられた人数
        assigned=Child.joins(:class_rooms, :assignments).group("class_rooms.grade", "class_rooms.section").distinct.count("children.id")
        # クラス別の割合を計算
        class_rates = total.map { |(grade, section), count|
        { grade: grade, section: section, class_name: "#{grade}-#{section}", rate: (assigned[[ grade, section ]] || 0) / count.to_f * 100 }}
        # 全体の割合を計算
        all_rates = Child.joins(:assignments).distinct.count("children.id") / Child.count.to_f * 100

        render json: { class_rates: class_rates, all_rates: all_rates }, status: :ok
    end
end
