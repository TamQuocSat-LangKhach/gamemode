local jiange__tianyu = fk.CreateSkill {
  name = "jiange__tianyu"
}

Fk:loadTranslationTable{
  ['jiange__tianyu'] = '天狱',
  ['#jiange__tianyu-invoke'] = '天狱：是否横置所有敌方角色？',
  [':jiange__tianyu'] = '结束阶段，你可以横置所有敌方角色。',
}

jiange__tianyu:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__tianyu.name) and player.phase == Player.Finish and
      table.find(U.GetEnemies(player.room, player), function (p)
        return not p.chained
      end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiange__tianyu.name,
      prompt = "#jiange__tianyu-invoke"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("lianhuan")
    local targets = table.filter(U.GetEnemies(room, player), function (p)
      return not p.chained
    end)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if table.contains(targets, p) and not p.dead then
        p:setChainState(true)
      end
    end
  end,
})

return jiange__tianyu
