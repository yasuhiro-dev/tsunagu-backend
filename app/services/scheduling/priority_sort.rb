module Scheduling
  class PrioritySort
    def call(groups)
        groups.sort_by { |group| -score(group) }
    end

    private

    def score(group)
        score=0
        siblings = group.count { |g| g[:type] == :normal } > 1
        has_support = group.any? { |g| g[:type] == :support }
        has_unavailable = group.first[:child].family.family_unavailabilities.any?

        score += 4 if siblings
        score += 2 if has_support
        score += 1 if has_unavailable
        score
    end
  end
end
