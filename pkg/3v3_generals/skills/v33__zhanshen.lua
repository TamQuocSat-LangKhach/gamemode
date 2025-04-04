local v33__zhanshen = fk.CreateSkill {
  name = "v33__zhanshen"
}

Fk:loadTranslationTable{
  ['v33__zhanshen'] = '战神',
  ['#v33__zhanshen-choice'] = '战神：选择一项效果，本局游戏永久获得',
  ['v33__zhanshen_1'] = '摸牌阶段多摸一张牌',
  ['v33__zhanshen_2'] = '使用【杀】伤害+1',
  ['v33__zhanshen_3'] = '使用【杀】可以额外选择一个目标',
  ['#v33__zhanshen-choose'] = '战神：你可以为此%arg增加一个目标',
  [':v33__zhanshen'] = '锁定技，准备阶段，你选择一项未获得过的效果，获得此效果直到本局游戏结束：<br>1.摸牌阶段，你多摸一张牌；<br>2.你使用【杀】造成伤害+1；<br>3.你使用【杀】可以额外选择一个目标。',
  ['$v33__zhanshen1'] = '战神降世，神威再临！',
  ['$v33__zhanshen2'] = '战神既出，谁与争锋！',
}

v33__zhanshen:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(v33__zhanshen.name) and player.phase == Player.Start then
      for i = 1, 3 do
        if player:getMark("v33__zhanshen_"..i) == 0 then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local choices = table.map(table.filter({1, 2, 3}, function(n)
      return player:getMark("v33__zhanshen_"..n) == 0
    end), function(n)
        return "v33__zhanshen_"..n
      end)
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = v33__zhanshen.name,
      prompt = "#v33__zhanshen-choice"
    })
    room:setPlayerMark(player, choice, 1)
  end,
})

v33__zhanshen:addEffect(fk.DrawNCards, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("v33__zhanshen_1") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(v33__zhanshen.name)
    room:notifySkillInvoked(player, v33__zhanshen.name, "drawcard")
    data.n = data.n + 1
  end,
})

v33__zhanshen:addEffect(fk.PreCardUse, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("v33__zhanshen_2") > 0 and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(v33__zhanshen.name)
    room:notifySkillInvoked(player, v33__zhanshen.name, "offensive")
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
})

v33__zhanshen:addEffect(fk.AfterCardTargetDeclared, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("v33__zhanshen_3") > 0 and data.card.trueName == "slash" and
      #player.room:getUseExtraTargets(data) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local targets = player.room:getUseExtraTargets(data)
    local tos = player.room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#v33__zhanshen-choose:::"..data.card:toLogString(),
      skill_name = v33__zhanshen.name
    })
    if #tos > 0 then
      event:setCostData(self, tos)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(v33__zhanshen.name)
    room:notifySkillInvoked(player, v33__zhanshen.name, "offensive")
    table.insert(data.tos, event:getCostData(self))
  end,
})

return v33__zhanshen
