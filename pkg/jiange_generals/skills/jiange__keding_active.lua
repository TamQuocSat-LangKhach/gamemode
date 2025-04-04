local jiange__keding_active = fk.CreateSkill {
  name = "jiange__keding_active"
}

Fk:loadTranslationTable{
  ['jiange__keding_active'] = '克定',
}

jiange__keding_active:addEffect('active', {
  min_card_num = 1,
  min_target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return table.contains(player:getCardIds("h"), to_select) and not player:prohibitDiscard(to_select)
  end,
  target_filter = function (skill, player, to_select, selected, selected_cards)
    return #selected < #selected_cards
  end,
  feasible = function (skill, player, selected, selected_cards)
    return #selected > 0 and #selected == #selected_cards
  end,
})

return jiange__keding_active
