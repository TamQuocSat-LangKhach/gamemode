local rule = fk.CreateSkill {
  name = "#zombie_rule&",
}

Fk:loadTranslationTable{
  ["@zombie_tuizhi"] = "退治",
  ["zombie_tuizhi_success"] = "主公已经集齐8个退治标记！僵尸被退治！",
}

rule:addEffect(fk.RoundStart, {
  priority = 0.001,
  can_refresh = function(self, event, target, player, data)
    return player.role == "lord"
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local count = room:getBanner("RoundCount")
    --第二轮出现两个僵尸
    if count == 2 then
      local loyalist = table.filter(room.alive_players, function(p) return p.role == "loyalist" end)
      local zombie = table.random(loyalist, 2)
      for _, p in ipairs(zombie) do
        room:addPlayerMark(p, "zombie_mustdie", 1)
      end
    elseif count > 2 then
      local haszombie = table.find(room.players, function(p)
        return table.contains({ "rebel", "renegade" }, p.role)
      end)
      local haslivezombie = table.find(room.alive_players, function(p)
        return table.contains({ "rebel", "renegade" }, p.role)
      end)
      if not haszombie then room:gameOver("rebel") end
      if not haslivezombie then room:gameOver("lord+loyalist") end
    end
  end,
})

local function zombify(victim, role, maxHp)
  local room = victim.room
  local gender = victim.gender
  local kingdom = victim.kingdom
  room:changeHero(victim, "zombie", false, true)
  victim.role = role
  victim.maxHp = math.ceil(maxHp / 2)
  room:revivePlayer(victim, true)
  room:broadcastProperty(victim, "role")
  room:broadcastProperty(victim, "maxHp")
  room:setPlayerProperty(victim, "kingdom", kingdom)
  room:setPlayerProperty(victim, "gender", gender)
  room:broadcastPlaySound("./packages/gamemode/audio/zombify-" ..
    (gender == General.Male and "male" or "female"))
end

--僵尸出现
rule:addEffect(fk.TurnStart, {
  priority = 0.001,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("zombie_mustdie") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "zombie_mustdie", 1)
    room:killPlayer{ who = player }
    zombify(player, "rebel", 10)
    player:drawCards(5)
  end,
})

--退治胜利
rule:addEffect(fk.EventPhaseStart, {
  priority = 0.001,
  can_refresh = function(self, event, target, player, data)
    return target == player and player.role == "lord" and player.phase == Player.Start
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@zombie_tuizhi", 1)
    if player:getMark("@zombie_tuizhi") >= 8 then
      room:sendLog { type = "zombie_tuizhi_success" }
      room:gameOver("lord+loyalist")
    end
  end,
})

rule:addEffect(fk.GameOverJudge, {
  priority = 0.001,
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setTag("SkipGameRule", true)
  end,
})

rule:addEffect(fk.BuryVictim, {
  priority = 0.001,
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    --下一名忠臣玩家成为主公
    if player.role == "lord" then
      local tmp = player:getNextAlive()
      local nextp = tmp
      repeat
        if nextp.role == "loyalist" then
          room:setPlayerMark(nextp, "@zombie_tuizhi", math.max(player:getMark("@zombie_tuizhi") - 1, 0))
          nextp.role = "lord"
          room:broadcastProperty(nextp, "role")
          room:changeMaxHp(nextp, 1)
          room:recover{
            who = nextp,
            num = 1,
            skillName = rule.name,
          }
          break
        end
        nextp = nextp:getNextAlive()
      until nextp == tmp
    end

    --击杀奖惩
    if data.killer then
      if data.killer.dead then return end
      if player.role == "rebel" or player.role == "renegade" then
        data.killer:drawCards(3, "kill")
        if data.killer:isWounded() then
          room:recover({
            who = data.killer,
            num = data.killer:getLostHp(),
            skillName = self.name
          })
        end
      elseif table.contains({ "lord", "loyalist" }, player.role) then
        if table.contains({ "lord", "loyalist" }, data.killer.role) then
          data.killer:throwAllCards("he")
        end
      end
    end
  end,
})

rule:addEffect(fk.Deathed, {
  priority = 0.001,
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    --僵尸感染
    if data.killer then
      if data.killer.dead then return end
      if table.contains({ "lord", "loyalist" }, player.role) then
        if data.killer.role == "renegade" then
          data.killer.role = "rebel"
          room:broadcastProperty(data.killer, "role")
        end
        if table.contains({ "rebel", "renegade" }, data.killer.role) then
          local current = room.logic:getCurrentEvent()
          local last_event = current
          if room.current == player then
            last_event = current:findParent(GameEvent.Turn, true)
          else
            last_event = current
            if last_event.parent then
              repeat
                if table.contains({GameEvent.Round, GameEvent.Turn, GameEvent.Phase}, last_event.parent.event) then break end
                last_event = last_event.parent
              until (not last_event.parent)
            end
          end
          last_event:addExitFunc(function()
            zombify(player, "renegade", data.killer.maxHp)
          end)
        end
      end
    end

    --胜利判定
    local winner = Fk.game_modes[room.settings.gameMode]:getWinner(player)
    if winner then
      room:gameOver(winner)
    end
  end,
})

return rule
