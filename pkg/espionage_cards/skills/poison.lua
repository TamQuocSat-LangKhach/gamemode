local skill = fk.CreateSkill {
  name = "es__poison_skill",
}

Fk:loadTranslationTable{
  ["#es__poison-give"] = "你可以将摸到的【毒】交给其他角色（不触发失去体力效果）",
}

skill:addEffect("cardskill", {
  can_use = Util.FalseFunc,
})

skill:addEffect(fk.BeforeCardsMove, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player then
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player and move.skillName ~= "es__poison_give" and move.skillName ~= "scrape_poison_skill" then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and
            (move.moveVisible or table.contains({Card.PlayerEquip, Card.Processing, Card.DiscardPile}, move.toArea)) then
            if Fk:getCardById(info.cardId, false).name == "es__poison" then
              move.extra_data = move.extra_data or {}
              local dat = move.extra_data.es__poison or {}
              table.insert(dat, player.id)
              move.extra_data.es__poison = dat
            end
          end
        end
      end
    end
  end,
})

skill:addEffect(fk.AfterCardsMove, {
  global = true,
  priority = 0.001,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.extra_data and move.extra_data.es__poison then
        if table.contains(move.extra_data.es__poison, player.id) and not player.dead then
          return true
        end
      end
      if move.to == player and move.toArea == Card.PlayerHand and move.moveReason == fk.ReasonDraw then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).name == "es__poison" then
            return true
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local n = 0
    local ids = {}
    for _, move in ipairs(data) do
      if move.extra_data and move.extra_data.es__poison then
        n = n + #table.filter(move.extra_data.es__poison, function(id)
          return id == player.id
        end)
      end
      if move.to == player and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).name == "es__poison" then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end
    for _ = 1, n, 1 do
      if not player.dead then
        player.room:loseHp(player, 1, "poison")
      end
    end
    ids = table.filter(ids, function(id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if not player.dead and #ids > 0 and #player.room:getOtherPlayers(player, false) > 0 then
      event:setCostData(self, {cards = ids})
      self:doCost(event, nil, player, ids)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local result = room:askToYiji(player, {
      cards = event:getCostData(self).cards,
      targets = room:getOtherPlayers(player, false),
      skill_name = "",
      min_num = 0,
      max_num = 1,
      prompt = "#es__poison-give",
      skip = true,
    })
    for _, cards in pairs(result) do
      if #cards > 0 then
        event:setCostData(self, {extra_data = result})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:doYiji(event:getCostData(self).extra_data, player, "es__poison_give")
  end,
})

return skill
