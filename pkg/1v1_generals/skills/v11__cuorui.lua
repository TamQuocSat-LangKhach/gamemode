local v11__cuorui = fk.CreateSkill {
  name = "v11__cuorui",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["v11__cuorui"] = "挫锐",
  [":v11__cuorui"] = "锁定技，当你登场时，你摸X-2张牌（X为你的备用武将数）；你跳过登场后的第一个判定阶段。",
  ["$v11__cuorui1"] = "区区乌合之众，如何困得住我？！",
  ["$v11__cuorui2"] = "今日就让你见识见识老牛的厉害！",
}

v11__cuorui:addEffect("fk.Debut", {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(v11__cuorui.name) then
      return #player.room:getBanner(player.role == "lord" and "@&firstGenerals" or "@&secondGenerals") - 2 > 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(#room:getBanner(player.role == "lord" and "@&firstGenerals" or "@&secondGenerals") - 2, v11__cuorui.name)
  end,
})

v11__cuorui:addEffect(fk.EventPhaseChanging, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(v11__cuorui.name) then
      return data.to == Player.Judge and player:getMark("_v11__cuorui") == 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "_v11__cuorui", 1)
    return true
  end,
})

return v11__cuorui
