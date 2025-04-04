local jiange__weizhu = fk.CreateSkill {
  name = "jiange__weizhu"
}

Fk:loadTranslationTable{
  ['jiange__weizhu'] = '卫主',
  ['#jiange__weizhu-invoke'] = '卫主：你可以弃置一张手牌，防止 %dest 受到的伤害',
  [':jiange__weizhu'] = '当友方角色受到伤害时，你可以弃置一张手牌，防止此伤害。',
}

jiange__weizhu:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, _, target, player, data)
    return player:hasSkill(jiange__weizhu.name) and table.contains(U.GetFriends(player.room, player), target) and not player:isKongcheng()
  end,
  on_cost  = function(self, event, target, player, data)
    local card = player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = jiange__weizhu.name,
      cancelable = true,
      prompt = "#jiange__weizhu-invoke::"..target.id,
      skip = true
    })
    if #card > 0 then
      event:setCostData(self, card)
      return true
    end
  end,
  on_use  = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:throwCard(event:getCostData(self), jiange__weizhu.name, player, player)
    return true
  end,
})

return jiange__weizhu
