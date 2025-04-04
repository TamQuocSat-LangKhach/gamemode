local jiange__yuhuo = fk.CreateSkill {
  name = "jiange__yuhuo"
}

Fk:loadTranslationTable{
  ['jiange__yuhuo'] = '浴火',
  [':jiange__yuhuo'] = '锁定技，防止你受到的火焰伤害。',
}

jiange__yuhuo:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  can_trigger = function(_, _, target, player, data)
    return target == player and player:hasSkill(jiange__yuhuo.name) and data.damageType == fk.FireDamage
  end,
  on_use = Util.TrueFunc,
})

return jiange__yuhuo
