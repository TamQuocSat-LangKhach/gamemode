local hidden_skill = fk.CreateSkill {
  name = "hidden_skill&"
}

Fk:loadTranslationTable{
  ['hidden_skill&'] = '隐匿',
  [':hidden_skill&'] = '若你为隐匿将，防止你改变体力上限。当你扣减体力后，或你回合开始时，你解除隐匿状态。',
}

hidden_skill:addEffect(fk.HpChanged, {
  priority = 0.001,
  mute = true,
  can_trigger = function(self, event, target, player)
    if target == player and not player.dead and
      (player:getMark("__hidden_general") ~= 0 or player:getMark("__hidden_deputy") ~= 0) then
      return data.num < 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    if event == fk.BeforeMaxHpChanged then
      return true
    else
      room:handleAddLoseSkills(player, "-"..hidden_skill.name, nil, false, true)
      if Fk.generals[player:getMark("__hidden_general")] then
        player.general = player:getMark("__hidden_general")
      end
      if Fk.generals[player:getMark("__hidden_deputy")] then
        player.deputyGeneral = player:getMark("__hidden_deputy")
      end
      room:setPlayerMark(player, "__hidden_general", 0)
      room:setPlayerMark(player, "__hidden_deputy", 0)
      local general = Fk.generals[player.general]
      local deputy = Fk.generals[player.deputyGeneral]
      player.gender = general.gender
      player.kingdom = general.kingdom
      room:broadcastProperty(player, "gender")
      room:broadcastProperty(player, "general")
      room:broadcastProperty(player, "deputyGeneral")
      room:askToChooseKingdom({player})
      room:broadcastProperty(player, "kingdom")

      if player:getMark("__hidden_record") ~= 0 then
        player.maxHp = player:getMark("__hidden_record").maxHp
        player.hp = player:getMark("__hidden_record").hp
      else
        player.maxHp = player:getGeneralMaxHp()
        player.hp = deputy and math.floor((deputy.hp + general.hp) / 2) or general.hp
      end
      player.shield = math.min(general.shield + (deputy and deputy.shield or 0), 5)
      if player:getMark("__hidden_record") ~= 0 then
        room:setPlayerMark(player, "__hidden_record", 0)
      else
        local changer = Fk.game_modes[room.settings.gameMode]:getAdjustedProperty(player)
        if changer then
          for key, value in pairs(changer) do
            player[key] = value
          end
        end
      end
      room:broadcastProperty(player, "maxHp")
      room:broadcastProperty(player, "hp")
      room:broadcastProperty(player, "shield")

      local lordBuff = player.role == "lord" and player.role_shown == true and #room.players > 4
      local skills = general:getSkillNameList(lordBuff)
      if deputy then
        table.insertTable(skills, deputy:getSkillNameList(lordBuff))
      end
      skills = table.filter(skills, function (s)
        local skill = Fk.skills[s]
        return skill and (#skill.attachedKingdom == 0 or table.contains(skill.attachedKingdom, player.kingdom))
      end)
      if #skills > 0 then
        room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, false)
      end

      room:sendLog{ type = "#RevealGeneral", from = player.id, arg =  "mainGeneral", arg2 = general.name }
      local event_data = {["m"] = general}
      if deputy then
        room:sendLog{ type = "#RevealGeneral", from = player.id, arg =  "deputyGeneral", arg2 = deputy.name }
        event_data["d"] = deputy.name
      end
      room.logic:trigger("fk.GeneralAppeared", player, event_data)
    end
  end,
})

