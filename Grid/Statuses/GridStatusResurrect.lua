--[[--------------------------------------------------------------------
	Grid
	Compact party and raid unit frames.
	Copyright (c) 2006-2012 Kyle Smith (a.k.a. Pastamancer), A. Kinley (a.k.a. Phanx) <addons@phanx.net>
	All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info5747-Grid.html
	http://www.wowace.com/addons/grid/
	http://www.curse.com/addons/wow/grid
------------------------------------------------------------------------
	GridStatusResurrect.lua
	GridStatus module for showing incoming resurrections.
----------------------------------------------------------------------]]

local _, Grid = ...
local L = Grid.L

local MoP = select(4, GetBuildInfo()) >= 50000

local GridRoster = Grid:GetModule("GridRoster")

local GridStatusResurrect = Grid:NewStatusModule("GridStatusResurrect", "AceTimer-3.0")
GridStatusResurrect.menuName = L["Resurrection"]
GridStatusResurrect.options = false

GridStatusResurrect.defaultDB = {
	alert_resurrect = {
		text =  L["RES"],
		enable = true,
		color = { r = 0.5, g = 1.0, b = 0.5, a = 1.0 },
		priority = 50,
		range = false,
		showUntilUsed = true,
	},
}

local extraOptionsForStatus = {
	showUntilUsed = {
		name = L["Show until used"],
		desc = L["Show the status until the resurrection is accepted or expires, instead of only while it is being cast."],
		type = "toggle", width = "double",
		get = function()
			return GridStatusResurrect.db.profile.alert_resurrect.showUntilUsed
		end,
		set = function(_, v)
			GridStatusResurrect.db.profile.alert_resurrect.showUntilUsed = v
			GridStatusResurrect:UpdateAllUnits()
		end,
	},
}

------------------------------------------------------------------------
--[[
local resSpells = {
	2008,   -- Ancestral Spirit (shaman)
	61999,  -- Raise Ally (death knight)
	20484,  -- Rebirth (druid)
	7238,   -- Redemption (paladin)
	2006,   -- Resurrection (priest)
	115178, -- Resuscitate (monk)
	50769,  -- Revive (druid)
	982,    -- Revive Pet (hunter)
	20707,  -- Soulstone (warlock)
}
for i = #resSpells, 1, -1 do
	local id = resSpells[i]
	local name, _, icon = GetSpellInfo(id)
	if name then
		icon = icon:match("([^\\]+)$"):lower()
		resSpells[id] = icon
		resSpells[name] = icon
	end
	resSpells[i] = nil
end
]]
------------------------------------------------------------------------

function GridStatusResurrect:PostInitialize()
	self:Debug("PostInitialize")
	self:RegisterStatus("alert_resurrect", L["Resurrection"], extraOptionsForStatus, true)
end

function GridStatusResurrect:OnStatusEnable(status)
	if status ~= "alert_resurrect" then return end
	self:Debug("OnStatusEnable", status)

	self:RegisterEvent("INCOMING_RESURRECT_CHANGED", "UpdateAllUnits")
	self:RegisterEvent("PARTY_LEADER_CHANGED", "OnGroupChanged")
	if MoP then
		self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnGroupChanged")
	else
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", "OnGroupChanged")
		self:RegisterEvent("RAID_ROSTER_UPDATE", "OnGroupChanged")
	end

	self:RegisterMessage("Grid_PartyTransition", "OnGroupChanged")
	self:RegisterMessage("Grid_UnitJoined", "OnUnitJoined")
end

function GridStatusResurrect:OnStatusDisable(status)
	if status ~= "alert_resurrect" then return end

	self:UnregisterEvent("INCOMING_RESURRECT_CHANGED")
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
	if MoP then
		self:UnregisterEvent("GROUP_ROSTER_UPDATE")
	else
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		self:UnregisterEvent("RAID_ROSTER_UPDATE")
	end

	self:UnregisterMessage("Grid_PartyTransition")
	self:UnregisterMessage("Grid_UnitJoined")

	self:StopTimer("CheckCacheExpiry")
	self.core:SendStatusLostAllUnits("alert_resurrect")
end

------------------------------------------------------------------------

local TIMER_INTERVAL = 0.5

