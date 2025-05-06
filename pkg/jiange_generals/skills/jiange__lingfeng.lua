local jiange__lingfeng = fk.CreateSkill {
  name = "jiange__lingfeng"
}

Fk:loadTranslationTable{
  ['jiange__lingfeng'] = '灵锋',
  ['#jiange__lingfeng-choose'] = '灵锋：你可以令一名敌方角色失去1点体力',
  [':jiange__lingfeng'] = '摸牌阶段，你可以放弃摸牌，改为亮出牌堆顶两张牌并获得之，若颜色不同，你可以令一名敌方角色失去1点体力。',
}

jiange__lingfeng:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__lingfeng.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(2)
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, jiange__lingfeng.name, nil, true, player.id)
    room:delay(1000)
    local yes = #cards == 2 and Fk:getCardById(cards[1]).color ~= Fk:getCardById(cards[2]).color
    cards = table.filter(cards, function (id)
      return room:getCardArea(id) == Card.Processing
    end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, jiange__lingfeng.name, nil, true, player.id)
    end
    if yes and not player.dead and #U.GetEnemies(room, player) > 0 then
      local to = room:askToChoosePlayers(player, {
        targets = table.map(U.GetEnemies(room, player), Util.IdMapper),
        min_num = 1,
        max_num = 1,
        prompt = "#jiange__lingfeng-choose",
        skill_name = jiange__lingfeng.name,
        cancelable = true
      })
      if #to > 0 then
        room:loseHp(room:getPlayerById(to[1]), 1, jiange__lingfeng.name)
      end
    end
    return true
  end,
})

return jiange__lingfeng