hidden_skill:addEffect(fk.TurnStart, {
  priority = 0.001,
  mute = true,
  can_trigger = function(self, event, target, player)
    if target == player and not player.dead and
      (player:getMark("__hidden_general") ~= 0 or player:getMark("__hidden_deputy") ~= 0) then
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    if event == fk.BeforeMaxHpChanged then
      return true
    else
      room:handleAddLoseSkills(player, "-"..hidden_skill.name, nil, false, true)
      if Fk.generals[player:getMark("__hidden_general")] then
        player.general = player:getMark("__hidden_general")
      end
      if Fk.generals[player:getMark("__hidden_deputy")] then
        player.deputyGeneral = player:getMark("__hidden_deputy")
      end
      room:setPlayerMark(player, "__hidden_general", 0)
      room:setPlayerMark(player, "__hidden_deputy", 0)
      local general = Fk.generals[player.general]
      local deputy = Fk.generals[player.deputyGeneral]
      player.gender = general.gender
      player.kingdom = general.kingdom
      room:broadcastProperty(player, "gender")
      room:broadcastProperty(player, "general")
      room:broadcastProperty(player, "deputyGeneral")
      room:askToChooseKingdom({player})
      room:broadcastProperty(player, "kingdom")

      if player:getMark("__hidden_record") ~= 0 then
        player.maxHp = player:getMark("__hidden_record").maxHp
        player.hp = player:getMark("__hidden_record").hp
      else
        player.maxHp = player:getGeneralMaxHp()
        player.hp = deputy and math.floor((deputy.hp + general.hp) / 2) or general.hp
      end
      player.shield = math.min(general.shield + (deputy and deputy.shield or 0), 5)
      if player:getMark("__hidden_record") ~= 0 then
        room:setPlayerMark(player, "__hidden_record", 0)
      else
        local changer = Fk.game_modes[room.settings.gameMode]:getAdjustedProperty(player)
        if changer then
          for key, value in pairs(changer) do
            player[key] = value
          end
        end
      end
      room:broadcastProperty(player, "maxHp")
      room:broadcastProperty(player, "hp")
      room:broadcastProperty(player, "shield")

      local lordBuff = player.role == "lord" and player.role_shown == true and #room.players > 4
      local skills = general:getSkillNameList(lordBuff)
      if deputy then
        table.insertTable(skills, deputy:getSkillNameList(lordBuff))
      end
      skills = table.filter(skills, function (s)
        local skill = Fk.skills[s]
        return skill and (#skill.attachedKingdom == 0 or table.contains(skill.attachedKingdom, player.kingdom))
      end)
      if #skills > 0 then
        room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, false)
      end

      room:sendLog{ type = "#RevealGeneral", from = player.id, arg =  "mainGeneral", arg2 = general.name }
      local event_data = {["m"] = general}
      if deputy then
        room:sendLog{ type = "#RevealGeneral", from = player.id, arg =  "deputyGeneral", arg2 = deputy.name }
        event_data["d"] = deputy.name
      end
      room.logic:trigger("fk.GeneralAppeared", player, event_data)
    end
  end,
})

hidden_skill:addEffect(fk.BeforeMaxHpChanged, {
  priority = 0.001,
  mute = true,
  can_trigger = function(self, event, target, player)
    if target == player and not player.dead and
      (player:getMark("__hidden_general") ~= 0 or player:getMark("__hidden_deputy") ~= 0) then
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    if event == fk.BeforeMaxHpChanged then
      return true
    else
      room:handleAddLoseSkills(player, "-"..hidden_skill.name, nil, false, true)
      if Fk.generals[player:getMark("__hidden_general")] then
        player.general = player:getMark("__hidden_general")
      end
      if Fk.generals[player:getMark("__hidden_deputy")] then
        player.deputyGeneral = player:getMark("__hidden_deputy")
      end
      room:setPlayerMark(player, "__hidden_general", 0)
      room:setPlayerMark(player, "__hidden_deputy", 0)
      local general = Fk.generals[player.general]
      local deputy = Fk.generals[player.deputyGeneral]
      player.gender = general.gender
      player.kingdom = general.kingdom
      room:broadcastProperty(player, "gender")
      room:broadcastProperty(player, "general")
      room:broadcastProperty(player, "deputyGeneral")
      room:askToChooseKingdom({player})
      room:broadcastProperty(player, "kingdom")

      if player:getMark("__hidden_record") ~= 0 then
        player.maxHp = player:getMark("__hidden_record").maxHp
        player.hp = player:getMark("__hidden_record").hp
      else
        player.maxHp = player:getGeneralMaxHp()
        player.hp = deputy and math.floor((deputy.hp + general.hp) / 2) or general.hp
      end
      player.shield = math.min(general.shield + (deputy and deputy.shield or 0), 5)
      if player:getMark("__hidden_record") ~= 0 then
        room:setPlayerMark(player, "__hidden_record", 0)
      else
        local changer = Fk.game_modes[room.settings.gameMode]:getAdjustedProperty(player)
        if changer then
          for key, value in pairs(changer) do
            player[key] = value
          end
        end
      end
      room:broadcastProperty(player, "maxHp")
      room:broadcastProperty(player, "hp")
      room:broadcastProperty(player, "shield")

      local lordBuff = player.role == "lord" and player.role_shown == true and #room.players > 4
      local skills = general:getSkillNameList(lordBuff)
      if deputy then
        table.insertTable(skills, deputy:getSkillNameList(lordBuff))
      end
      skills = table.filter(skills, function (s)
        local skill = Fk.skills[s]
        return skill and (#skill.attachedKingdom == 0 or table.contains(skill.attachedKingdom, player.kingdom))
      end)
      if #skills > 0 then
        room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, false)
      end

      room:sendLog{ type = "#RevealGeneral", from = player.id, arg =  "mainGeneral", arg2 = general.name }
      local event_data = {["m"] = general}
      if deputy then
        room:sendLog{ type = "#RevealGeneral", from = player.id, arg =  "deputyGeneral", arg2 = deputy.name }
        event_data["d"] = deputy.name
      end
      room.logic:trigger("fk.GeneralAppeared", player, event_data)
    end
  end,
})

return hidden_skill
