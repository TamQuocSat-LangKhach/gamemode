-- SPDX-License-Identifier: GPL-3.0-or-later
local extension = Package:new("gamemode_generals")
extension.extensionName = "gamemode"

extension:loadSkillSkelsByPath("./packages/gamemode/pkg/gamemode_generals/skills")

Fk:loadTranslationTable{
  ["gamemode_generals"] = "模式专属武将",
  ["v22"] = "2v2",
  ["v11"] = "1v1",
  ["vd"] = "忠胆",
  ["var"] = "应变",
}

local zombie = General:new(extension, "zombie", "god", 1)
zombie.hidden = true
zombie:addSkills { "paoxiao", "wansha", "zombie_xunmeng", "zombie_zaibian", "zombie_ganran" }
Fk:loadTranslationTable{
  ["zombie"] = "僵尸",
}

local hiddenone = General:new(extension, "hiddenone", "jin", 1)
hiddenone.hidden = true
hiddenone.fixMaxHp = 1
hiddenone:addSkills { "hidden_skill&" }
Fk:loadTranslationTable{
  ["hiddenone"] = "隐匿者",
  ["#hiddenone"] = "隐介藏形",
  ["illustrator:hiddenone"] = "佚名",  --九鼎的隐匿牌上真就写着illustration：佚名
}

General:new(extension, "v22__leitong", "shu", 4):addSkills { "v22__kuiji" }
Fk:loadTranslationTable{
  ["v22__leitong"] = "雷铜",
  ["#v22__leitong"] = "石铠之鼋",
  ["designer:v22__leitong"] = "梦魇狂朝",
  ["illustrator:v22__leitong"] = "M云涯",

  ["~v22__leitong"] = "翼德救我……",
}

General:new(extension, "v22__wulan", "shu", 4):addSkills { "v22__cuoruiw" }
Fk:loadTranslationTable{
  ["v22__wulan"] = "吴兰",
  ["#v22__wulan"] = "剑齿之鼍",
  ["designer:v22__wulan"] = "梦魇狂朝",
  ["illustrator:v22__wulan"] = "alien",

  ["v22__cuoruiw"] = "挫锐",
  [":v22__cuoruiw"] = "出牌阶段开始时，你可以弃置一名友方角色区域内的一张牌。若如此做，你选择一项：1.弃置敌方角色装备区内至多两张与此牌颜色相同的牌；"..
  "2.展示敌方角色共计两张手牌，然后获得其中与此牌颜色相同的牌。",
  ["~v22__wulan"] = "蛮狗，尔敢杀我！",
}

General:new(extension, "vd__cuiyan", "wei", 3):addSkills { "yawang", "xunzhi" }
Fk:loadTranslationTable{
  ["vd__cuiyan"] = "崔琰",
  ["#vd__cuiyan"] = "伯夷之风",
  ["designer:vd__cuiyan"] = "凌天翼",
  ["illustrator:vd__cuiyan"] = "F.源",

  ["~vd__cuiyan"] = "尔等，皆是欺世盗名之辈！",
}

General:new(extension, "vd__huangfusong", "qun", 4):addSkills { "vd__fenyue" }
Fk:loadTranslationTable{
  ["vd__huangfusong"] = "皇甫嵩",
  ["#vd__huangfusong"] = "志定雪霜",
  ["designer:vd__huangfusong"] = "千幻",
  ["illustrator:vd__huangfusong"] = "秋呆呆",

  ["~vd__huangfusong"] = "",
}

General:new(extension, "var__yangyan", "jin", 3, 3, General.Female):addSkills { "nos__xuanbei", "xianwan" }
Fk:loadTranslationTable{
  ["var__yangyan"] = "杨艳",
  ["#var__yangyan"] = "武元皇后",
  ["illustrator:var__yangyan"] = "张艺骞",

  ["$xianwan_var__yangyan1"] = "姿容娴婉，服饰华光。",
  ["$xianwan_var__yangyan2"] = "有美一人，清扬婉兮。",
  ["~var__yangyan"] = "后承前训，奉述遗芳……",
}

General:new(extension, "var__yangzhi", "jin", 3, 3, General.Female):addSkills { "nos__wanyi", "maihuo" }
Fk:loadTranslationTable{
  ["var__yangzhi"] = "杨芷",
  ["#var__yangzhi"] = "武悼皇后",
  ["illustrator:var__yangzhi"] = "张艺骞",

  ["$maihuo_var__yangzhi1"] = "至亲约束不严，祸根深埋。",
  ["$maihuo_var__yangzhi2"] = "闻祸端而不备，可亡矣。",
  ["~var__yangzhi"] = "姊妹继宠，福极灾生……",
}

return extension
