local jiange__lingyu = fk.CreateSkill {
  name = "jiange__lingyu"
}

Fk:loadTranslationTable{
  ['jiange__lingyu'] = '灵愈',
  ['#jiange__lingyu-invoke'] = '灵愈：是否翻面，令其他友方角色各回复1点体力？',
  [':jiange__lingyu'] = '结束阶段，你可以翻面，然后令其他友方角色各回复1点体力。',
}

jiange__lingyu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiange__lingyu.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiange__lingyu.name,
      prompt = "#jiange__lingyu-invoke"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, table.map(U.GetFriends(room, player, false), Util.IdMapper))
    player:turnOver()
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead and table.contains(U.GetFriends(room, player), p) and p:isWounded() then
        room:recover({
          who = p,
          num = 1,
          recoverBy = player,
          skillName = jiange__lingyu.name,
        })
      end
    end
  end,
})

return jiange__lingyu
