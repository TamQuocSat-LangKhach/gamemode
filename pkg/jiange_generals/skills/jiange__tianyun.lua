local jiange__tianyun = fk.CreateSkill {
  name = "jiange__tianyun"
}

Fk:loadTranslationTable{
  ['jiange__tianyun'] = '天陨',
  ['#jiange__tianyun-invoke'] = '天陨：你可以失去1点体力，然后对一名敌方角色造成2点火焰伤害并弃置其装备区内所有牌',
  ['#jiange__tianyun-choose'] = '天陨：对一名敌方角色造成2点火焰伤害并弃置其装备区内所有牌',
  [':jiange__tianyun'] = '结束阶段，你可以失去1点体力，然后对一名敌方角色造成2点火焰伤害并弃置其装备区内所有牌。',
}

jiange__tianyun:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(jiange__tianyun.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiange__tianyun.name,
      prompt = "#jiange__tianyun-invoke"
    })
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:loseHp(player, 1, jiange__tianyun.name)
    if player.dead or #U.GetEnemies(room, player) == 0 then return end
    local to = room:askToChoosePlayers(player, {
      targets = table.map(U.GetEnemies(room, player), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#jiange__tianyun-choose",
      skill_name = jiange__tianyun.name
    })
    to = room:getPlayerById(to[1])
    room:damage({
      from = player,
      to = to,
      damage = 2,
      damageType = fk.FireDamage,
      skillName = jiange__tianyun.name,
    })
    if not to.dead then
      to:throwAllCards("e")
    end
  end,
})

return jiange__tianyun
