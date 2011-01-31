--{{{ Libraries
--}}}
local GridStatus = Grid:GetModule("GridStatus")
local GridRoster = Grid:GetModule("GridRoster")

GridStatusChimaeron = GridStatus:NewModule("GridStatusChimaeron")
GridStatusChimaeron.menuName = "Chimaeron (Health Left)"


GridStatusChimaeron.defaultDB = {
	unitChimaeron = {
		enable = true,
		color = { r = 1, g = .5, b = 1, a = 1 },
		priority = 99,
        range = false,
        useClassColors = false,
	threshold = 10000,
	},
}


local ChimaeronOptions = {
    ["useClassColors"] = {
        type = "toggle",
        name = "Use class color",
        desc = "Color health based on class.",
        get = function ()
            return GridStatusChimaeron.db.profile.unitChimaeron.useClassColors
            end,
        set = function (_,v)
            GridStatusChimaeron.db.profile.unitChimaeron.useClassColors = v
            GridStatusChimaeron:UpdateAllUnits()
        end,
    },
    ["Threshold"] = {
		type = "range",
		name = "Health Threshold",
		desc = "Blah Blah",
        max = 200000,
        min = 1,
        step = 1,
		get = function()
			return GridStatusChimaeron.db.profile.unitChimaeron.threshold
		end,
		set = function(_, v)
			GridStatusChimaeron.db.profile.unitChimaeron.threshold=v
		end,
	}
}

function GridStatusChimaeron:OnInitialize()
	self.super.OnInitialize(self)
	self:RegisterStatus("unitChimaeron", "Chimaeron (Health Left)", ChimaeronOptions,true)
end

function GridStatusChimaeron:OnEnable()
    self:RegisterEvent("Grid_UnitJoined")

	self:RegisterEvent("UNIT_HEALTH", "UpdateUnit")

    self:RegisterEvent("RAID_ROSTER_UPDATE", "UpdateAllUnits")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "UpdateAllUnits")

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAllUnits")
	self:RegisterEvent("Grid_ColorsChanged", "UpdateAllUnits")
end

function GridStatusChimaeron:OnDisable()
end

function GridStatusChimaeron:Reset()
	self.super.Reset(self)
	self:UpdateAllUnits()
end

function GridStatusChimaeron:UpdateAllUnits()
	for guid, unitid in GridRoster:IterateRoster() do
		self:Grid_UnitJoined(self,guid, unitid)
	end
end

function GridStatusChimaeron:Grid_UnitJoined(event,guid, unitid)
	if unitid then
		self:UpdateUnit(event,unitid, true)
		self:UpdateUnit(event,unitid)
	end
end

function GridStatusChimaeron:UpdateUnit(event,unitid, ignoreRange)
    local cur, max = UnitHealth(unitid), UnitHealthMax(unitid)
    local guid = UnitGUID(unitid)
    local settings = self.db.profile.unitChimaeron
    local healthText
    local priority = settings.priority
    if not GridRoster:IsGUIDInRaid(guid) then
        return
    end

    if cur < max then
        healthText = self:FormatHealthText(cur)
    else
        priority = 1
    end


    if cur <= settings.threshold then
        self.core:SendStatusGained(guid, "unitChimaeron", priority,
            (settings.range and 40),
            (settings.useClassColors and self.core:UnitColor(guid)
                or settings.color),
            healthText,
            cur,
            max,
            settings.icon)
    else
        self.core:SendStatusLost(guid, "unitChimaeron")
    end
end

function GridStatusChimaeron:FormatHealthText(amount)
	local healthText
	if amount > 999 then
		healthText = string.format("%.1fk", amount/1000.0)
	else
		healthText = string.format("%3.0f", amount)
	end

	return healthText
end
