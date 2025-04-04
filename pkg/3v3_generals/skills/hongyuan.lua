local hongyuan = fk.CreateSkill {
  name = "v33__hongyuan"
}

Fk:loadTranslationTable{
  ['v33__hongyuan'] = '弘援',
  [':v33__hongyuan'] = '摸牌阶段，你可以少摸一张牌，若如此做，其他己方角色各摸一张牌。',
}

hongyuan:addEffect(fk.DrawNCards, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hongyuan.name) and data.n > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.n = data.n - 1
  end,
})

hongyuan:addEffect(fk.EventPhaseEnd, {
  name = "#v33__hongyuan_trigger",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Draw and player:usedSkillTimes(hongyuan.name, Player.HistoryPhase) > 0
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(U.GetFriends(player.room, player, false)) do
      if not p.dead then
        player.room:doIndicate(player.id, {p.id})
        p:drawCards(1, hongyuan.name)
      end
    end
  end,
})

return hongyuan
