
------------------------------------------------------------------------
--
-- GridStatusAbsorbsMonitor
--
-- Copyright (C) 2010  Philipp Schmidt
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to:
--
-- Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor,
-- Boston, MA  02110-1301, USA.
--
--
------------------------------------------------------------------------


if(not Grid) then
	message("GridStatusAbsorbsMonitor requires Grid to be installed and active");
	return;
end

local L_ABSORBS_LEFT;
local locale = GetLocale();

if(locale == "deDE") then
	L_ABSORBS_LEFT = "Verbleibende Absorptionseffekte";
elseif(locale == "frFR") then
	L_ABSORBS_LEFT = "Effets absorbés sur la gauche";
elseif(locale == "koKR") then
	L_ABSORBS_LEFT = "흡수 효과 사라짐";
else
	L_ABSORBS_LEFT = "Absorb effects left";
end

local GridStatusAbsorbsMonitor = Grid:GetModule("GridStatus"):NewModule("GridStatusAbsorbsMonitor");
GridStatusAbsorbsMonitor.menuName = L_ABSORBS_LEFT;

local AbsorbsMonitor = LibStub("LibAbsorbsMonitor-1.0");

local profile;
local color;

GridStatusAbsorbsMonitor.defaultDB = {
	unitAbsorbsLeft = {
		enable = true,
		priority = 90,
		color = { r = 1, g = 0, b = 0, a = 0.5 },
	},
};


function GridStatusAbsorbsMonitor:OnInitialize()
	self.super.OnInitialize(self);
	self:RegisterStatus("unitAbsorbsLeft", L_ABSORBS_LEFT, nil, true);
	
	profile = self.db.profile.unitAbsorbsLeft;
	color = profile.color;
end

function GridStatusAbsorbsMonitor:OnEnable()
    self:RegisterMessage("Grid_UnitJoined");
    
    AbsorbsMonitor.RegisterUnitCallbacks(self, "Absorbs_UnitUpdated", "Absorbs_UnitCleared");
end

function GridStatusAbsorbsMonitor:OnDisable()
	AbsorbsMonitor.UnregisterAllCallbacks(self);
end

function GridStatusAbsorbsMonitor:Grid_UnitJoined(event, guid, unitId)
    self.core:SendStatusLost(guid, "unitAbsorbsLeft");
end

function GridStatusAbsorbsMonitor:Absorbs_UnitUpdated(event, guid, value, quality)
	local shieldText;
	
	if(value > 999) then
		shieldText = string.format("%.1fk", value / 1000.0);
	else
		shieldText = string.format("%3.0f", value);
	end
	
	color.r = 1 - quality;
	color.g = quality;
	color.b = 0;

	self.core:SendStatusGained(guid, "unitAbsorbsLeft", profile.priority, nil, color, shieldText)
end

function GridStatusAbsorbsMonitor:Absorbs_UnitCleared(event, guid)
	self.core:SendStatusLost(guid, "unitAbsorbsLeft");
end
