--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ultraxion", 824, 331)
if not mod then return end
mod:RegisterEnableMob(55294, 56667) -- Ultraxion, Thrall

--------------------------------------------------------------------------------
-- Locales
--

local hourCounter = 1
local lightTargets = mod:NewTargetList()

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "Now is the hour of twilight!"

	L.warmup = "Warmup"
	L.warmup_desc = "Warmup timer"
	L.warmup_trigger = "I am the beginning of the end...the shadow which blots out the sun"

	L.crystal = "Buff Crystals"
	L.crystal_desc = "Timers for the various buff crystals the NPCs summon."
	L.crystal_icon = "inv_misc_head_dragon_01"
	L.crystal_red = "Red Crystal"
	L.crystal_green = "Green Crystal"
	L.crystal_green_icon = "inv_misc_head_dragon_green"
	L.crystal_blue = "Blue Crystal"
	L.crystal_blue_icon = "inv_misc_head_dragon_blue"
	L.crystal_red_icon = "inv_misc_head_dragon_bronze"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"warmup", {106371, "FLASHSHAKE"}, {105925, "FLASHSHAKE"}, "crystal", "berserk", "bosskill",
	}, {
		warmup = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "HourofTwilight", 106371, 109415, 109416, 109417)
	self:Log("SPELL_AURA_APPLIED", "FadingLight", 105925, 109075, 110068, 110069, 110078, 110079, 110070, 110080)
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	self:Yell("Warmup", L["warmup_trigger"])
	self:Emote("Gift", L["crystal_icon"])
	self:Emote("Dreams", L["crystal_green_icon"])
	self:Emote("Magic", L["crystal_blue_icon"])
	self:Emote("Loop", L["crystal_red_icon"])

	self:Death("Win", 55294)
end

function mod:Warmup()
	self:Bar("warmup", self.displayName, 30, "achievment_boss_ultraxion")
end

function mod:OnEngage(diff)
	self:Berserk(360)
	self:Bar(106371, GetSpellInfo(106371), 45, 106371) -- Hour of Twilight
	self:Bar("crystal", L["crystal_red"], 80, L["crystal_icon"])
	hourCounter = 1
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Gift()
	self:Bar("crystal", L["crystal_green"], 75, L["crystal_green_icon"])
	self:Message("crystal", L["crystal_red"], "Positive", L["crystal_icon"], "Info")
end

function mod:Dreams()
	self:Bar("crystal", L["crystal_blue"], 60, L["crystal_blue_icon"])
	self:Message("crystal", L["crystal_green"], "Positive", L["crystal_green_icon"], "Info")
end

function mod:Magic()
	self:Bar("crystal", EJ_GetSectionInfo(4241), 75, L["crystal_red_icon"]) -- Timeloop
	self:Message("crystal", L["crystal_blue"], "Positive", L["crystal_blue_icon"], "Info")
end

function mod:Loop()
	self:Message("crystal", EJ_GetSectionInfo(4241), "Positive", L["crystal_red_icon"], "Info") -- Timeloop
end

function mod:HourofTwilight(_, spellId, _, _, spellName)
	self:FlashShake(106371)
	self:Message(106371, ("%s (%d)"):format(spellName, hourCounter), "Important", spellId, "Alert")
	hourCounter = hourCounter + 1
	self:Bar(106371, ("%s (%d)"):format(spellName, hourCounter), 45, spellId)
end

do
	local scheduled = nil
	local function fadingLight(spellName)
		mod:TargetMessage(105925, spellName, lightTargets, "Attention", 105925, "Alarm")
		scheduled = nil
	end
	function mod:FadingLight(player, spellId, _, _, spellName)
		lightTargets[#lightTargets + 1] = player
		if UnitIsUnit(player, "player") then
			local duration = select(6, UnitDebuff("player", spellName))
			self:Bar(105925, CL["you"]:format(spellName), duration, spellId)
			self:FlashShake(105925)
		end
		if not scheduled then
			scheduled = true
			self:ScheduleTimer(fadingLight, 0.1, spellName)
		end
	end
end

