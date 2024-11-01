


local role_mode = fk.CreateGameMode{
  name = "aab_role_mode", -- just to let it at the top of list
  minPlayer = 8,
  maxPlayer = 8,
  main_mode = "role_mode",
  logic = function()
    local l = GameLogic:subclass("aab_role_mode_logic")
    function l:run()
      self.room.settings.enableDeputy = false
      GameLogic.run(self)
    end

    function l:chooseGenerals()
      local room = self.room---@type Room
      local generalNum = room.settings.generalNum
      local lord = room:getLord()
      if not lord then
        local temp = room.players[1]
        temp.role = "lord"
        lord =  temp
      end
      room.current = lord

      local lord_general_num = 3
      local lord_generals = table.connect(room:findGenerals(function(g)
        return table.contains(Fk.lords, g)
      end, lord_general_num), room:getNGenerals(generalNum))
      if #lord_generals < generalNum then
        room:sendLog{ type = "#NoGeneralDraw", toast = true }
        room:gameOver("")
      end

      local lord_general = room:askForGeneral(lord, lord_generals, 1)---@type string
      room:returnToGeneralPile(lord_generals)
      room:findGeneral(lord_general)

      room:prepareGeneral(lord, lord_general, "", true)
      room:askForChooseKingdom({lord})
      room:broadcastProperty(lord, "kingdom")


      local lord_skills = Fk.generals[lord.general]:getSkillNameList(true)
      for _, sname in ipairs(lord_skills) do
        local skill = Fk.skills[sname]
        if #skill.attachedKingdom == 0 or table.contains(skill.attachedKingdom, lord.kingdom) then
          room:doBroadcastNotify("AddSkill", json.encode{ lord.id, sname })
        end
      end
  
      local nonlord = room:getOtherPlayers(lord, true)
      local generals = table.random(room.general_pile, #nonlord * generalNum)
      if #generals < #nonlord * generalNum then
        room:sendLog{ type = "#NoGeneralDraw", toast = true }
        room:gameOver("")
      end

      local req = Request:new(nonlord, "AskForGeneral")
      for i, p in ipairs(nonlord) do
        local arg = table.slice(generals, (i - 1) * generalNum + 1, i * generalNum + 1)
        req:setData(p, { arg, 1 })
        req:setDefaultReply(p, table.random(arg, 1))
      end

      local selected = {}
      for _, p in ipairs(nonlord) do
        local result = req:getResult(p)
        local general = result[1]
        room:findGeneral(general)
        room:prepareGeneral(p, general, "")
      end

      room:askForChooseKingdom(nonlord)

    end

    return l
  end,
  surrender_func = Fk.game_modes["aaa_role_mode"].surrenderFunc
}

Fk:loadTranslationTable{
  ["aab_role_mode"] = "单将军八",
  [":aab_role_mode"] = "就是禁用了副将且人数必须为8的身份模式。这个模式创立的目的是便于统计数据。",
  ["#aab_role_rule"] = "单将军八规则",
}

return role_mode
