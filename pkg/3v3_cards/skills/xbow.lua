local sk = fk.CreateSkill {
  name = "#xbow_skill",
  tags = { Skill.Compulsory },
  attached_equip = "xbow",
}

sk:addEffect("targetmod", {
  residue_func = function (self, player, skill, scope, card, to)
    if player:hasSkill(sk.name) and card and card.trueName == "slash" and scope == Player.HistoryPhase then
      --FIXME: 无法检测到非转化的cost选牌的情况，如活墨等
      local cardIds = Card:getIdList(card)
      local xbows = table.filter(player:getEquipments(Card.SubtypeWeapon), function(id)
        return Fk:getCardById(id).name == sk.attached_equip
      end)
      if #xbows == 0 or not table.every(xbows, function(id)
        return table.contains(cardIds, id)
      end) then
        return 3
      end
    end
  end,
})

sk:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(sk.name) and player.phase == Player.Play and
      data.card.trueName == "slash" and not data.extraUse and player:usedCardTimes("slash", Player.HistoryPhase) > 1
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:broadcastPlaySound("./packages/standard_cards/audio/card/xbow")
    room:setEmotion(player, "./packages/standard_cards/image/anim/xbow")
    room:sendLog{
      type = "#InvokeSkill",
      from = player.id,
      arg = "xbow",
    }
  end,
})

return sk
