local Ellipsis = _G.Ellipsis

-- AURA EVENT HANDLER -------------------------------------

do
	local UnitCanAttack = _G.UnitCanAttack
	local handler

	local function AuraHandler(frame, event, unit)
		if (unit == 'target' or unit == 'focus') then
			if (UnitCanAttack('player', unit)) then
				Ellipsis:ScanAuras(unit, 'HARMFUL', true)
			else
				Ellipsis:ScanAuras(unit, 'HELPFUL', true)
			end
		else -- must be a friendly
			Ellipsis:ScanAuras(unit, 'HELPFUL')
		end
	end

	handler = CreateFrame('Frame')
	handler:SetScript('OnEvent', AuraHandler)

	function Ellipsis:ConfigureAuraScan()
		if (self.db.profile.trackBuffs or self.db.profile.trackDebuffs) then
			if (not handler:IsEventRegistered('UNIT_AURA')) then
				handler:RegisterEvent('UNIT_AURA')
			end
		else
			if (handler:IsEventRegistered('UNIT_AURA')) then
				handler:UnregisterEvent('UNIT_AURA')
			end
		end
	end
end

-- SECONDARY SCAN HANDLER ---------------------------------

do
	local handler = CreateFrame('Frame')
	local scan = false

	local throttle, rate = 0, 1.0
	local function SecondaryScan(frame, elapsed)
		throttle = throttle + elapsed

		if (throttle >= rate) then
			if (UnitExists('pettarget')) then
				Ellipsis:ScanAuras('pettarget', 'HARMFUL')
			end

			if (scan) then
				Ellipsis:DoSecondaryScan()
			end

			throttle = throttle - rate
		end
	end

	function Ellipsis:SetSecondaryScan(inParty, hasPet)
		if (scan and inParty or hasPet) then
			handler:SetScript('OnUpdate', SecondaryScan)
		else
			handler:SetScript('OnUpdate', nil)
		end
	end

	function Ellipsis:ConfigureSecondaryScan()
		scan = self.db.profile.secondaryScan
		rate = self.db.profile.secondaryScanRate
	end
end

local GetTime = _G.GetTime
local UnitHealth = _G.UnitHealth
local UnitAura = _G.UnitAura
local UnitGUID = _G.UnitGUID
local UnitIsUnit = _G.UnitIsUnit

local dntList, activeGUIDS, barMode, ghostShow, ignoreBreaksTime, minDur, maxDur, aoeSpells, trackPlayer, trackPet, showStackInName, trackBuffs, trackDebuffs
local name, rank, icon, count, duration, expireTime, caster, index, guid, target, time, changed, percent, remains, t

