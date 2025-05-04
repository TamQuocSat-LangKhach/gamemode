local jiange__hupo = fk.CreateSkill {
  name = "jiange__hupo",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jiange__hupo"] = "虎魄",
  [":jiange__hupo"] = "锁定技，你的锦囊牌均视为【杀】。",
}

jiange__hupo:addEffect("filter", {
  anim_type = "offensive",
  card_filter = function(self, player, card)
    return player:hasSkill(skill.name) and card.type == Card.TypeTrick and table.contains(player:getCardIds("h"), card.id)
  end,
  view_as = function(self, player, to_select)
    return Fk:cloneCard("slash", to_select.suit, to_select.number)
  end,
})

return jiange__hupo
