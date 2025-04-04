local zhanshen = fk.CreateSkill {
  name = "zhanshen"
}

Fk:loadTranslationTable{
  ['zhanshen'] = '战神',
  [':zhanshen'] = '觉醒技，准备阶段，若你已受伤且己方有角色已死亡，你减1点体力上限，获得技能〖马术〗和〖神戟〗。',
}

zhanshen:addEffect(fk.EventPhaseStart, {
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhanshen.name) and
      player.phase == Player.Start and
      player:usedSkillTimes(zhanshen.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:isWounded() and table.find(U.GetFriends(player.room, player, true, true), function (p)
      return p.dead
    end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if not player.dead then
      room:handleAddLoseSkills(player, "mashu|shenji", nil)
    end
  end,
})

return zhanshen
