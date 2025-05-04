

local xbowSkill = fk.CreateTargetModSkill{
  name = "#xbow_skill",
  attached_equip = "xbow",
  frequency = Skill.Compulsory,
  residue_func = function(self, player, skill, scope, card)
    if player:hasSkill(self) and skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      --FIXME: 无法检测到非转化的cost选牌的情况，如活墨等
      local cardIds = Card:getIdList(card)
      local xbows = table.filter(player:getEquipments(Card.SubtypeWeapon), function(id)
        return Fk:getCardById(id).equip_skill == self
      end)
      if #xbows == 0 or not table.every(xbows, function(id)
        return table.contains(cardIds, id)
      end) then
        return 3
      end
    end
  end,
}
local xbowAudio = fk.CreateTriggerSkill{
  name = "#xbowAudio",

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(xbowSkill) and player.phase == Player.Play and
      data.card.trueName == "slash" and player:usedCardTimes("slash", Player.HistoryPhase) > 1
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:broadcastPlaySound("./packages/standard_cards/audio/card/crossbow")
    room:setEmotion(player, "./packages/standard_cards/image/anim/crossbow")
    room:sendLog{
      type = "#InvokeSkill",
      from = player.id,
      arg = "xbow",
    }
  end,
}
