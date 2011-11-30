--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Madness of Deathwing", 824, 333)
if not mod then return end
mod:RegisterEnableMob(56173, 56168, 56103) -- Deathwing, Wing Tentacle, Thrall

--------------------------------------------------------------------------------
-- Locales
--

local hemorrhage = (GetSpellInfo(105853))

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.last_phase, L.last_phase_desc = EJ_GetSectionInfo(4046)
	L.last_phase_icon = 109592

	L.bigtentacle, L.bigtentacle_desc = EJ_GetSectionInfo(4112)
	L.bigtentacle_icon = 105563

	L.smalltentacles, L.smalltentacles_desc = EJ_GetSectionInfo(4103)
	L.smalltentacles_icon = 109588

	L.hemorrhage, L.hemorrhage_desc = EJ_GetSectionInfo(4108)
	L.hemorrhage_icon = "SPELL_FIRE_MOLTENBLOOD"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"bigtentacle", "smalltentacles", { 105651, "FLASHSHAKE"}, "hemorrhage", 110044,
		"last_phase",
		"bosskill",
	}, {
		bigtentacle = "ej:4040",
		last_phase = "ej:4046",
		bosskill = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "EngageUnit")
	self:Log("SPELL_AURA_APPLIED", "BlisteringTentacle", 109588, 109589, 109590, 105444)
	self:Log("SPELL_CAST_SUCCESS", "ElementiumBolt", 105651)
	self:Log("SPELL_CAST_SUCCESS", "AgonizingPain", 106548)
	self:Log("SPELL_CAST_START", "Cataclysm", 110044, 106523, 110042, 110043)
	self:Log("SPELL_AURA_APPLIED", "LastPhase", 109592) -- corrupted blood

	self:Death("Win", 56173)
end

function mod:OnEngage(diff)

end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- XXX maybe too much sound? All of them are for adds tho that you have to kill ASAP.
do
	local prev = 0
	function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, spellName, _, _, spellId)
		if spellName == hemorrhage then
			local t = GetTime()
			if t-prev > 5 then
				prev = t
				self:Message("hemorrhage", spellName, "Urgent", "spell_fire_moltenblood", "Alarm")
			end
		end
	end
end

function mod:LastPhase(_, spellId)
	self:Message("last_phase", L["last_phase"], "Attention", spellId)
end

function mod:ElementiumBolt(_, spellId, _, _, spellName)
	self:FlashShake(105651)
	self:Message(105651, spellName, "Important", spellId, "Long")
end

function mod:Cataclysm(_, spellId, _, _, spellName)
	self:Message(110044, spellName, "Attention", spellId)
	self:Bar(110044, spellName, 60, spellId)
end

function mod:AgonizingPain()
	self:SendMessage("BigWigs_StopBar", self, (GetSpellInfo(110044))) -- cataclysm
end

do
	local prev = 0
	function mod:BlisteringTentacle(unit, spellId)
		local t = GetTime()
		if t-prev > 5 then
			prev = t
			self:Message("smalltentacles", unit, "Urgent", spellId, "Alarm")
		end
	end
end

function mod:EngageUnit()
	if UnitExists("boss2") then
		if tonumber(UnitGUID("boss1"):sub(7, 10), 16) == 56471 then
			self:Message("bigtentacle", L["bigtentacle"] , "Urgent", 105563, "Alert")
		end
	end
	mod:CheckBossStatus()
end

