--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Warlord Zon'ozz", 824, 324)
if not mod then return end
mod:RegisterEnableMob(55308)

--------------------------------------------------------------------------------
-- Locales
--

local psychicDrain, voidoftheUnmaking, darkness = (GetSpellInfo(104322)), (GetSpellInfo(103627)), (GetSpellInfo(109413))
local disruptingShadowsTargets = mod:NewTargetList()

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.ball = "Void ball"
	L.ball_desc = "Void ball that bounces off of players and the boss."
	L.ball_icon = 28028 -- void sphere icon

	L.bounce = "Void ball bounce"
	L.bounce_desc = "Counter for the void ball bounces."
	L.bounce_icon = 73981 -- some bouncing bullet like icon

	L.darkness = "Tentacle disco party!"
	L.darkness_desc = "This phase starts, when the void ball hits the boss."
	L.darkness_icon = 109413
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"ball", "bounce", "darkness",
		104322, {103434, "FLASHSHAKE", "SAY" }, "proximity",
		"berserk", "bosskill",
	}, {
		["ball"] = "ej:3973",
		[104322] = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:Log("SPELL_CAST_SUCCESS", "PsychicDrain", 104322, 104607, 104608, 104606)
	self:Log("SPELL_AURA_APPLIED", "DisruptingShadowsApplied", 103434, 104600, 104601, 104599)
	self:Log("SPELL_AURA_REMOVED", "DisruptingShadowsRemowed", 103434, 104600, 104601, 104599)
	self:Log("SPELL_CAST_SUCCESS", "VoidoftheUnmaking", 103627)
	self:Log("SPELL_AURA_APPLIED", "VoidDiffusion", 106836)
	self:Log("SPELL_AURA_APPLIED_DOSE", "VoidDiffusion", 106836)

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Win", 55308)
end

function mod:OnEngage(diff)
	self:Berserk(360) -- confirmed 10 man heroic
	if diff > 2 then
		self:Bar("ball", voidoftheUnmaking, 6, 28028)
		self:Bar(104322, psychicDrain, 12, 104322)
	else
		self:Bar(104322, psychicDrain, 16, 104322)
		self:Bar("ball", voidoftheUnmaking, 26, 28028)
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prev = 0
	function mod:UNIT_SPELLCAST_SUCCEEDED(_, unit, spellName, _, _, spellId)
		if not (unit):find("boss") then return end -- For PTR's take untill we know it's always boss 1
		if spellName == darkness then
			local t = GetTime()
			if t-prev > 5 then
				prev = t
				self:Bar("darkness", L["darkness"], 30, spellId) -- EJ says 30 sec, heroic timing is probably different
				self:Message("darkness", L["darkness"], "Important", spellId, "Info") -- can use info, no conflict here
			end
		end
	end
end

function mod:VoidDiffusion(_, spellId, _, _, spellName, stack)
	self:Message("bounce", ("%s (%d)"):format(L["bounce"], stack or 1), "Important", spellId)
end

function mod:PsychicDrain(_, spellId, _, _, spellName)
	self:Bar(104322, "~"..spellName, 20, spellId)
	--self:Message(104322, spellName, "Urgent", spellId) -- do we need this, it's for tanks only
end

function mod:VoidoftheUnmaking(_, spellId, _, _, spellName)
	self:Bar("ball", "~"..L["ball"], 20, 28028) -- void sphere icon
	self:Message("ball", L["ball"], "Urgent", 28028, "Alarm") -- void sphere icon
end

do
	local scheduled = nil
	local function disruptingShadows(spellName)
		mod:TargetMessage(103434, spellName, disruptingShadowsTargets, "Attention", 103434, "Info")
		scheduled = nil
	end
	function mod:DisruptingShadowsApplied(player, spellId, _, _, spellName)
		disruptingShadowsTargets[#disruptingShadowsTargets + 1] = player
		if UnitIsUnit(player, "player") then
			self:Say(103434, CL["say"]:format(spellName))
			self:FlashShake(103434)
			if self:Difficulty() > 2 then
				self:OpenProximity(10)
			end
		end
		if not scheduled then
			scheduled = true
			self:ScheduleTimer(disruptingShadows, 0.1, spellName)
		end
	end
end

function mod:DisruptingShadowsRemowed(player)
	if UnitIsUnit(player, "player") then
		self:CloseProximity()
	end
end

