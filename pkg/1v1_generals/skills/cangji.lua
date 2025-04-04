local cangji = fk.CreateSkill {
  name = "v11__cangji"
}

Fk:loadTranslationTable{
  ['v11__cangji'] = '藏机',
  [':v11__cangji'] = '当你死亡时，你可以将你装备区里的所有牌移出游戏，然后你的下一名武将登场时将这些牌置入你的装备区。',
}

cangji:addEffect({fk.Death, "fk.Debut"}, {
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.Death then
        return player:hasSkill(cangji.name, false, true) and #player:getCardIds("e") > 0
      else
        return player.tag["v11__cangji"] ~= nil
      end
    end
  end,
  on_cost = function (skill, event, target, player, data)
    return event ~= fk.Death or player.room:askToSkillInvoke(player, { skill_name = cangji.name })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Death then
      local cards = player:getCardIds("e")
      player.tag["v11__cangji"] = cards
      room:moveCardTo(cards, Card.Void, nil, fk.ReasonJustMove, cangji.name, nil, true, player.id)
    else
      local cards = table.simpleClone(player.tag["v11__cangji"])
      player.tag["v11__cangji"] = nil
      room:moveCardIntoEquip(player, cards, cangji.name, false, player)
    end
  end,
})

return cangji
