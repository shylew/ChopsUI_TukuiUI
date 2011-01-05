--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Atramedes", "Blackwing Descent")
if not mod then return end
mod:RegisterEnableMob(41442)
mod.toggleOptions = {"ground_phase", 78075, 77840, "air_phase", {78092, "FLASHSHAKE", "SAY"}, "bosskill"}

--------------------------------------------------------------------------------
-- Locals
--

local airPhaseDuration = 30

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.tracking_me = "Tracking on ME!"

	L.ground_phase = "Ground Phase"
	L.ground_phase_desc = "Warning for when Atramedes lands."
	L.air_phase = "Air Phase"
	L.air_phase_desc = "Warning for when Atramedes takes off."

	L.air_phase_trigger = "Yes, run! With every step your heart quickens. The beating, loud and thunderous... Almost deafening. You cannot escape!"

	L.sonicbreath_cooldown = "~Sonic Breath"
end
L = mod:GetLocale()

mod.optionHeaders = {
	ground_phase = L["ground_phase"],
	air_phase = L["air_phase"],
	[78092] = "general",
}

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "SonicBreath", 78075)
	self:Log("SPELL_AURA_APPLIED", "Tracking", 78092)
	self:Log("SPELL_AURA_APPLIED", "SearingFlame", 77840)
	self:Yell("AirPhase", L["air_phase_trigger"])

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Win", 41442)
end

function mod:OnEngage(diff)
	self:Bar(78075, L["sonicbreath_cooldown"], 23, 78075)
	self:Bar(77840, (GetSpellInfo(77840)), 45, 77840)
	self:Bar("air_phase", L["air_phase"], 100, 5740) -- Rain of Fire Icon
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Tracking(player, spellId, _, _, spellName)
	if UnitIsUnit(player, "player") then
		self:Say(78092, L["tracking_me"])
		self:FlashShake(78092)
	end
	self:TargetMessage(78092, spellName, player, "Personal", spellId, "Alarm")
	self:SecondaryIcon(78092, player)
end

function mod:SonicBreath(_, spellId, _, _, spellName)
	self:Message(78075, spellName, "Urgent", spellId, "Info")
	self:Bar(78075, L["sonicbreath_cooldown"], 42, spellId)
end

function mod:SearingFlame(_, spellId, _, _, spellName)
	self:Message(77840, spellName, "Important", spellId, "Alert")
end

do
	local function groundPhase()
		mod:Message("ground_phase", L["ground_phase"], "Attention", 61882) -- Earthquake Icon
		mod:Bar("air_phase", L["air_phase"], 90, 5740) -- Rain of Fire Icon
		mod:Bar(78075, L["sonicbreath_cooldown"], 25, 78075)
		-- XXX need a good trigger for ground phase start to make this even more accurate
		mod:Bar(77840, (GetSpellInfo(77840)), 50, 77840)
	end
	function mod:AirPhase()
		self:SendMessage("BigWigs_StopBar", self, L["sonicbreath_cooldown"])
		self:Message("air_phase", L["air_phase"], "Attention", 5740) -- Rain of Fire Icon
		self:Bar("ground_phase", L["ground_phase"], airPhaseDuration, 61882) -- Earthquake Icon
		self:ScheduleTimer(groundPhase, airPhaseDuration)
	end
end

