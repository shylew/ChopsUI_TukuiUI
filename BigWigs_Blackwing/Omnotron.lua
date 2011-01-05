--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Omnotron Defense System", "Blackwing Descent")
if not mod then return end
mod:RegisterEnableMob(42166, 42179, 42178, 42180, 49226) -- Arcanotron, Electron, Magmatron, Toxitron, Lord Victor Nefarius
mod.toggleOptions = {{79501, "ICON", "FLASHSHAKE"}, {79888, "ICON", "FLASHSHAKE"}, "proximity", {80161, "FLASHSHAKE"}, 91513, {80094, "FLASHSHAKE"}, "nef", {92048, "ICON"}, 92023, "switch", "iconomnotron", "bosskill"}
local CL = LibStub("AceLocale-3.0"):GetLocale("Big Wigs: Common")
mod.optionHeaders = {
	switch = "general",
	[79501] = "Magmatron",
	[79888] = "Electron",
--	[] = "Arcanotron",
	[80161] = "Toxitron",
	nef = "Nefarian",
}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.nef = "Lord Victor Nefarius"
	L.nef_desc = "Warnings for Lord Victor Nefarius abilities."
	L.switch = "Switch"
	L.switch_desc = "Warning for Switches."
	L.switch_message = "Switch - %s %s"

	L.next_switch = "Next Switch"

	L.nef_trigger1 = "Were you planning on using Toxitron's chemicals to damage the other constructs? Clever plan, let me ruin that for you."
	L.nef_trigger2 = "Stupid Dwarves and your fascination with runes! Why would you create something that would help your enemy?"

	L.nef_next = "~Next ability buff"

	L.acquiring_target = "Acquiring Target"

	L.cloud_message = "Cloud on YOU!"
	L.protocol_message = "Poison Bombs!"

	L.iconomnotron = "Icon on active boss"
	L.iconomnotron_desc = "Place the primary raid icon on the active boss (requires promoted or leader)."
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "AcquiringTarget", 79501, 92035, 92036)

	self:Yell("NefAbilties", L["nef_trigger1"])
	self:Yell("NefAbilties", L["nef_trigger2"])

	self:Log("SPELL_CAST_SUCCESS", "PoisonProtocol", 91513, 91499, 91514, 91515)
	self:Log("SPELL_AURA_APPLIED", "Fixate", 80094)

	self:Log("SPELL_AURA_APPLIED", "ChemicalCloud", 80161, 91480, 91479, 91473, 91471) --91471 for 25norm, not sure about the rest, obviously 1 is wrong
	self:Log("SPELL_AURA_APPLIED", "ShadowInfusion", 92048)
	self:Log("SPELL_AURA_APPLIED", "EncasingShadows", 92023)
	self:Log("SPELL_AURA_APPLIED", "LightningConductor", 79888, 91433, 91431, 91432)
	self:Log("SPELL_AURA_APPLIED", "Switch", 78740, 95016)

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Deaths", 42166, 42179, 42178, 42180)
end

function mod:OnEngage(diff)
	self:Bar("switch", L["next_switch"], diff > 2 and 30 or 40, 91513)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:NefAbilties()
	self:Message("nef", L["nef_next"], "Attention", 92048)
	self:Bar("nef", L["nef_next"], 35, 92048)
end

function mod:Switch(unit, spellId, _, _, spellName)
	self:Bar("switch", L["next_switch"], self:GetInstanceDifficulty() > 2 and 30 or 40, spellId)
	self:Message("switch", L["switch_message"]:format(unit, spellName), "Important", spellId, "Alert")
	for i = 1, 4 do
		local bossId = ("boss%d"):format(i)
		if UnitName(bossId) == unit then
			self:PrimaryIcon("iconomnotron", bossId)
			break
		end
	end
end

function mod:ShadowInfusion(player, spellId, _, _, spellName)
	if UnitIsUnit(player, "player") then
		self:FlashShake(92048)
	end
	self:TargetMessage(92048, spellName, player, "Urgent", spellId)
	self:Bar("nef", L["nef_next"], 35, 92048)
	self:SecondaryIcon(92048, player)
end

function mod:EncasingShadows(player, spellId, _, _, spellName)
	self:TargetMessage(92023, spellName, player, "Urgent", spellId)
	self:Bar("nef", L["nef_next"], 35, 92048)
end

function mod:AcquiringTarget(player, spellId)
	if UnitIsUnit(player, "player") then
		self:FlashShake(79501)
	end
	self:TargetMessage(79501, L["acquiring_target"], player, "Urgent", spellId)
	self:SecondaryIcon(79501, player)
end

function mod:Fixate(player, spellId, _, _, spellName)
	if UnitIsUnit(player, "player") then
		self:FlashShake(80094)
		self:LocalMessage(80094, CL["you"]:format(spellName), "Personal", spellId, "Info")
	end
end

function mod:LightningConductor(player, spellId, _, _, spellName)
	if UnitIsUnit(player, "player") then
		self:FlashShake(79888)
		self:OpenProximity(15) --assumed
		self:ScheduleTimer(self.CloseProximity, 10, self)
	end
	self:TargetMessage(79888, spellName, player, "Attention", spellId)
	self:SecondaryIcon(79888, player)
end

function mod:PoisonProtocol(_, spellId, _, _, spellName)
	self:Bar(91513, spellName, 45, spellId)
	self:Message(91513, L["protocol_message"], "Positive", spellId)
end

do
	local last = 0
	function mod:ChemicalCloud(player, spellId)
		local time = GetTime()
		if (time - last) > 2 then
			last = time
			if UnitIsUnit(player, "player") then
				self:LocalMessage(80161, L["cloud_message"], "Personal", spellId, "Info")
				self:FlashShake(80161)
			end
		end
	end
end

do
	local deaths = 0
	function mod:Deaths()
		deaths = deaths + 1
		if deaths == 4 then
			self:Win()
		end
	end
end

