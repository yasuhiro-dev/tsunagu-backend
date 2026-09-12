module Scheduling
  class PrioritySort
    def call(groups)
      groups.sort_by { |group| -score(group) }
    end

    private

    def score(group)
      score = 0
      siblings = group.count { |g| g[:type] == :normal } > 1
      has_support = group.any? { |g| g[:type] == :support }
      # 参加できる日時を提出した家庭は、候補がその時刻に限られる
      has_time_constraint = group.first[:child].family.submitted

      score += 4 if siblings
      score += 2 if has_support
      score += 1 if has_time_constraint
      score
    end
  end
end
