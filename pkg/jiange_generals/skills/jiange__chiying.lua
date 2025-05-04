local jiange__chiying = fk.CreateSkill {
  name = "jiange__chiying",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["jiange__chiying"] = "持盈",
  [":jiange__chiying"] = "锁定技，当友方角色受到大于1点的伤害时，你令此伤害减至1点。",
}

jiange__chiying:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skill.name) and data.damage > 1 and table.contains(U.GetFriends(player.room, player), target)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:broadcastPlaySound("./packages/maneuvering/audio/card/silver_lion")
    room:setEmotion(target, "./packages/maneuvering/image/anim/silver_lion")
    data.damage = 1
  end,
})

return jiange__chiying
