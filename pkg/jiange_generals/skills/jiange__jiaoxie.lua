local jiange__jiaoxie = fk.CreateSkill {
  name = "jiange__jiaoxie"
}

Fk:loadTranslationTable{
  ['jiange__jiaoxie'] = '缴械',
  ['#jiange__jiaoxie'] = '缴械：令至多两名敌方攻城器械各交给你一张牌',
  ['#jiange__jiaoxie-give'] = '缴械：你须交给 %src 一张牌',
  [':jiange__jiaoxie'] = '出牌阶段限一次，你可以令至多两名敌方攻城器械各交给你一张牌。',
}

jiange__jiaoxie:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  min_target_num = 1,
  max_target_num = 2,
  prompt = "#jiange__jiaoxie",
  can_use = function(self, player)
    return player:usedSkillTimes(jiange__jiaoxie.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected < 2 and table.contains(U.GetEnemies(Fk:currentRoom(), player), target) and
      Fk.generals[target.general].jiange_machine and not target:isNude()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:sortPlayersByAction(effect.tos)
    for _, id in ipairs(effect.tos) do
      if player.dead then return end
      local target = room:getPlayerById(id)
      if not target.dead and not target:isNude() then
        local card = room:askToCards(target, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = jiange__jiaoxie.name,
          cancelable = false,
          prompt = "#jiange__jiaoxie-give:"..player.id
        })
        room:moveCardTo(card[1], Card.PlayerHand, player, fk.ReasonGive, jiange__jiaoxie.name, nil, false, target.id)
      end
    end
  end,
})

return jiange__jiaoxie
