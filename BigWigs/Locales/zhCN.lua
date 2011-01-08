local L = LibStub("AceLocale-3.0"):NewLocale("Big Wigs", "zhCN")

if not L then return end

-- Core.lua
L["%s has been defeated"] = "%s被击败了！"

L.bosskill = "首领死亡"
L.bosskill_desc = "首领被击杀时显示提示信息。"
L.berserk = "狂暴"
L.berserk_desc = "当首领进入狂暴状态时发出警报。"

L.already_registered = "|cffff0000警告：|r |cff00ff00%s|r（|cffffff00%s|r）在 Big Wigs 中已经存在模块，但存在模块仍试图重新注册。可能由于更新失败的原因，通常表示您有两份模块拷贝在您插件的文件夹中。建议删除所有 Big Wigs 文件夹并重新安装。"

-- Loader / Options.lua
L["You are running an official release of Big Wigs %s (revision %d)"] = "你所使用的 Big Wigs %s 为官方正式版（修订号%d）"
L["You are running an ALPHA RELEASE of Big Wigs %s (revision %d)"] = "你所使用的 Big Wigs %s 为“α测试版”（修订号%d）"
L["You are running a source checkout of Big Wigs %s directly from the repository."] = "你所使用的 Big Wigs %s 为从源直接检出的。"
L["There is a new release of Big Wigs available. You can visit curse.com, wowinterface.com, wowace.com or use the Curse Updater to get the new release."] = "有新的 Big Wigs 正式版可用。你可以访问 Curse.com，wowinterface.com，wowace.com 或使用 Curse 更新器来更新到新的正式版。"

L.tooltipHint = "|cffeda55f点击|r图标重置所有运行中的模块。|cffeda55fAlt-点击|r可以禁用所有首领模块。"
L["Active boss modules:"] = "激活首领模块："
L["All running modules have been reset."] = "所有运行中的模块都已重置。"
L["All running modules have been disabled."] = "所有运行中的模块都已禁用。"

L["There are people in your group with older versions or without Big Wigs. You can get more details with /bwv."] = "在你队伍里使用旧版本或没有使用 Big Wigs。你可以用 /bwv 获得详细内容。"
L["Up to date:"] = "已更新："
L["Out of date:"] = "过期："
L["No Big Wigs 3.x:"] = "没有 Big Wigs 3.x："

