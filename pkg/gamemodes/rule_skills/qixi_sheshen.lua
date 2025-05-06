local sheshen = fk.CreateSkill {
  name = "qixi_sheshen",
}

Fk:loadTranslationTable{
  ["qixi_sheshen"] = "舍身",
  [":qixi_sheshen"] = "伴侣技，当伴侣不以此法受到伤害时，你可以将伤害转移给自己。",

  ["#qixi_sheshen-invoke"] = "舍身：是否将伴侣 %dest 受到的伤害转移给你？",
}

---@param from ServerPlayer
---@param to ServerPlayer
local function isCouple(from, to)
  return from:getMark("qixi_couple") == to.id and to:getMark("qixi_couple") == from.id
end

sheshen:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sheshen.name) and data.skillName ~= sheshen.name and isCouple(target, player)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = sheshen.name,
      prompt = "#qixi_sheshen-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:damage{
      from = data.from,
      to = player,
      damage = data.damage,
      damageType = data.damageType,
      skillName = sheshen.name,
    }
    data:preventDamage()
  end,
})

return sheshen
