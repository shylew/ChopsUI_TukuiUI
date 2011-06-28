--[[
## Interface: 40200
## Title: BalancePowerTracker_Pipe
## Version: 1.0.0
## Author: Kurohoshi (EU-Minahonda)
## Notes: Provides PowerAuras the ability to read BPT's values.

--CHANGELOG
v1.0.0: Release
--]]
if BPT_PIPE_STATUS then 
	BPT_PIPE_STATUS = "ARDY"
	print("|c00a080ffBalancePowerTracker PIPE|r: ERROR: NOT LOADED")
	return 
elseif (select(2,UnitClass("player"))~="DRUID") then 
	BPT_PIPE_STATUS = "!DRU" 
	print("|c00a080ffBalancePowerTracker PIPE|r: ERROR: NOT LOADED")
	return
end
BPT_PIPE_STATUS = "INIT"
--saved values 
local powerStorage = {};
local directionStorage = {};
local vLunarEnergyType,vSolarEnergyType,lunarEnergyType,solarEnergyType,eclipseDirectionType,vEclipseDirectionType;
local callbackId;
local modified = false
-- PowaAuras functions
local oldIsCorrectPowerType,oldUnitValue,oldUnitValueMax;	
--Event frames
local eventFrame = CreateFrame("Frame",nil,UIParent)
eventFrame:RegisterEvent("ADDON_LOADED")
local resetDirectionOnTalentFrame = CreateFrame("Frame",nil,UIParent)
resetDirectionOnTalentFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
resetDirectionOnTalentFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

