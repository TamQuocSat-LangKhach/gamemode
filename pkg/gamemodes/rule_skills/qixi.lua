local rule = fk.CreateSkill {
  name = "#qixi_rule&",
}

Fk:loadTranslationTable{
  ["#QixiModeNegative"] = "由于 %from 没有伴侣，防止其造成致命伤害",
}

---@param from Player
---@param to Player
local function canPayCourtTo(from, to)
  if from:getMark("qixi_couple") ~= 0 then return false end
  if to:getMark("qixi_couple") ~= 0 then return false end
  if from:getMark("@!qixi_female") == to:getMark("@!qixi_female") then return false end
  return true
end

--没有伴侣无法造成致命伤害
rule:addEffect(fk.DamageCaused, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("qixi_couple") == 0 and data.damage >= (data.to.hp + data.to.shield)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if table.find(room:getOtherPlayers(player, false), function(p)
      return canPayCourtTo(player, p)
    end) then
      room:sendLog{
        type = "#QixiModeNegative",
        from = player.id,
        toast = true,
      }
      data:preventDamage()
    else
      data:changeDamage(1)
    end
  end,
})

--正牌伴侣男方拥有英姿
rule:addEffect(fk.DrawNCards, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@qixi_couple_pink") ~= 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = "yingzi",
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("yingzi")
    room:notifySkillInvoked(player, "yingzi", "drawcard")
    data.n = data.n + 1
  end,
})

--正牌伴侣女方拥有闭月
rule:addEffect(fk.EventPhaseStart, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player.phase == Player.Finish and player:getMark("@qixi_couple_blue") ~= 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = "biyue",
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("biyue")
    room:notifySkillInvoked(player, "biyue", "drawcard")
    player:drawCards(1, "biyue")
  end,
})

return rule
