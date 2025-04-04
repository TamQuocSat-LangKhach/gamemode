local jiange__keding = fk.CreateSkill {
  name = "jiange__keding"
}

Fk:loadTranslationTable{
  ['jiange__keding'] = '克定',
  ['jiange__keding_active'] = '克定',
  ['#jiange__keding-choose'] = '克定：你可以弃置任意张手牌，为此%arg增加等量的目标',
  [':jiange__keding'] = '当你使用【杀】或普通锦囊牌指定唯一目标时，你可以弃置任意张手牌，为此牌增加等量的目标。',
}

jiange__keding:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and #TargetGroup:getRealTargets(data.tos) == 1 and
      (data.card.trueName == "slash" or data.card:isCommonTrick()) and
      #player.room:getUseExtraTargets(data) > 0 and
      not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getUseExtraTargets(data)
    local _, dat = room:askToUseActiveSkill(player, {
      skill_name = "jiange__keding_active",
      prompt = "#jiange__keding-choose:::"..data.card:toLogString(),
      cancelable = true,
      extra_data = {exclusive_targets = targets},
      no_indicate = false
    })
    if dat then
      event:setCostData(skill, dat)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = event:getCostData(skill).targets
    room:sortPlayersByAction(tos)
    for _, id in ipairs(tos) do
      table.insert(data.tos, {id})
    end
    room:throwCard(event:getCostData(skill).cards, jiange__keding.name, player, player)
  end,
})

return jiange__keding