local numPending = 0
local casting, pending = {}, {}

function GridStatusResurrect:SendStatusLost(guid)
	self:Debug("SendStatusLost", GridRoster:GetUnitidByGUID(guid), (GridRoster:GetNameByGUID(guid)))
	self.core:SendStatusLost(guid, "alert_resurrect")

	casting[guid] = nil
	pending[guid] = nil
	numPending = numPending - 1

	if numPending == 0 then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:UnregisterEvent("UNIT_HEALTH")
		self:StopTimer("CheckCacheExpiry")
		self:Debug("Stopped timer.")
	end
end

function GridStatusResurrect:UpdateUnit(unit, guid)
	if not guid then
		guid = UnitGUID(unit)
	end

	local hasRes = UnitHasIncomingResurrection(unit)
	if hasRes and not casting[guid] then
		self:Debug(unit, UnitName(unit), "is now being resurrected.")

		local settings = self.db.profile.alert_resurrect
		self.core:SendStatusGained(guid, "alert_resurrect",
			settings.priority,
			settings.range,
			settings.color,
			settings.text,
			nil, nil,
			settings.icon)

		casting[guid] = true

	elseif not hasRes and casting[guid] then
		self:Debug(unit, UnitName(unit), "is no longer being resurrected.")
		casting[guid] = nil

		if not self.db.profile.alert_resurrect.showUntilUsed then
			self:Debug("Resurrection cast ended.")
			self:SendStatusLost(guid)

		elseif pending[guid] then
			self:Debug("Resurrection cast ended. Duplicate detected.")

		else
			pending[guid] = 1
			self:Debug("Resurrection cast ended. Waiting for combat log event.")

			numPending = numPending + 1
			self:Debug("Pending resurrections:", numPending)

			if numPending == 1 then
				self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
				self:RegisterEvent("UNIT_HEALTH")
				self:StartTimer("CheckCacheExpiry", TIMER_INTERVAL, true)
				self:Debug("Started timer.")
			end
		end
	end
end

function GridStatusResurrect:UNIT_HEALTH(event, unit)
	local guid = UnitGUID(unit)
	if not pending[guid] then return end

	self:Debug("UNIT_HEALTH", unit)

	if not UnitIsDeadOrGhost(unit) then
		self:Debug(unit, UnitName(unit), "is alive. Probably accepted resurrection.")
		self:SendStatusLost(guid)
	elseif UnitIsGhost(unit) then
		self:Debug(unit, UnitName(unit), "released.")
		self:SendStatusLost(guid)
	end
end

function GridStatusResurrect:COMBAT_LOG_EVENT_UNFILTERED(event, _, combatEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, spellName, spellSchool)
	if combatEvent ~= "SPELL_RESURRECT" then return end

	self:Debug(combatEvent, sourceName, "cast", spellName, "on", destName)

	if pending[destGUID] then
		self:Debug(GridRoster:GetUnitidByGUID(destGUID), destName, "received resurrection. Waiting for acceptance or expiry.")
		pending[destGUID] = GetTime() + 120
	end
end

function GridStatusResurrect:CheckCacheExpiry()
	--self:Debug("CheckCacheExpiry") -- pretty spammy
	local now = GetTime()
	for guid, expiry in pairs(pending) do
		if expiry - now < TIMER_INTERVAL then
			self:Debug("Resurrection expired on", GridRoster:GetUnitidByGUID(guid), (GridRoster:GetNameByGUID(guid)))
			self:SendStatusLost(guid)
		end
	end
end

------------------------------------------------------------------------

function GridStatusResurrect:UpdateAllUnits(event)
	self:Debug("UpdateAllUnits", event)
	for guid, unit in GridRoster:IterateRoster() do
		self:UpdateUnit(unit, guid)
	end
end

function GridStatusResurrect:OnGroupChanged(event)
	if self.db.profile.alert_resurrect.enable then
		self:Debug("OnGroupChanged", event)
		self:UpdateAllUnits()
	end
end

function GridStatusResurrect:OnUnitJoined(event, guid, unit)
	if unit and self.db.profile.alert_resurrect.enable then
		self:Debug("OnUnitJointed", event, unit)
		self:UpdateUnit(unit, guid)
	end
end