local function Modify()
	if (modified) or (not PowaAuras) then return end
	if (not LibBalancePowerTracker) then 
		BPT_PIPE_STATUS = "MISS"
		eventFrame:UnregisterEvent("ADDON_LOADED")
		print("|c00a080ffBalancePowerTracker PIPE|r: ERROR: LibBalancePowerTracker not found") 
		return 
	end
	
	--Global initialization
	BPT_VIRTUAL_SPELL_POWER_LUNAR_ECLIPSE = SPELL_POWER_RUNES;
	BPT_VIRTUAL_SPELL_POWER_SOLAR_ECLIPSE =	SPELL_POWER_RUNIC_POWER;
	BPT_ECLIPSE_DIRECTION = SPELL_POWER_SOUL_SHARDS;
	BPT_VIRTUAL_ECLIPSE_DIRECTION = SPELL_POWER_HOLY_POWER;
	--Locals 
	vLunarEnergyType = BPT_VIRTUAL_SPELL_POWER_LUNAR_ECLIPSE;
	vSolarEnergyType = BPT_VIRTUAL_SPELL_POWER_SOLAR_ECLIPSE;
	lunarEnergyType = SPELL_POWER_LUNAR_ECLIPSE;
	solarEnergyType = SPELL_POWER_SOLAR_ECLIPSE;
	eclipseDirectionType = BPT_ECLIPSE_DIRECTION;
	vEclipseDirectionType = BPT_VIRTUAL_ECLIPSE_DIRECTION;
	
	--store values (there's no reason to ask LBPT every time), it also checks the type values 
	powerStorage = {
		[vLunarEnergyType]	= 0,
		[vSolarEnergyType]	= 0,
		[lunarEnergyType]	= 0,
		[solarEnergyType]	= 0,
	}
	directionStorage ={
		[eclipseDirectionType]	= 2,
		[vEclipseDirectionType]	= 2,
	}
	--PowaAuras DB values
	PowaAuras.PowerTypeIcon[BPT_VIRTUAL_SPELL_POWER_LUNAR_ECLIPSE] = "ability_druid_eclipse";
	PowaAuras.PowerTypeIcon[BPT_VIRTUAL_SPELL_POWER_SOLAR_ECLIPSE] = "ability_druid_eclipseorange";
	PowaAuras.PowerTypeIcon[BPT_ECLIPSE_DIRECTION] = "ability_druid_EarthandSky";
	PowaAuras.PowerTypeIcon[BPT_VIRTUAL_ECLIPSE_DIRECTION] = "ability_druid_EarthandSky";

	--PowaAuras.RangeType[BPT_VIRTUAL_SPELL_POWER_LUNAR_ECLIPSE] = "%";
	--PowaAuras.RangeType[BPT_VIRTUAL_SPELL_POWER_SOLAR_ECLIPSE] = "%";
	--PowaAuras.RangeType[BPT_ECLIPSE_DIRECTION] = "";
	--PowaAuras.RangeType[BPT_VIRTUAL_ECLIPSE_DIRECTION] = "";

	--PowaAuras.PowerRanges[BPT_VIRTUAL_SPELL_POWER_LUNAR_ECLIPSE] = 100;
	--PowaAuras.PowerRanges[BPT_VIRTUAL_SPELL_POWER_SOLAR_ECLIPSE] = 100;
	--PowaAuras.PowerRanges[BPT_ECLIPSE_DIRECTION] = 3;
	--PowaAuras.PowerRanges[BPT_VIRTUAL_ECLIPSE_DIRECTION] = 3;

	PowaAuras.Text.PowerType[BPT_VIRTUAL_SPELL_POWER_LUNAR_ECLIPSE]="|c00a080ff(BPT)|r Virtual Lunar energy";
	PowaAuras.Text.PowerType[BPT_VIRTUAL_SPELL_POWER_SOLAR_ECLIPSE]="|c00a080ff(BPT)|r Virtual Solar energy";
	PowaAuras.Text.PowerType[BPT_ECLIPSE_DIRECTION]="|c00a080ff(BPT)|r Eclipse Direction";
	PowaAuras.Text.PowerType[BPT_VIRTUAL_ECLIPSE_DIRECTION]="|c00a080ff(BPT)|r Virtual Eclipse Direction";

	--modify PowaAuras functions
	oldIsCorrectPowerType = cPowaPowerType.IsCorrectPowerType
	oldUnitValue			= cPowaPowerType.UnitValue
	oldUnitValueMax 		= cPowaPowerType.UnitValueMax

	function cPowaPowerType:IsCorrectPowerType(unit)
		local pType = self.PowerType;
		if powerStorage[pType] or directionStorage[pType] then return true; end
		
		local unitPowerType = UnitPowerType(unit);
		if (self.Debug) then PowaAuras:DisplayText("TAINTED BY BPT  cPowaPowerType IsCorrectPowerType powerType=", unitPowerType, " expected=", pType);	end
		if (not unitPowerType) 							then return false;					end
		if (not pType or pType==-1)	then return (unitPowerType > 0); 	end
		return (unitPowerType==pType);
	end
	function cPowaPowerType:UnitValue(unit)
		PowaAuras:Debug("TAINTED BY BPT  UnitValue for ", unit, " type=",self.PowerType);
		if (self.Debug) then PowaAuras:DisplayText("TAINTED BY BPT  UnitValue for ", unit, " type=",self.PowerType);end
		local power;
		if		(not self.PowerType or self.PowerType==-1)				then power = UnitPower(unit);
		elseif	(unit=="player") and powerStorage[self.PowerType] 		then power = powerStorage[self.PowerType];
		elseif 	(unit=="player") and directionStorage[self.PowerType]	then power = directionStorage[self.PowerType];
		else													 			 power = UnitPower(unit, self.PowerType);
		end
		if (self.Debug) then PowaAuras:DisplayText("power=", power); end
		return power;
	end
	function cPowaPowerType:UnitValueMax(unit)
		PowaAuras:Debug("TAINTED BY BPT  UnitValueMax for ", unit);
		if (self.Debug) then PowaAuras:DisplayText("TAINTED BY BPT  UnitValueMax for ", unit, " type=",self.PowerType);	end
		local maxpower;
		if 		(not self.PowerType or self.PowerType==-1)				then maxpower = UnitPowerMax(unit);
		elseif 	(unit=="player") and powerStorage[self.PowerType] 		then maxpower = 100;
		elseif	(unit=="player") and directionStorage[self.PowerType]	then maxpower = 3;
		else															 	 maxpower = UnitPowerMax(unit, self.PowerType);
		end
		if (self.Debug) then PowaAuras:DisplayText("maxpower=", maxpower); end
		return maxpower;
	end
	--Schedule events firing & Store energy values
	local directionToInt = {moon = 1,none = 2,sun = 3,}
	setmetatable(directionToInt, {__index = function () return 0 end})
	resetDirectionOnTalentFrame:SetScript("OnEvent",function() if GetEclipseDirection()=="none" then directionStorage[eclipseDirectionType],directionStorage[vEclipseDirectionType] = 2,2 end end)
	callbackId = LibBalancePowerTracker:RegisterFullCallback(function(energy,direction,vEnergy,vDirection) 
																		powerStorage[vLunarEnergyType]	= math.max(-vEnergy,0);
																		powerStorage[vSolarEnergyType]	= math.max(vEnergy,0);
																		powerStorage[lunarEnergyType]	= math.max(-energy,0);
																		powerStorage[solarEnergyType]	= math.max(energy,0);
																		directionStorage[eclipseDirectionType]	= directionToInt[direction];
																		directionStorage[vEclipseDirectionType]	= directionToInt[vDirection];
																		PowaAuras:UNIT_POWER("player");
																	end)
	
	for k,v in pairs(PowaAuras.Auras) do if powerStorage[v.PowerType] or directionStorage[v.PowerType] then	v.icon = "Interface\\icons\\"..PowaAuras.PowerTypeIcon[v.PowerType]; end end
	
	modified = true;
	BPT_PIPE_STATUS = "WORK"
end
eventFrame:SetScript("OnEvent",Modify);
BPT_PIPE_STATUS = "LOAD"
Modify();