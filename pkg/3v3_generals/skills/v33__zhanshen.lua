local v33__zhanshen = fk.CreateSkill {
  name = "v33__zhanshen",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["v33__zhanshen"] = "战神",
  [":v33__zhanshen"] = "锁定技，准备阶段，你选择一项未获得过的效果，获得此效果直到本局游戏结束：<br>"..
  "1.摸牌阶段，你多摸一张牌；<br>"..
  "2.你使用【杀】造成伤害+1；<br>"..
  "3.你使用【杀】可以额外选择一个目标。",

  ["#v33__zhanshen-choice"] = "战神：选择一项效果，本局游戏永久获得",
  ["v33__zhanshen_1"] = "摸牌阶段多摸一张牌",
  ["v33__zhanshen_2"] = "使用【杀】伤害+1",
  ["v33__zhanshen_3"] = "使用【杀】可以额外选择一个目标",
  ["#v33__zhanshen-choose"] = "战神：你可以为此%arg增加一个目标",

  ["$v33__zhanshen1"] = "战神降世，神威再临！",
  ["$v33__zhanshen2"] = "战神既出，谁与争锋！",
}

v33__zhanshen:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(v33__zhanshen.name) and player.phase == Player.Start then
      for i = 1, 3 do
        if player:getMark("v33__zhanshen_"..i) == 0 then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = table.map(table.filter({1, 2, 3}, function(n)
      return player:getMark("v33__zhanshen_"..n) == 0
    end), function(n)
      return "v33__zhanshen_"..n
    end)
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = v33__zhanshen.name,
      prompt = "#v33__zhanshen-choice",
    })
    room:setPlayerMark(player, choice, 1)
  end,
})

v33__zhanshen:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("v33__zhanshen_1") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
})

v33__zhanshen:addEffect(fk.PreCardUse, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("v33__zhanshen_2") > 0 and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
})

v33__zhanshen:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("v33__zhanshen_3") > 0 and data.card.trueName == "slash" and
      #data:getExtraTargets() > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = data:getExtraTargets(),
      min_num = 1,
      max_num = 1,
      prompt = "#v33__zhanshen-choose:::"..data.card:toLogString(),
      skill_name = v33__zhanshen.name,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(event:getCostData(self).tos) do
      data:addTarget(p)
    end
  end,
})

return v33__zhanshen
