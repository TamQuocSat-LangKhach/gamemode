local jiange__gongshen = fk.CreateSkill {
  name = "jiange__gongshen"
}

Fk:loadTranslationTable{
  ['jiange__gongshen'] = '工神',
  ['jiange__gongshen1'] = '友方攻城器械回复1点体力',
  ['jiange__gongshen2'] = '对敌方攻城器械造成1点火焰伤害',
  ['#jiange__gongshen-invoke'] = '工神：你可以执行一项',
  [':jiange__gongshen'] = '结束阶段，你可以令友方攻城器械各回复1点体力，或对敌方攻城器械各造成1点火焰伤害。',
}

jiange__gongshen:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__gongshen.name) and player.phase == Player.Finish and
      (table.find(U.GetEnemies(player.room, player), function(p)
        return Fk.generals[p.general].jiange_machine
      end) or
      table.find(U.GetFriends(player.room, player), function(p)
        return Fk.generals[p.general].jiange_machine and p:isWounded()
      end))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choices = {}
    if table.find(U.GetFriends(room, player), function(p)
      return Fk.generals[p.general].jiange_machine and p:isWounded()
    end) then
      table.insert(choices, "jiange__gongshen1")
    end
    if table.find(U.GetEnemies(room, player), function(p)
      return Fk.generals[p.general].jiange_machine
    end) then
      table.insert(choices, "jiange__gongshen2")
    end
    table.insert(choices, "Cancel")
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = jiange__gongshen.name,
      prompt = "#jiange__gongshen-invoke",
      detailed = false,
      all_choices = {"jiange__gongshen1", "jiange__gongshen2", "Cancel"}
    })
    if choice ~= "Cancel" then
      event:setCostData(skill, choice:sub(17))
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(jiange__gongshen.name)
    if event:getCostData(skill) == "1" then
      local targets = table.filter(U.GetFriends(room, player), function(p)
        return Fk.generals[p.general].jiange_machine and p:isWounded()
      end)
      room:doIndicate(player.id, table.map(targets, Util.IdMapper))
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if table.contains(targets, p) and not p.dead and p:isWounded() then
          room:recover({
            who = p,
            num = 1,
            recoverBy = player,
            skillName = jiange__gongshen.name,
          })
        end
      end
    else
      local targets = table.filter(U.GetEnemies(room, player), function(p)
        return Fk.generals[p.general].jiange_machine
      end)
      room:doIndicate(player.id, table.map(targets, Util.IdMapper))
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if table.contains(targets, p) and not p.dead then
          room:damage({
            from = player,
            to = p,
            damage = 1,
            damageType = fk.FireDamage,
            skillName = jiange__gongshen.name,
          })
        end
      end
    end
  end,
})

return jiange__gongshen
