local jiange__shuailing = fk.CreateSkill {
  name = "jiange__shuailing"
}

Fk:loadTranslationTable{
  ['jiange__shuailing'] = '帅令',
  [':jiange__shuailing'] = '锁定技，友方角色摸牌阶段开始时，其进行一次判定，若结果为黑色，其获得判定牌。',
}

jiange__shuailing:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(jiange__shuailing) and target.phase == Player.Draw and table.contains(U.GetFriends(player.room, player), target)
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local judge = {
      who = target,
      reason = jiange__shuailing.name,
      pattern = ".|.|spade,club",
      skipDrop = true,
    }
    room:judge(judge)
    if not target.dead and judge.card.color == Card.Black and room:getCardArea(judge.card) == Card.Processing then
      room:moveCardTo(judge.card, Card.PlayerHand, target, fk.ReasonJustMove, jiange__shuailing.name, nil, true, target.id)
      return
    end
    if room:getCardArea(judge.card) == Card.Processing then
      room:moveCardTo(judge.card, Card.DiscardPile, nil, fk.ReasonJustMove, jiange__shuailing.name, nil, true)
    end
  end,
})

return jiange__shuailing