function Ellipsis:ScanAuras(unit, auraType, isTargetFocus)
	-- Abort scanning if this is an auraType were not tracking
	if ((not trackDebuffs and auraType == 'HARMFUL') or (not trackBuffs and auraType == 'HELPFUL')) then return end

	-- Abort scanning if its the player or pet but were either not tracking them or they come from another unitID,
	-- also abort scanning if this isn't the target or focus, but the unitID is also the targer or focus (redundant scanning)
	if (UnitIsUnit('player', unit)) then
		if (not trackPlayer or unit ~= 'player') then return end
	elseif (UnitIsUnit('pet', unit)) then
		if (not trackPet or unit ~= 'pet') then return end
	elseif (not isTargetFocus) then
		if (UnitIsUnit('target', unit) or UnitIsUnit('focus', unit)) then return end
	end

	guid, index, time = UnitGUID(unit), 1, GetTime()
	target = activeGUIDS[guid] or nil

	name, rank, icon, count, _, duration, expireTime, caster = UnitAura(unit, 1, auraType)

	while (name) do
		if (caster == 'player' and duration >= minDur and duration <= maxDur and not dntList[name]) then -- this is one of our buffs we want to track, do so
			if (target and target.timers[name]) then -- already on target, update values
				t = target.timers[name]
				t.valid = time

				-- checks to see if anything major has changed about the timer, if so, update display
				if (t.ghost or t.count ~= count or t.start ~= (expireTime - duration) or t.finish ~= expireTime) then
					-- Something major has changed, update timer GUI
					percent = 1 - ((time - t.start) / (expireTime - t.start))
					remains = expireTime - time

					t.ghost = false
					t.count = count
					t.start = expireTime - duration
					t.finish = expireTime

					t.bar:SetValue(percent)
					t.spark:SetPoint('CENTER', t.bar, 'LEFT', percent * self.barWidth, 0)
					t.spark:Show()

					if (showStackInName) then
						if (t.count > 0) then
							t.name:SetText(format(self.stackNameFormat, t.count, t.spell))
						else
							t.name:SetText(t.spell)
						end
					else
						t.stack:SetText((t.count > 0 and t.count) or '')
					end

					t.time:SetFormattedText(self:GetFormattedTime(remains))
					t.border:SetVertexColor(self:GetTimerColours(remains))

					if (barMode) then
						t.time:SetTextColor(unpack(self.db.profile.colours.timertext))
						t.name:SetWidth(self.barWidth - (t.time:GetStringWidth() + 6))
						t.bar:SetStatusBarColor(self:GetTimerColours(remains))
					else
						t.time:SetTextColor(self:GetTimerColours(remains))
					end
					self:UpdateTimerDisplay(guid)
				end
			elseif (not aoeSpells[name] and (expireTime - time) > 0.5) then
				-- not an aoe spell, not on target and not about to expire, add it (and a target if needed)
				if (not target) then
					self:CreateTarget(guid, unit, time, UnitName(unit), UnitLevel(unit), select(2, UnitClass(unit)), UnitClassification(unit), GetRaidTargetIndex(unit))
					target = activeGUIDS[guid]
				end

				self:CreateTimer(guid, name, rank, icon, count, duration, expireTime, time)
			end
		end

		index = index + 1
		name, rank, icon, count, _, duration, expireTime, caster = UnitAura(unit, index, auraType)
	end

	if (UnitHealth(unit) == 1) then return end -- Kind of a hack due to a 'final' unit_aura event being fired -just- as a mob dies (after stripping its debuffs)

	if (target) then -- this target is being tracked, check for broken timers
		changed = false
		for _, t in pairs(target.sortedTimers) do
			if (t.valid ~= time and not t.ghost and (t.finish - time) > ignoreBreaksTime) then
				-- we were tracking this timer, but it no longer exists as an active timer
				changed = true

				if (not ghostShow) then
					self:DestroyTimer(t.guid, t.spell, false, 'broken')
				else
					t.finish = time -- to force onupdate to see this as a ghost timer as well
					self:TimerSetAsGhost(t, 'broken')
				end
			end
		end

		if (changed) then
			-- one or more timers were killed (or ghosted), update or destroy target
			if (#target.sortedTimers > 0) then
				self:UpdateTimerDisplay(guid)
			else
				self:DestroyTarget(guid)
			end
		end
	end
end

function Ellipsis:ConfigureScanAuras()
	dntList = self.db.profile.doNotTrack
	activeGUIDS = self:GetActiveGUIDS()
	barMode = (self.db.profile.mode == 'bars' and true) or false
	ghostShow = self.db.profile.ghostShow
	ignoreBreaksTime = self.db.profile.timerUpdateRate + 1.0
	minDur, maxDur = self.db.profile.minAuraDuration, self.db.profile.maxAuraDuration * 60
	if (maxDur == 0) then
		maxDur = 432000 -- Don't think theres any buffs with a duration > 5days
	else
		maxDur = maxDur + 1 -- Hack: fix an onload bug with buffs of duration equal to maxDur
	end
	aoeSpells = self.aoeSpells
	trackPlayer = self.db.profile.trackPlayer
	trackPet = self.db.profile.trackPet
	trackBuffs = self.db.profile.trackBuffs
	trackDebuffs = self.db.profile.trackDebuffs
	showStackInName = self.db.profile.showStackInName
end

do
	local raidTargets = setmetatable({}, {__index=function(t,k)
		t[k] = format('raid%dtarget', k)
		return t[k]
	end})

	local partyTargets = setmetatable({}, {__index=function(t,k)
		t[k] = format('party%dtarget', k)
		return t[k]
	end})

	local unitIDs = {}
	local UnitExists = _G.UnitExists
	local UnitCanAttack = _G.UnitCanAttack
	local UnitIsUnit = _G.UnitIsUnit

	function Ellipsis:DoSecondaryScan()
		if (not self.db.profile.trackDebuffs) then return end -- if not tracking debuffs, abort scan

		local num = GetNumRaidMembers()
		local unit, inTable

		for _, v in pairs(unitIDs) do v = false end

		if (num > 0) then
			for x = 1, num do
				unit = raidTargets[x]
				if (UnitExists(unit) and UnitCanAttack('player', unit)) then
					inTable = false
					for k, v in pairs(unitIDs) do
						if (v and UnitIsUnit(unit, k)) then
							inTable = true
							break
						end
					end
					if (not inTable) then unitIDs[unit] = true end
				end
			end
		else
			num = GetNumPartyMembers()
			if (num > 0) then
				for x = 1, num do
					unit = partyTargets[x]
					if (UnitExists(unit) and UnitCanAttack('player', unit)) then
						inTable = false
						for k, v in pairs(unitIDs) do
							if (v and UnitIsUnit(unit, k)) then
								inTable = true
								break
							end
						end
						if (not inTable) then unitIDs[unit] = true end
					end
				end
			end
		end

		for k, v in pairs(unitIDs) do
			if (v) then
				self:ScanAuras(k, 'HARMFUL', false)
			end
		end
	end
end
