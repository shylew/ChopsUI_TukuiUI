﻿local L = BigWigs:NewBossLocale("Al'Akir", "zhTW")
if L then
	L.phase = "階段轉換"
	L.phase_desc = "當進入不同階段時發出警報。"

	L.feedback_message = "%dx 回饋！"
end

local L = BigWigs:NewBossLocale("Conclave of Wind", "zhTW")
if L then
	L.gather_strength = "%正在聚集力量！"

	L.full_power = "滿能量"
	L.full_power_desc = "當首領獲得滿能量並開始施放特殊技能時發出警報。"
	L.gather_strength_emote = "%s開始從剩下的風之王那裡取得力量!"

	L.wind_chill = ">你<獲得%s層風寒冷卻！"
end
