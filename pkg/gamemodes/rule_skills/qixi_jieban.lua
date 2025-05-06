local jieban = fk.CreateSkill {
  name = "qixi_jieban&",
}

Fk:loadTranslationTable{
  ["qixi_jieban&"] = "结伴",
  [":qixi_jieban&"] = "出牌阶段限一次，若你没有伴侣，你可以将一张" ..
  "【桃】或者防具牌交给一名未结伴的异性角色并将其设为追求目标；" ..
  "然后若其的追求目标是你，双方移除追求目标并结为伴侣。" ..
  "<br/>伴侣确定后就无法更改，即使死亡也无法将二人分开。",

  ["#qixi_jieban"] = "结伴：将一张【桃】或者防具牌交给一名未结伴的异性角色，追求该角色",
}

local couples = {
  -- wei
  caopi = { "zhenji", "guozhao", "duanqiaoxiao", "xuelingyun", "tianshangyi", "moqiongshu", "liujinliupei" },
  caorui = "guohuanghou",
  simayi = {"zhangchunhua", "bailingyun"},
  simazhao = "wangyuanji",
  simashi = { "xiahouhui", "yanghuiyu" },
  simayan = { "yangyan", "yangzhi", "zuofen" },
  pangde = "licaiwei",
  zhaoang = "wangyi",
  jiachong = { "liwan", "guohuaij" },
  wanghun = "zhongyan",
  duyu = "xuangongzhu",
  zhongyao = "zhangchangpu",
  heyan = "caojinyu",
  pangshanmin = "zhugeruoxue",
  kuaiqi = "zhugemengxue",
  caomao = "bianyue",
  caoyu = "zhangqiying",
  xiahoumao = "qinghegongzhu",

  -- shu
  liubei = { "ganfuren", "mifuren", "sunshangxiang", "zhangchu", "wuxian", "ganfurenmifuren" },
  zhangfei = "xiahoushi",
  guanyu = "hujinding",
  menghuo = "zhurong",
  liushan = { "xingcai", "zhangjinyun" },
  zhugeliang = "huangyueying",
  wolong = "huangyueying",
  huangzhong = "liucheng",
  machao = "yangwan",
  zhaoyun = {"mayunlu", "zhouyi", "fanyufeng"}, -- 绷
  guansuo = { "baosanniang", "wangtao", "wangyues", "huaman" },
  liuliG = "malingli",
  jiangwei = {"liutan", "wenyuan"},

  -- wu
  sunquan = { "bulianshi", "yuanji", "panshu", "xielingyu", "zhaoyanw", "xuxin" },
  zhouyu = "xiaoqiao",
  sunce = "daqiao",
  sunjian = { "wuguotai", "wuke" },
  sunhao = { "tengfanglan", "zhangxuan", "zhangyao" },  -- 太哈人了
  luxun = "sunru",
  sundeng = { "ruiji", "zhoufei" },
  zhangfen = "sunlingluan",
  tengyin = "tenggongzhu",
  sunyi = "xushi",
  quancong = "sunluban",
  sunliang = "quanhuijie",
  sunxiu = "zhupeilan",
  lukang = "zhanghuai",

  -- qun
  lvbu = { "diaochan", "yanfuren", "caoyuan" },
  dongzhuo = "diaochan",  -- ???
  liuxie = { "fuhuanghou", "caojie", "caoxiancaohua", "caoxian", "caohua", "dongguiren" },
  liubiao = "caifuren",
  liuhong = { "hetaihou", "wangrong", "songhuanghou" },
  liubian = "tangji",
  zhangji = "zoushi",
  yuanshao = "liufuren",
  yuanshu = {"fengfangnv", "dongwan"},
  niufu = "dongxie",
  qinyilu = "dufuren",

  -- misc
  blank_shibing = "blank_nvshibing",
  zhangjiao = "huangjinleishi",
  liuyan = "lushi",
  lvbuwei = "zhaoji",
}

