local nos__xuanbei = fk.CreateSkill {
  name = "nos__xuanbei"
}

Fk:loadTranslationTable{
  ['nos__xuanbei'] = '选备',
  ['#nos__xuanbei-give'] = '选备：你可以将 %arg 交给一名其他角色',
  [':nos__xuanbei'] = '游戏开始时，你获得两张带有应变效果的牌。每回合限一次，当你使用带有应变效果的牌结算后，你可以将之交给一名其他角色。',
  ['$nos__xuanbei1'] = '男胤有德色，愿陛下以备六宫。',
  ['$nos__xuanbei2'] = '广集良家，召充选者使吾拣择。',
}

nos__xuanbei:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(nos__xuanbei) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    for _, id in ipairs(room.draw_pile) do
      if table.find({"@fujia", "@kongchao", "@canqu", "@zhuzhan"}, function(mark) return Fk:getCardById(id):getMark(mark) ~= 0 end) then
        table.insert(cards, id)
      end
    end
    if #cards > 0 then
      room:moveCardTo(table.random(cards, 2), Card.PlayerHand, player, fk.ReasonJustMove, nos__xuanbei.name, nil, false, player.id)
    end
  end,
})

nos__xuanbei:addEffect(fk.CardUseFinished, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(nos__xuanbei) then
      return target == player and not data.card:isVirtual() and
        table.find({"@fujia", "@kongchao", "@canqu", "@zhuzhan"}, function(mark) return data.card:getMark(mark) ~= 0 end) and
        player.room:getCardArea(data.card.id) == Card.Processing and
        player:usedSkillTimes(nos__xuanbei.name, Player.HistoryTurn) == 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#nos__xuanbei-give:::" .. data.card:toLogString(),
      skill_name = nos__xuanbei.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost_data = event:getCostData(self)
    room:moveCardTo(data.card, Card.PlayerHand, room:getPlayerById(cost_data.tos[1]), fk.ReasonGive, nos__xuanbei.name, nil, true, player.id)
  end,
})

return nos__xuanbei
