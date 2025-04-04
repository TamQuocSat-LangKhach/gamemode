local v11__puji = fk.CreateSkill {
  name = "v11__puji"
}

Fk:loadTranslationTable{
  ['v11__puji'] = '普济',
  ['#v11__puji'] = '普济：你可以弃置一张牌，再弃置对手一张牌。失去♠牌的角色摸一张牌',
  [':v11__puji'] = '出牌阶段限一次，若对手有牌，你可以弃置一张牌，然后弃置其一张牌。然后以此法失去♠牌的角色摸一张牌。',
}

v11__puji:addEffect('active', {
  anim_type = "control",
  card_num = 1,
  target_num = 0,
  prompt = "#v11__puji",
  can_use = function(self, player)
    return player:usedSkillTimes(v11__puji.name, Player.HistoryPhase) == 0 and not player.next:isNude()
  end,
  card_filter = function (skill, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local drawers = {}
    if Fk:getCardById(effect.cards[1]).suit == Card.Spade then
      table.insert(drawers, player)
    end
    room:throwCard(effect.cards, v11__puji.name, player, player)
    local to = player.next
    if not to:isNude() then
      local cid = room:askToChooseCard(player, {
        target = to,
        flag = "he",
        skill_name = v11__puji.name
      })
      if Fk:getCardById(cid).suit == Card.Spade then
        table.insert(drawers, to)
      end
      room:throwCard(cid, v11__puji.name, to, player)
    end
    for _, p in ipairs(drawers) do
      if not p.dead then
        p:drawCards(1, v11__puji.name)
      end
    end
  end,
})

return v11__puji
