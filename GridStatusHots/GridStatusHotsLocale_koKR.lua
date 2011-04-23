﻿--[[--------------------------------------------------------------------
	GridStatusHotsLocale_koKR.lua
	Korean (한국어) localization for GridStatusHots.
----------------------------------------------------------------------]]

if GetLocale() ~= "koKR" then return end
local _, GridStatusHots = ...
GridStatusHots.L = {
	["My HoTs"] = "나의 지속치유",
	["Hots: Hot Count"] = "지속치유: 지속치유 갯수",
	["Hots: My Earth Shield"] = "지속치유: 나의 대지의 보호막",
	["Hots: My Gift of the Naaru"] = "지속치유: 나의 나루의 선물",
	["Hots: My Renew"] = "지속치유 : 나의 소생",
	["Hots: My Holy Word: Aspire"] = "지속치유: 나의 신의 권능: 열망",
	["Hots: My Rejuvenation"] = "지속치유 : 나의 회복",
	["Hots: My Regrowth"] = "지속치유 : 나의 재생",
	["Hots: My Lifebloom"] = "지속치유: 나의 피어나는 생명",
	["Hots: My Lifebloom Stack Colored"] = "지속치유: 나의 피생 중첩 색상",
	["Hots: My Wild Growth"] = "지속치유: 나의 급속 성장",
	["Hots: My Riptide"] = "지속치유: 나의 성난 해일",
	["Hots: My Earthliving"] = "지속치유: 나의 대지의 생명",
	["Hots: My Prayer of Mending"] = "지속치유: 나의 회복의 기원",
	["Hots: My Prayer of Mending - duration colored"] = "지속치유: 나의 회복의 기원 - 지속시간 색상",
	["Hots: Power Word: Shield"] = "지속치유: 신의 권능: 보호막",
	["Hots: Weakened Soul"] = "지속치유: 약화된 영혼",
	["Hots: My Beacon of Light"] = "지속치유: 나의 빛의 봉화",
	["Hots: My Grace Stack"] = "지속치유: 나의 은총 중첩",
	["Hots: My Grace Duration + Stack"] = "지속치유: 나의 은총 지속시간 + 중첩",
	["Color when player has two charges of PoM."] = "플레이어에 회복의 기원 2중첩일 때 색상입니다.",
	["Color when player has three charges of PoM."] = "플레이어에 회복의 기원 3중첩일 때 색상입니다.",
	["Color when player has four charges of PoM."] = "플레이어에 회복의 기원 4중첩일 때 색상입니다.",
	["Color when player has five charges of PoM."] = "플레이어에 회복의 기원 5중첩일 때 색상입니다.",
	["Color when player has six charges of PoM."] = "플레이어에 회복의 기원 6중첩일 때 색상입니다.",
	["Color when player has 2 charges of Earth Shield."] = "플레이어에 대지의 보호막 2이하일 때 색상입니다.",
	["Color when player has 3 charges of Earth Shield."] = "플레이어에 대지의 보호막 3일때 색상입니다.",
	["Color when player has 4 charges of Earth Shield."] = "플레이어에 대지의 보호막 4일때 색상입니다.",
	["Color when player has 5 or more charges of Earth Shield."] = "플레이어에 대지 보호막 5이상일 때 색상입니다.",
	["Color when player has two charges of grace."] = "플레이어에 은총 2중첩일 때 색상입니다.",
	["Color when player has three charges of grace."] = "플레이어에 은총 3중첩일 때 색상입니다.",
	["Threshold to activate color 2"] = "색상 2을 사용할 수치",
	["Threshold to activate color 3"] = "색상 3을 사용할 수치",
	["Color 2"] = "색상 2",
	["Color 3"] = "색상 3",
	["Color 4"] = "색상 4",
	["Color 5"] = "색상 5",
	["Color 6"] = "색상 6",
	["Refresh frequency"] = "재확인 빈도",
	["Seconds between status refreshes"] = "상태 재확인 지속시간(초)을 설정합니다.",
	["Count Lifebloom as 1 HoT per stack"] = "피생 중첩을 1개의 지속치유로 표시",
	["Check, if you want each stack of Lifebloom to count as 1 HoT"]= "당신이 피어나는 생명의 각 중첩 지속치유를 1개로 보여주길 원한다면 체크합니다.",
	["Show HoT-Counter"] = "HoT-갯수 표시",
	["Check, if you want to see the total of HoTs behind the countdown of your HoT(i.e. 13-5)"]= "당신의 지속치유 갯수를 전부 보여주길 원한다면 체크합니다. (예. 13-5)",
	["Combine Timers"] = "결합 타이머",
	["Check, if you want to see the Weakened Soul Timer behind the Pw: Shield Timer(i.e. 13-5)"]= "당신의 신의 권능: 보호막의 약화된 영혼 타이머를 보여주길 원한다면 체크합니다. (예. 13-5)",
	["Show decimals"] = "소수 표시",
	["Check, if you want to see one decimal place for your Lifebloom(i.e. 7.1)"] = "당신의 피어나는 생명의 지속시간을 소수점으로 보여주실 원한다면 체크합니다. (예. 7.1)",
	["Only mine"] = "나의 것만",
	["Only show my PoM"] = "자신의 회복의 기원만 표시",
}
