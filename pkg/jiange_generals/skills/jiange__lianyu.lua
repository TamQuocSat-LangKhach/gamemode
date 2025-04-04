local jiange__lianyu = fk.CreateSkill {
  name = "jiange__lianyu"
}

Fk:loadTranslationTable{
  ['jiange__lianyu'] = '炼狱',
  ['#jiange__lianyu-invoke'] = '炼狱：是否翻面并对所有敌方角色各造成1点火焰伤害？',
  [':jiange__lianyu'] = '结束阶段，你可以翻面，对所有敌方角色各造成1点火焰伤害。',
}

jiange__lianyu:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__lianyu.name) and player.phase == Player.Finish and
      #U.GetEnemies(player.room, player) > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiange__lianyu.name,
      prompt = "#jiange__lianyu-invoke"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, table.map(U.GetEnemies(room, player), Util.IdMapper))
    player:turnOver()
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if table.contains(U.GetEnemies(room, player), p) and not p.dead then
        room:damage({
          from = player,
          to = p,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = jiange__lianyu.name,
        })
      end
    end
  end,
})

return jiange__lianyu
