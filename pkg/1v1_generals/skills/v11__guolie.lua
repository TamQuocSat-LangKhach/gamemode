local v11__guolie = fk.CreateSkill {
  name = "v11__guolie"
}

Fk:loadTranslationTable{
  ['v11__guolie'] = '果烈',
  ['#v11__guolie-use'] = '果烈：你须使用 %arg',
  [':v11__guolie'] = '当你使用【杀】被【闪】抵消时，你可以亮出牌堆顶牌，若你：可以使用此牌，则使用之；不能使用且为【杀】，你获得之。',
}

v11__guolie:addEffect(fk.CardEffectCancelledOut, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(v11__guolie.name) and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(1)
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, v11__guolie.name)
    if not player.dead then
      local card = Fk:getCardById(cards[1])
      local use = room:askToUseRealCard(player, {
        pattern = cards,
        skill_name = v11__guolie.name,
        prompt = "#v11__guolie-use:::" .. card:toLogString(),
        expand_pile = cards,
        cancelable = false,
        skip = false
      })
      if not use and card.trueName == "slash" then
        room:obtainCard(player, card, true, fk.ReasonJustMove, player.id, v11__guolie.name)
      end
    end
    room:cleanProcessingArea(cards, v11__guolie.name)
  end,
})

return v11__guolie
