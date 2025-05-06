local gongdou = fk.CreateSkill {
  name = "qixi_gongdou",
}

Fk:loadTranslationTable{
  ["qixi_gongdou"] = "共斗",
  [":qixi_gongdou"] = "伴侣技，每回合限一次，当伴侣使用的非转化【杀】结算结束后，你可以视为对相同目标使用一张【杀】。",

  ["#qixi_gongdou-invoke"] = "共斗：是否视为对相同的目标使用【杀】？",
}

---@param from ServerPlayer
---@param to ServerPlayer
local function isCouple(from, to)
  return from:getMark("qixi_couple") == to.id and to:getMark("qixi_couple") == from.id
end

gongdou:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and isCouple(target, player) and
      player:usedSkillTimes(gongdou.name, Player.HistoryTurn) == 0 and
      data.card.trueName == "slash" and not data.card:isVirtual() and
      table.find(data.tos, function (p)
        return not p.dead and player:canUseTo(Fk:cloneCard("slash"), p, { bypass_distances=true, bypass_times = true })
      end)
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = gongdou.name,
      prompt = "#qixi_gongdou-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data.tos, function (p)
      return not p.dead and player:canUseTo(Fk:cloneCard("slash"), p, { bypass_distances=true, bypass_times = true })
    end)
    room:useVirtualCard("slash", nil, player, targets, gongdou.name, true)
  end,
})

return gongdou
