local zaibian = fk.CreateSkill {
  name = "zombie_zaibian"
}

Fk:loadTranslationTable{
  ['zombie_zaibian'] = '灾变',
  [':zombie_zaibian'] = '锁定技，摸牌阶段，若X大于0，则你多摸X张牌（X为人类玩家数-僵尸玩家数+1）。',
}

zaibian:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not (player == target and player:hasSkill(zaibian.name)) then return end
    local room = player.room
    local human = #table.filter(room.alive_players, function(p)
      return p.role == "lord" or p.role == "loyalist"
    end)
    local zombie = #room.alive_players - human
    return human - zombie + 1 > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local human = #table.filter(room.alive_players, function(p)
      return p.role == "lord" or p.role == "loyalist"
    end)
    local zombie = #room.alive_players - human
    data.n = data.n + (human - zombie + 1)
  end,
})

return zaibian
