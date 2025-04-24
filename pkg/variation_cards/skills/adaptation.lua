local skill = fk.CreateSkill {
  name = "adaptation_skill",
}


skill:addEffect("cardskill", {
  can_use = Util.FalseFunc,
})

skill:addEffect("filter", {
  global = true,
  mute = true,
  card_filter = function(self, card, player)
    return card.name == "adaptation" and player:getMark("adaptation-turn") ~= 0
  end,
  view_as = function(self, player, card)
    return Fk:cloneCard(player:getMark("adaptation-turn"), card.suit, card.number)
  end,
})

local spec = {
  can_refresh = function(self, event, target, player, data)
    return target == player and (data.card.type == Card.TypeBasic or data.card:isCommonTrick())
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "adaptation-turn", data.card.name)
  end,
}

skill:addEffect(fk.PreCardUse, {
  global = true,
  can_refresh = spec.can_refresh,
  on_refresh = spec.on_refresh,
})
skill:addEffect(fk.PreCardRespond, {
  global = true,
  can_refresh = spec.can_refresh,
  on_refresh = spec.on_refresh,
})

return skill
