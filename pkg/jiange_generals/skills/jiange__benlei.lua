local jiange__benlei = fk.CreateSkill {
  name = "jiange__benlei"
}

Fk:loadTranslationTable{
  ['jiange__benlei'] = '奔雷',
  ['#jiange__benlei-choose'] = '奔雷：你可以对一名敌方攻城器械造成2点雷电伤害',
  [':jiange__benlei'] = '准备阶段，你可以对一名敌方攻城器械造成2点雷电伤害。',
}

jiange__benlei:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(jiange__benlei.name) and player.phase == Player.Start and
      table.find(U.GetEnemies(player.room, player), function (p)
        return Fk.generals[p.general].jiange_machine
      end)
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local targets = table.filter(U.GetEnemies(room, player), function (p)
      return Fk.generals[p.general].jiange_machine
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#jiange__benlei-choose",
      skill_name = jiange__benlei.name,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:damage({
      from = player,
      to = room:getPlayerById(event:getCostData(self)),
      damage = 2,
      damageType = fk.ThunderDamage,
      skillName = jiange__benlei.name,
    })
  end,
})

return jiange__benlei
