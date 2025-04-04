local jiange__fengxing = fk.CreateSkill {
  name = "jiange__fengxing"
}

Fk:loadTranslationTable{
  ['jiange__fengxing'] = '风行',
  ['#jiange__fengxing-slash'] = '风行：你可以视为对一名敌方角色使用一张【杀】',
  [':jiange__fengxing'] = '准备阶段，你可以视为对一名敌方角色使用一张【杀】。',
}

jiange__fengxing:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Start and
      table.find(U.GetEnemies(player.room, player), function (p)
        return not player:isProhibited(p, Fk:cloneCard("slash"))
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(U.GetEnemies(room, player), function (p)
      return not player:isProhibited(p, Fk:cloneCard("slash"))
    end)
    local use = room:askToUseRealCard(player, {
      pattern = "slash",
      skill_name = jiange__fengxing.name,
      prompt = "#jiange__fengxing-slash",
      cancelable = true,
      extra_data = {exclusive_targets = table.map(targets, Util.IdMapper)},
      skip = true
    })
    if use then
      event:setCostData(skill, use)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("shensu")
    player.room:useCard(event:getCostData(skill))
  end,
})

return jiange__fengxing
