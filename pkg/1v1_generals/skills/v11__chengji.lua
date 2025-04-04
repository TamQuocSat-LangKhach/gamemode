local v11__chengji = fk.CreateSkill {
  name = "v11__chengji"
}

Fk:loadTranslationTable{
  ['v11__chengji'] = '城棘',
  [':v11__chengji'] = '当你造成或受到伤害后，若“城棘”牌少于四张，你可以将造成伤害的牌置于你的武将牌上。你死亡后，你的下一名武将登场时获得所有“城棘”牌。',
}

v11__chengji:addEffect(fk.Damage, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(v11__chengji.name) and data.card and #player:getPile(v11__chengji.name) < 4 then
      local room = player.room
      local subcards = Card:getIdList(data.card)
      return #subcards > 0 and table.every(subcards, function(id) return room:getCardArea(id) == Card.Processing end)
    end
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile(v11__chengji.name, data.card, true, v11__chengji.name)
  end,
})

v11__chengji:addEffect(fk.Death, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player then
      return #player:getPile(v11__chengji.name) > 0 and player.room.settings.gameMode == "m_1v1_mode"
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Death then
      room:setTag("v11__chengji"..player.id, table.simpleClone(player:getPile(v11__chengji.name)))
      room:moveCardTo(player:getPile(v11__chengji.name), Card.Void, nil, fk.ReasonJustMove, v11__chengji.name, nil, true, player.id)
    end
  end,
})

v11__chengji:addEffect("fk.Debut", {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player then
      return player.room:getTag("v11__chengji"..player.id) ~= nil
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.simpleClone(room:getTag("v11__chengji"..player.id))
    room:removeTag("v11__chengji"..player.id)
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, v11__chengji.name, nil, true, player.id)
  end,
})

return v11__chengji
