local qibie = fk.CreateSkill {
  name = "qixi_qibie",
}

Fk:loadTranslationTable{
  ["qixi_qibie"] = "泣别",
  [":qixi_qibie"] = "伴侣技，当伴侣求桃结束即将阵亡时，你可以令其失去〖泣别〗，获得你武将牌上所有的技能并回复X点体力" ..
    "（X为你的体力值，至少回复至1点体力），然后你失去所有技能和所有体力。",

  ["#qixi_qibie-invoke"] = "泣别：是否失去所有体力和技能，令伴侣 %dest 回复体力并获得技能？",
}

---@param from ServerPlayer
---@param to ServerPlayer
local function isCouple(from, to)
  return from:getMark("qixi_couple") == to.id and to:getMark("qixi_couple") == from.id
end

qibie:addEffect(fk.AskForPeachesDone, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qibie.name) and isCouple(target, player) and target.hp < 1
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = qibie.name,
      prompt = "#qixi_qibie-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skills = Fk.generals[player.general]:getSkillNameList()
    table.insert(skills, "-qixi_qibie")
    room:handleAddLoseSkills(target, table.concat(skills, "|"))
    room:recover {
      who = target,
      num = math.max(player.hp, 1 - target.hp),
      skillName = qibie.name,
    }

    room:handleAddLoseSkills(player, "-"..table.concat(player:getSkillNameList(), "|-"))
    room:loseHp(player, player.hp, qibie.name)
  end,
})

return qibie
