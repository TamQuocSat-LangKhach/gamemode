local xunmeng = fk.CreateSkill {
  name = "zombie_xunmeng",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["zombie_xunmeng"] = "迅猛",
  [":zombie_xunmeng"] = "锁定技，你使用【杀】对目标角色造成伤害时，此伤害+1，若此时你的体力值大于1，则你失去1点体力。",
}

xunmeng:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xunmeng.name) and
      data.card and data.card.trueName == "slash" and
      player.room.logic:damageByCardEffect()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:changeDamage(1)
    if player.hp > 1 then
      room:loseHp(player, 1, xunmeng.name)
    end
  end,
})

return xunmeng