---@param from Player
---@param to Player
local function canPayCourtTo(from, to)
  if from:getMark("qixi_couple") ~= 0 then return false end
  if to:getMark("qixi_couple") ~= 0 then return false end
  if from:getMark("@!qixi_female") == to:getMark("@!qixi_female") then return false end
  return true
end

---@param from ServerPlayer
---@param to ServerPlayer
local function addCoupleSkill(from, to)
  local room = from.room
  local kingdom = from.gender == General.Male and from.kingdom or to.kingdom
  local kingdom_skill_map = {
    ["wei"] = "qixi_sheshen",
    ["shu"] = "qixi_gongdou",
    ["wu"] = "qixi_lianzhi",
    ["qun"] = "qixi_qibie",
  }
  local skill = kingdom_skill_map[kingdom]
  if table.contains({"wei", "shu", "wu", "qun"}, kingdom) then
    room:handleAddLoseSkills(from, skill .. "|-qixi_jieban&|-" .. from.tag["qixi_rand_skill"])
    room:handleAddLoseSkills(to, skill .. "|-qixi_jieban&|-" .. to.tag["qixi_rand_skill"])
  else
    room:handleAddLoseSkills(from, "-qixi_jieban&")
    room:handleAddLoseSkills(to, "-qixi_jieban&")
  end
end

---@param from ServerPlayer
---@param to ServerPlayer
local function isCoupleGeneral(from, to)
  local m, f = from, to
  if from.gender == General.Female then
    m, f = to, from
  end
  local g1 = Fk.generals[m.general].trueName
  local g2 = Fk.generals[f.general].trueName
  if g1:startsWith("god") then g1 = g1:sub(4) end
  if g2:startsWith("god") then g2 = g2:sub(4) end
  if g1 == "caocao" and f.general ~= "sp__xiahoushi" then return true end
  local t = couples[g1] or ""
  return t == g2 or (type(t) == "table" and table.contains(t, g2))
end

jieban:addEffect("active", {
  anim_type = "support",
  prompt = "#qixi_jieban",
  card_num = 1,
  target_num = 1,
  can_use = function (self, player)
    if player:usedSkillTimes(jieban.name, Player.HistoryPhase) > 0 then return false end
    if player:getMark("qixi_couple") ~= 0 then return false end
    return true
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected ~= 0 then return end
    local c = Fk:getCardById(to_select)
    return c.trueName == "peach" or c.sub_type == Card.SubtypeArmor
  end,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and canPayCourtTo(player, to_select) and #cards == 1
  end,
  on_use = function (self, room, effect)
    local from = effect.from
    local to = effect.tos[1]
    room:obtainCard(to, effect.cards, true, fk.ReasonGive)

    --- set court mark
    ---@param f ServerPlayer
    ---@param t ServerPlayer
    ---@param clear? boolean
    local function setCourt(f, t, clear)
      if clear then
        for _, p in ipairs{f, t} do
          room:setPlayerMark(p, "qixi_pay_court", 0)
          room:setPlayerMark(p, "@qixi_pay_court", 0)
        end
      else
        room:setPlayerMark(f, "qixi_pay_court", t.id)
        room:setPlayerMark(f, "@qixi_pay_court", t.general)
      end
    end

    setCourt(from, to)
    if to:getMark("qixi_pay_court") == from.id then
      setCourt(from, to, true)

      room:setPlayerMark(from, "qixi_couple", to.id)
      room:setPlayerMark(to, "qixi_couple", from.id)
      addCoupleSkill(from, to)
      local couple = isCoupleGeneral(from, to)
      if couple then
        room:setPlayerMark(from, to.gender == General.Female and "@qixi_couple_pink" or "@qixi_couple_blue", to.general)
        room:setPlayerMark(to, from.gender == General.Female and "@qixi_couple_pink" or "@qixi_couple_blue", from.general)
      else
        room:setPlayerMark(from, "@qixi_couple", to.general)
        room:setPlayerMark(to, "@qixi_couple", from.general)
      end
    end
  end,
})

return jieban
