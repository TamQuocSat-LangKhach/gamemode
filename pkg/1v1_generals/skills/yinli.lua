local yinli = fk.CreateSkill {
  name = "v11__yinli"
}

Fk:loadTranslationTable{
  ['v11__yinli'] = '姻礼',
  ['#v11__yinli-choose'] = '姻礼：选择你要获得的装备牌',
  [':v11__yinli'] = '对手的回合内，当该角色的装备牌置入弃牌堆时，你可以获得之。',
  ['$v11__yinli1'] = '这份大礼我收下啦！',
  ['$v11__yinli2'] = '小女子谢过将军。',
}

yinli:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yinli.name) and player.phase == Player.NotActive then
      local ids = {}
      local room = player.room
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.from and move.from ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                Fk:getCardById(info.cardId).type == Card.TypeEquip and
                room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(ids, info.cardId)
              end
            end
          end
        end
      end
      ids = player.room.logic:moveCardsHoldingAreaCheck(ids)
      if #ids > 0 then
        event:setCostData(self, ids)
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = table.simpleClone(event:getCostData(self))
    if #ids > 1 then
      local cards, _ = room:askToChooseCardsAndPlayers(player, {
        min_card_num = 1,
        max_card_num = #ids,
        pattern = "Equip",
        prompt = "#v11__yinli-choose",
        cancelable = false,
        targets = {},
        skill_name = yinli.name
      })
      if #cards > 0 then
        ids = cards
      end
    end
    room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, yinli.name, nil, true, player.id)
  end,
})

return yinli
