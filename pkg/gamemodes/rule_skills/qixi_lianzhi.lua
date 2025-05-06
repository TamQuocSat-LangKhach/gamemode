local lianzhi = fk.CreateSkill {
  name = "qixi_lianzhi",
}

Fk:loadTranslationTable{
  ["qixi_lianzhi"] = "连枝",
  [":qixi_lianzhi"] = "伴侣技，当你使用装备牌时，可以令伴侣摸一张牌。",

  ["#qixi_lianzhi-invoke"] = "连枝：是否令伴侣 %dest 摸一张牌？",
}

lianzhi:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lianzhi.name) and data.card.type == Card.TypeEquip and
      player.room:getPlayerById(player:getMark("qixi_couple")) ~= nil and
      not player.room:getPlayerById(player:getMark("qixi_couple")).dead
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local couple = room:getPlayerById(player:getMark("qixi_couple"))
    if room:askToSkillInvoke(player, {
      skill_name = lianzhi.name,
      prompt = "#qixi_lianzhi-invoke::"..couple.id,
    }) then
      event:setCostData(self, {tos = {couple}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:getPlayerById(player:getMark("qixi_couple")):drawCards(1, lianzhi.name)
  end,
})

return lianzhi
