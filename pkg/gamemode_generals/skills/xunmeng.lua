local xunmeng = fk.CreateSkill {
  name = "zombie_xunmeng"
}

Fk:loadTranslationTable{
  ['zombie_xunmeng'] = '迅猛',
  [':zombie_xunmeng'] = '锁定技，你的【杀】造成伤害时，令此伤害+1，若此时你的体力值大于1，则你失去1点体力。',
}

xunmeng:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xunmeng.name) and data.card and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.damage = data.damage + 1
    if player.hp > 1 then
      room:loseHp(player, 1, xunmeng.name)
    end
  end,
})

return xunmeng
