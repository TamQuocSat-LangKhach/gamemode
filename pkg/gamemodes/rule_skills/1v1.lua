local rule = fk.CreateSkill {
  name = "#m_1v1_rule&",
}

--登场
rule:addEffect(fk.GameStart, {
  can_refresh = function(self, event, target, player, data)
    return player.room.current == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room.logic:trigger("fk.Debut", player, player.general, false)
    room.logic:trigger("fk.Debut", player.next, player.general, false)
  end,
})

--初始手牌
rule:addEffect(fk.DrawInitialCards, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    data.num = math.min(player.maxHp, 5)
  end,
})

--先手第一回合少摸一张牌
rule:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, target, player, data)
    --注意1v1不能用mark做记录
    return target == player and player.role == "lord" and player.room:getBanner(self.name) == nil
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setBanner(self.name, 1)
    data.n = data.n - 1
  end,
})

--阵亡换将
rule:addEffect(fk.GameOverJudge, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    if player.rest > 0 then return end
    local num, num2 = tonumber(room:getBanner("@firstFallen")[1]), tonumber(room:getBanner("@secondFallen")[1])
    if player.role == "lord" then num = num + 1 else num2 = num2 + 1 end
    room:setBanner("@firstFallen", tostring(num) .. " / 3")
    room:setBanner("@secondFallen", tostring(num2) .. " / 3")
    room:sendLog{
      type = "#1v1Score",
      arg = num,
      arg2 = num2,
      toast = true,
    }
    if num < 3 and num2 < 3 then return end
    room:gameOver(player.next.role)
  end,
})

local function drawInit(room, player, n)
  -- TODO: need a new function to call the UI
  local cardIds = room:getNCards(n)
  player:addCards(Player.Hand, cardIds)
  for _, id in ipairs(cardIds) do
    Fk:filterCard(id, player)
  end

  local move_to_notify = {   ---@type MoveCardsDataSpec
    moveInfo = {},
    to = player,
    toArea = Card.PlayerHand,
    moveReason = fk.ReasonDraw
  }
  for _, id in ipairs(cardIds) do
    table.insert(move_to_notify.moveInfo,
    { cardId = id, fromArea = Card.DrawPile })
  end
  room:notifyMoveCards(nil, {move_to_notify})

  for _, id in ipairs(cardIds) do
    table.removeOne(room.draw_pile, id)
    room:setCardArea(id, Card.PlayerHand, player.id)
  end
end

local function removeGeneral(generals, g)
  local gt = Fk.generals[g].trueName
  for i, v in ipairs(generals) do
    if Fk.generals[v].trueName == gt then
      return table.remove(generals, i)
    end
  end
  return table.remove(generals, 1)
end

rule:addEffect(fk.BuryVictim, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    local generals = room:getBanner(player.role == "lord" and "@&firstGenerals" or "@&secondGenerals")
    player:bury()
    if player.rest > 0 then return end
    local exiled_name = player.role == "lord" and "@&firstExiled" or "@&secondExiled"
    local exiled_generals = room:getBanner(exiled_name) or  {}
    table.insert(exiled_generals, player.general)
    room:setBanner(exiled_name, exiled_generals)
    if #generals == 0 then
      room:gameOver(player.next.role)
      return
    end
    local current = room.logic:getCurrentEvent()
    local last_event = nil
    if room.current.dead then
      last_event = current:findParent(GameEvent.Turn, true)
    end
    if last_event == nil then
      last_event = current
      if last_event.parent then
        repeat
          if table.contains({GameEvent.Round, GameEvent.Turn, GameEvent.Phase}, last_event.parent.event) then break end
          last_event = last_event.parent
        until (not last_event.parent)
      end
    end
    last_event:addCleaner(function()
      local req = Request:new({player}, "AskForGeneral")
      req:setData(player, { generals, 1 })
      req:setDefaultReply(player, { generals[1] })
      req:ask()
      local g = req:getResult(player)[1]
      removeGeneral(generals, g)
      room:setBanner(player.role == "lord" and "@&firstGenerals" or "@&secondGenerals", generals)

      room:handleAddLoseSkills(player, "-"..table.concat(player:getSkillNameList(), "|-"), nil, false)
      room:resumePlayerArea(target, {
        Player.WeaponSlot,
        Player.ArmorSlot,
        Player.OffensiveRideSlot,
        Player.DefensiveRideSlot,
        Player.TreasureSlot,
        Player.JudgeSlot,
      }) -- 全部恢复
      room:changeHero(player, g, true, false, true)

      -- trigger leave

      room:setPlayerProperty(player, "shield", Fk.generals[g].shield)
      room:revivePlayer(player, false)
      local draw_data = DrawInitialData:new{ num = math.min(player.maxHp, 5) }
      room.logic:trigger(fk.DrawInitialCards, player, draw_data)
      drawInit(room, player, math.min(player.maxHp, 5))
      room.logic:trigger(fk.AfterDrawInitialCards, player, draw_data)
      room.logic:trigger("fk.Debut", player, player.general, false)
    end)
  end,
})

return rule