-- Options.lua
L["Big Wigs Encounters"] = "Big Wigs 战斗"
L["Customize ..."] = "自定义…"
L["Profiles"] = "配置文件"
L.introduction = "欢迎使用 Big Wigs 戏弄各个首领。请系好安全带，吃吃花生并享受这次旅行。它不会吃了你的孩子，但会协助你的团队与新的首领进行战斗就如同享受饕餮大餐一样。"
L["Configure ..."] = "配置…"
L.configureDesc = "关闭插件选项窗口并配置显示项，如计时条、信息。\n\n如果需要自定义更多幕后时间，你可以展开左侧 Big Wigs 找到“自定义…”小项进行设置。"
L["Sound"] = "音效"
L.soundDesc = "信息出现时伴随着音效。有些人更容易在听到何种音效后发现何种警报，而不是阅读的实际信息。\n\n|cffff4411即使被关闭，默认的团队警报音效可能会随其它玩家的团队警报出现，那些声音与这里用的不同。|r"
L["Show Blizzard warnings"] = "暴雪警报"
L.blizzardDesc = "暴雪提供了他们自己的警报信息。我们认为，这些信息太长和复杂。我们试着简化这些消息而不打扰游戏的乐趣，并不需要你做什么。\n\n|cffff4411当关闭时，暴雪警报将不会再屏幕中间显示，但是仍将显示在聊天框体内。|r"
L["Show addon warnings"] = "显示插件警报"
L.addonwarningDesc = "Big Wigs 与其它首领战斗插件可以使用团队警报频道广播信息。这些消息通常包含三星号（***），Big Wigs 以此查找和判断是否屏蔽此消息。\n\n|cffff4411开启此选项将造成大量的垃圾信息所以并不推荐。|r"
L["Flash and shake"] = "闪屏/震动"
L["Flash"] = "闪屏"
L["Shake"] = "震动"
L.fnsDesc = "某些重要的技能需要你相当的注意力。当这些技能出现时 Big Wigs 可以闪烁和震动屏幕。\n\n|cffff4411如果开启了暴雪的姓名板选项，屏幕只会闪烁而震动功能将不会工作。|r"
L["Raid icons"] = "团队标记"
L.raidiconDesc = "团队中有些首领模块使用团队标记来为某些中了特定技能的队员打上标记。例如类似“炸弹”类或心灵控制的技能。如果你关闭此功能，你将不会给队员打标记。\n\n|cffff4411只有团队领袖或被提升为助理时才可以这么做！|r"
L["Whisper warnings"] = "密语警报"
L.whisperDesc = "发送给其它队员的首领战斗技能密语警报功能，例如类似“炸弹”类的技能。\n\n|cffff4411只有团队领袖或被提升为助理时才可以这么做！|r"
L["Broadcast"] = "广播"
L.broadcastDesc = "Big Wigs 广播所有信息到团队警报频道。\n\n|cffff4411在团队时只有获得权限时才可用，小队时不受限制。|r"
L["Raid channel"] = "团队频道"
L["Use the raid channel instead of raid warning for broadcasting messages."] = "使用团队频道而不是团队警报广播信息。"
L["Minimap icon"] = "迷你地图图标"
L["Toggle show/hide of the minimap icon."] = "打开或关闭迷你地图图标。"
L["Configure"] = "配置"
L["Test"] = "测试"
L["Reset positions"] = "重置位置"
L["Options for %s."] = "%s选项。"
L["Colors"] = "颜色"
L["Select encounter"] = "选择战斗"

L["BAR"] = "计时条"
L["MESSAGE"] = "信息"
L["ICON"] = "标记"
L["WHISPER"] = "密语"
L["SAY"] = "说"
L["FLASHSHAKE"] = "闪屏/震动"
L["PING"] = "点击地图"
L["EMPHASIZE"] = "醒目"
L["MESSAGE_desc"] = "大多数遇到技能出现一个或多个信息时 Big Wigs 将在屏幕上显示。如果禁用此选项，没有信息附加选项，如果有，将会被显示。"
L["BAR_desc"] = "当遇到某些技能时计时条将会适当显示。如果这个功能伴随着你想要隐藏的计时条，禁用此选项。"
L["FLASHSHAKE_desc"] = "一些技能可能比其它更加重要。如果想这些技能即将出现或发动时闪屏和震动，选中此选项。"
L["ICON_desc"] = "Big Wigs 可以根据技能用图标标记人物。这将使他们更容易被辨认。"
L["WHISPER_desc"] = "当一些技能足够重要时 Big Wigs 将发送密语给受到影响的人。"
L["SAY_desc"] = "聊天泡泡容易辨认。Big Wigs 将使用说的信息方式通知给附近的人告诉他们你中了什么技能。"
L["PING_desc"] = "有时所在位置也很重要，Big Wigs 将点击迷你地图通知大家你位于何处。"
L["EMPHASIZE_desc"] = "启用这些将特别醒目所相关遇到技能的任何信息或计时条。信息将被放大，计时条将会闪烁并有不同的颜色，技能即将出现时会使用计时音效，基本上你会发现它。"
L["Advanced options"] = "高级选项"
L["<< Back"] = "<< 返回"

L["About"] = "关于"
L["Main Developers"] = "主要开发者"
L["Developers"] = "开发者"
L["Maintainers"] = "维护"
L["License"] = "许可"
L["Website"] = "网站"
L["Contact"] = "联系方式"
L["See license.txt in the main Big Wigs folder."] = "查看 license.txt 位于 Big Wigs 主文件夹。"
L["irc.freenode.net in the #wowace channel"] = "#wowace 频道位于 irc.freenode.net"
L["Thanks to the following for all their help in various fields of development"] = "感谢他们在各个领域的开发与帮助"
