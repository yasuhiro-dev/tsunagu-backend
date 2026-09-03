module Scheduling
  class SiblingsFilter
    SLOT_INTERVAL_MINUTES = 15

    def call(slots, group)
      return slots unless siblings_group?(group)

      # 担任の先生の面談slotを取り出す
      child_slot_candidates = group.map do |entry|
        # room_typeを特別支援と通常級で分ける
        room_type = entry[:type] == :support ? "support" : "normal"
        # 担任（通常級・支援級）の先生を割り出す
        teacher_id = entry[:child].class_rooms.find { |cr| cr.room_type == room_type }&.teacher_id
        # 面談表と担任の先生を一致させる
        slots.select { |s| s.teacher_id == teacher_id }
      end
      # groupの人数分の担任からslotを取り出し、その担任のslot全組み合わせを作る
      child_slot_candidates.first.product(*child_slot_candidates[1..]).each do |combo|
        # 重複がある場合、スキップする
        next if combo.uniq.size != combo.size
        # 重複がない場合、並び替えた全パターン作る
        combo.permutation.each do |ordered|
          # slotにreservedが含まれている場合、割り当てない
          next if ordered.any? { |s| s.status == "reserved" }
          # 連続でない場合、割り当てない
          next unless consecutive?(ordered)
          # 通常学級と特別支援学級の両方に在籍する場合、その2枠は隣り合っていなければならない
          next unless same_child_slots_adjacent?(group, combo, ordered)

          return ordered
        end
      end
      []
    end

    private

    def siblings_group?(group)
      group.count { |g| g[:type] == :normal || g[:type] == :support } > 1
    end

    def consecutive?(slots)
      slots.each_cons(2).all? do |s1, s2|
        s2.start_at == s1.start_at + SLOT_INTERVAL_MINUTES * 60 &&
          s1.start_at.to_date == s2.start_at.to_date
      end
    end


    def same_child_slots_adjacent?(group, combo, ordered)
      # group要素に番号をつけ、child_idが同じもの同士でグループ化する
      group.each_with_index.group_by { |e, _i| e[:child].id }.all? do |_id, entries|
        # グループ化したものが１人の場合、スキップする
        next true if entries.size < 2
        # グループ化したもののindex番号を取り出し、小さい順に並べる
        pos = entries.map { |_e, i| ordered.index(combo[i]) }.sort
        # ２つずつペアにして、全てのペアの位置の差が１(＝隣接している)かを確認する
        pos.each_cons(2).all? { |a, b| b - a == 1 }
      end
    end
  end
end
