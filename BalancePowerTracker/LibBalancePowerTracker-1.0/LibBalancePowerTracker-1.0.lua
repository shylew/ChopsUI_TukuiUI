--[[
Interface: 4.2.0
Title: LibBalancePowerTracker
Version: 1.0.7
Author: Kurohoshi (EU-Minahonda)

--INFO
	LibBalancePowerTracker is a library designed to provide the foresee energy feature to Balance Druids.
	CPU is only used when required, so the CPU usage is very low.
	
	FORESEE ENERGY:
	Foresee Energy is a feature that analizes the spells you have cast and/or you are casting but are yet to land and computes 
	the energy sum of them. This allows the library to distinguish between two kinds of energy and Eclipse direction: One real, 
	the one you have at the moment and other virtual, the one you'll have when all flying spells and the spell you are casting land.
	Foresee Energy works assuming the following: 
		-You're hit capped (All your spells will land).
		-You're not going to proc Euphoria (2x energy gain).
			·If you proc it, it will update immediately, this only means you will reach Eclipse earlier than the library predicted the moment 
			before the Eupforia proc. 
	All the features with the 'virtual' tag (virtual Energy, virtual Eclipse ...) rely on Foresee Energy.
	
--API
	There are 5 variables related to Eclipse energy used in this addon:
		energy: The energy you have at the moment. Int = [-100,100]
		direction: The direction of the arrow. String = {"none","sun","moon"}
		virtual_energy: The energy you will have when the spell you're casting and all the flying spells land. Int = [-100,100]
		virtual_direction: The direction of the arrow when the spell you're casting and all the flying spells land. String = {"none","sun","moon"}
		virtual_eclipse: -100 if lunar, 100 if solar, false otherwise.

	FUNCTIONS:

	id = LibBalancePowerTracker:RegisterFullCallback(function(energy, direction, virtual_energy, virtual_direction, virtual_eclipse))
	These callbacks will be fired when there is a change in one of the Eclipse energy variables, usually twice per WR/SF/SS.
	NOTE: When registering a callback, that callback will be fired once.
		
	id = LibBalancePowerTracker:RegisterReducedCallback(function(energy, direction))
	These callbacks will be fired when there is a change ONLY in energy or direction, usually once per WR/SF/SS.
	NOTE: When registering a callback, that callback will be fired once.
	
	id = LibBalancePowerTracker:RegisterEclipseProbCallback(function(value))
	These callbacks will be fired every time value changes, value is the probability of Eclipse, taking into consideration euphoria and miss chance, 
	negative for Lunar Eclipse, positive for Solar Eclipse.
	NOTE: When registering a callback, that callback will be fired once.
	
	id = LibBalancePowerTracker:RegisterStatCallback(function(EnergyFunction))
	These callbacks will be fired every time EnergyFunction changes:
		energy, direction, virtual_energy, virtual_direction, virtual_eclipse = EnergyFunction(value) 
		Note: In this case, virtual_energy, virtual_direction and virtual_eclipse are special, EnergyFunction means:
		 "You have <value*100>% chance of having at least <select(3,EnergyFunction(value))> energy when all spells land, considering euphoria & miss chance." (the same goes the direction and virtual_eclipse)
	
	NOTE: When registering a callback, that callback will be fired once.
	
	failed = LibBalancePowerTracker:UnregisterCallback(id)
	Tries to unregister the callback with identifier id (id is returned only when you register the callback).
	
	energy, direction, virtual_energy, virtual_direction, virtual_eclipse = LibBalancePowerTracker:GetEclipseEnergyInfo()
	Gets the current state of the variables.
	
	value = LibBalancePowerTracker:GetEclipseChance()
	Gets the current Eclipse chance, checking Euphoria and miss chance of spells.
	
	EnergyFunction = LibBalancePowerTracker:GetEnergyFunction()	
		energy, direction, virtual_energy, virtual_direction, virtual_eclipse = EnergyFunction(value) 
		Note: In this case, virtual_energy, virtual_direction and virtual_eclipse are special, EnergyFunction means:
		 "You have <value*100>% chance of having at least <select(3,EnergyFunction(value))> energy when all spells land, considering euphoria & miss chance." (the same goes the direction and virtual_eclipse)
		
	version,subversion,revision = LibBalancePowerTracker:GetVersion()
	Gets the current working version of the library.	

--Must have an eye on this:
	AoE silence ------------------------------ Working in 4.1
	Vanish/Shadowmeld when spell is flying --- Working in 4.1
	pvp 4piece bonus issues ------------------ Working in 4.1 (Is it really needed now?) 
	
	A 40m y 41% celeridad llega antes el SF que el WR (se elimina correctamente, pero da problemas con la predicción del Eclipse) 
		-> A lo mejor debería añadir una función para introducir los hechizos en la cola en función de cuando van a llegar en vez de cuando salieron.
	
--CHANGELOG
v 1.0.7 Tier12 fully supported
		Handling specialWR now here
		Updated SpellQueueADT
		Some code improvements
		Changed reachEnd to virtualEclipse

v 1.0.6	WoW 4.2 fix
		SF autodelete timer increased by .5s
		Updated SpellQueueADT-1.1
		Interrupted spell bug fixed
		Fixed DoTs' energy for 4.2
		Early support for 4t12 bonus
		Included tier set
		Removed some unnecessary functions (RmoveFirsto0...)
		Minor bug in Advanced settings fixed.
		Minor bug causing to fire two callbacks when crossing 0 fixed.

v 1.0.5 Moved UpdateEuphoria into ReCheck
		4.1 fix
		Now shouldn´t load when not a druid succeesfully
		Future log compatibility functions
		The mark shouldn´t 'dance' at 0,100 and -100 energy anymore.
		Extra functions to avoid letting a spell remain in the queue when it must be erased.
		
v 1.0.4 Changed Euphoria chance based on Hamlet's findings on www.elitistjerks.com 
		Added target of target to the unit check.
		Fixed casting glyph of SS counting as casting SS
		Use spellId instead of names
		
v 1.0.3 Changed to use propperly SpellQueueADT 1.1.2
		Now erases flying spells when teleporting.
		FEATURE: Eclipse chance calculation.
		FEATURE: Energy statistically calculation.

v 1.0.2 Fixed sometimes not fetching the direction properly. 
		Fixed PvP bonus

v 1.0.1 Reduced the number of callbacks fired.

v 1.0.0 Release
--]]

local version = {1,0,7};

if (LibBalancePowerTracker and LibBalancePowerTracker:CompareVersion(version)) then return; end;

--Initialize Global Lib
LibBalancePowerTracker = {};
function LibBalancePowerTracker:CompareVersion(versionTable) 
	for i,v in ipairs(versionTable) do
		if version[i] < v then
			return false;
		end;
	end;
	return true;
end;


--Locals
----GLOBALS TO LOCALS-------------------------------------------------------------------
local GetEclipseDirection,UnitPower,SPELL_FAILED_NOT_READY,SPELL_FAILED_SPELL_IN_PROGRESS = GetEclipseDirection,UnitPower,SPELL_FAILED_NOT_READY,SPELL_FAILED_SPELL_IN_PROGRESS;
----DATA--------------------------------------------------------------------------------
local LBPT = {};
------OPTIONS---------------------------------------------------------------------------
local options = {
	enabled = true,
	foresee = true,
}
local callBacksActivated = {
	reduced = false,
	full = false,
	eclipseProb = false,
	stat = false,
}
------VARS------------------------------------------------------------------------------
local vars = {
	isDruid = false,
	isBalance = false,
	changedState = false,
	computedEnergy=0,
	computedVirtualEnergy = 0,
	computedVirtualEclipse = false,
	direction = "none",
	vDirection = "none",
	spellQ = SpellQueueADT:New(),

	lastWRenergy = -14,
	formerlastWRenergy = -13,
	
	ecTime = 0,
	eclipse = false,
	
	unitLevelSent = 0,
	unitIsPCSent = true,
	euphoria = 0.12,
	wayTable = {},
	max_levels = 5, --Número máximo de hechizos que se calculan, consumo máximo aumenta de forma exponencial, 3^5 me parece un buen límite
	
	inverseCumulativeDistributionFunction = function() return 0,"none",0,"none",false; end,
	eclipseProb= 0,
	
	tiers = {
		[1]=false,--head
		[3]=false,--shoulders
		[5]=false,--chest
		[7]=false,--trousers
		[10]=false,--gloves
		tierPieceCount = {},
	}
}
local playerGUID,lastCallback,callbacks,reducedCallbacks,eclipseProbCallbacks,statCallbacks,elements = false,0,{},{},{},{},0;
------STATIC----------------------------------------------------------------------------
local missTablePvE = {
	[-4] = 1,
	[-3] = .99,
	[-2] = .98,
	[-1] = .97,
	[0] = .96,
	[1] = .95,
	[2] = .94,
	[3]	= .83,
	[4]	= .72,
	[5]	= .61,
};
local missTablePvP = {
	[-4]= 1,
	[-3]= .99,
	[-2]= .98,
	[-1]= .97,
	[0]	= .96,
	[1]	= .95,
	[2]	= .94,
	[3]	= .87,
	[4]	= .80,
	[5]	= .73,
};
local data ={
	WR  = {name = GetSpellInfo(5176) ,energy = 13,spellId=5176 }, -- name & energy Wrath
	SF  = {name = GetSpellInfo(2912) ,energy = 20,spellId=2912 }, -- name & energy Starfire
	SS  = {name = GetSpellInfo(78674),energy = 15,spellId=78674}, -- name StarSurge
	EE  = {spellId = 89265}, -- Eclipse Energy spell
	SSE = {spellId = 86605}, --Starsurge Energy spell
	SuddenEclipse = {spellId = 95746}, --PvP energy proc
	LunarEclipse  = {spellId = 48518}, -- Lunar eclipse buff id
	SolarEclipse  = {spellId = 48517}, -- Solar eclipse buff id
	balanceTiersItemId ={
		[12]={
			[1]={ [71108]="n",[71497]="h"},--head
			[3]={ [71111]="n",[71500]="h"},--shoulders
			[5]={ [71110]="n",[71499]="h"},--chest
			[7]={ [71109]="n",[71498]="h"},--trousers
			[10]={[71107]="n",[71496]="h"},--gloves
			bonus4p = true,
		},
	}
};
----TIMERS-------------------------------------------------------------------------------
local timers={
	holder = CreateFrame("Frame","LibBalancePowerTrackerTimerFrame",UIParent);
	broadcastTier = CreateFrame("Cooldown","LibBalancePowerTrackerWRTimer",LibBalancePowerTrackerTimerFrame),
	[data.WR.spellId] = {seconds=2,timer=CreateFrame("Cooldown","LibBalancePowerTrackerWRTimer",LibBalancePowerTrackerTimerFrame)}, --2.2s aprox
	[data.SS.spellId] = {seconds=2,timer=CreateFrame("Cooldown","LibBalancePowerTrackerSSTimer",LibBalancePowerTrackerTimerFrame)}, --2.2s aprox
	[data.SF.spellId] = {seconds=.5,timer=CreateFrame("Cooldown","LibBalancePowerTrackerSFTimer",LibBalancePowerTrackerTimerFrame)}, --0.6s aprox
}
for k,v in pairs(timers) do	if tonumber(k)~= nil then v.timer:SetScript("OnHide",function() if vars.spellQ:RemoveAllSpellsById(k) then LBPT:ChangedState() end end)	end end
----FRAME--------------------------------------------------------------------------------
local frame = CreateFrame("Frame","LibBalancePowerTrackerEventFrame",UIParent);
-----------------------------------------------------------------------------------------


--ENERGY FUNCTIONS-----------------------------------------------------------------------
local actualizarEnergiaWR = {
	[-13] = function(ultimo,_) return -13,ultimo end,
	[-14] = function() return -14,-13 end,
	[-26] = function() return -13,-13 end,
	[-27] = function(_,penultimo) if penultimo == -14 then	return -14,-13
								  else						return -13,-14
								  end
			end,
}
local nextWRenergy = { --ultimo, penultimo
	[-13] = {
		[-13] = -14,
		[-14] = -13,
	},
	[-14] = {
		[-13] = -13,
		[-14] = -13,  --unreachable
	}
}
local energyFromSpell={
	[data.SF.spellId]={
		moon	= function(_,ultimoWR,penultimoWR) return              0,ultimoWR,penultimoWR end,
		sun		= function(_,ultimoWR,penultimoWR) return data.SF.energy,ultimoWR,penultimoWR end,
		none 	= function(_,ultimoWR,penultimoWR) return data.SF.energy,ultimoWR,penultimoWR end,
	},
	[data.WR.spellId]={
		moon 	= function(_,ultimoWR,penultimoWR) 
						local n = nextWRenergy[ultimoWR][penultimoWR];
						return n,actualizarEnergiaWR[n](ultimoWR,penultimoWR); 
				end,
		sun 	= function(_,ultimoWR,penultimoWR) 
						local n = nextWRenergy[ultimoWR][penultimoWR];
						return 0,actualizarEnergiaWR[n](ultimoWR,penultimoWR); 
				end,
		none 	= function(_,ultimoWR,penultimoWR) 
						local n = nextWRenergy[ultimoWR][penultimoWR];
						return n,actualizarEnergiaWR[n](ultimoWR,penultimoWR); 
				end,
	},
	[data.SS.spellId]={
		moon 	= function(_,ultimoWR,penultimoWR) 	return -data.SS.energy,ultimoWR,penultimoWR; end,
		sun 	= function(_,ultimoWR,penultimoWR) 	return  data.SS.energy,ultimoWR,penultimoWR; end,
		none 	= function(e,ultimoWR,penultimoWR) 	if e<0 then return -data.SS.energy,ultimoWR,penultimoWR; else return data.SS.energy,ultimoWR,penultimoWR; end end,
	},
}
local doubleEnergyFromSpell={
	[data.SF.spellId]={
		moon	= function(_,ultimoWR,penultimoWR) return                0,ultimoWR,penultimoWR end,
		sun		= function(_,ultimoWR,penultimoWR) return 2*data.SF.energy,ultimoWR,penultimoWR end,
		none 	= function(_,ultimoWR,penultimoWR) return 2*data.SF.energy,ultimoWR,penultimoWR end,
	},
	[data.WR.spellId]={
		moon 	= function(_,ultimoWR,penultimoWR) 
						local n1 = nextWRenergy[ultimoWR][penultimoWR];
						local n2 = nextWRenergy[n1][ultimoWR];
						return n1+n2,actualizarEnergiaWR[n1+n2](ultimoWR,penultimoWR); 
				end,
		sun 	= function(_,ultimoWR,penultimoWR) 
						local n1 = nextWRenergy[ultimoWR][penultimoWR];
						local n2 = nextWRenergy[n1][ultimoWR];
						return 0,actualizarEnergiaWR[n1+n2](ultimoWR,penultimoWR); 
				end,
		none 	= function(_,ultimoWR,penultimoWR) 
						local n1 = nextWRenergy[ultimoWR][penultimoWR];
						local n2 = nextWRenergy[n1][ultimoWR];
						return n1+n2,actualizarEnergiaWR[n1+n2](ultimoWR,penultimoWR); 
				end,
	},
	[data.SS.spellId]={
		moon 	= function(_,ultimoWR,penultimoWR) 	return -data.SS.energy,ultimoWR,penultimoWR; end,
		sun 	= function(_,ultimoWR,penultimoWR) 	return  data.SS.energy,ultimoWR,penultimoWR; end,
		none 	= function(e,ultimoWR,penultimoWR) 	if e<0 then return -data.SS.energy,ultimoWR,penultimoWR; else return data.SS.energy,ultimoWR,penultimoWR; end end,
	},
}
local function EnergyFromSpell(id,direction,energy,ultimoWR,penultimoWR,euphoria,eclipse) --returns energy from spellid, direction, energy & special
	if euphoria and not eclipse then
		return doubleEnergyFromSpell[id][direction](energy,ultimoWR,penultimoWR);
	else
		return energyFromSpell[id][direction](energy,ultimoWR,penultimoWR,eclipse);
	end
end
-----------------------------------------------------------------------------------------


--Aux functions
function LBPT.MissChance() return 0; end --will be modified
local function UpdateSpellcastSentEvent()
	if (next(eclipseProbCallbacks) ~= nil or next(statCallbacks) ~= nil) and options.enabled and options.foresee and vars.isBalance then
		LibBalancePowerTrackerEventFrame:RegisterEvent("UNIT_SPELLCAST_SENT");
		function LBPT.MissChance()
			local diff = vars.unitLevelSent - UnitLevel("player");
			if diff <= -4 then return 0;elseif diff > 5 then diff = 5;end
			if vars.unitIsPCSent then return 1-min(missTablePvP[diff]+GetCombatRatingBonus(8)*.01,1);end
			return 1-min(missTablePvE[diff]+GetCombatRatingBonus(8)*.01,1);
		end
	else
		LibBalancePowerTrackerEventFrame:UnregisterEvent("UNIT_SPELLCAST_SENT");
		function LBPT.MissChance() return 0; end;
	end
end
local function UpdateFunctions()
	callBacksActivated.reduced,callBacksActivated.full = next(reducedCallbacks) ~= nil,next(callbacks) ~= nil;
	callBacksActivated.eclipseProb,callBacksActivated.stat = next(eclipseProbCallbacks) ~= nil,next(statCallbacks) ~= nil;
	if elements ~= 0 then
		if (callBacksActivated.eclipseProb or callBacksActivated.stat) and callBacksActivated.reduced then
			function LBPT:ChangedState(real) if LBPT:RecalcEnergy() then return end 	LBPT:RecalcWays();	LBPT:FireCallbacks(); if real then LBPT:FireReducedCallbacks() end;	end;--aded reduced callbacks and stat analysis
		elseif callBacksActivated.reduced then
			function LBPT:ChangedState(real) if LBPT:RecalcEnergy() then return end 						LBPT:FireCallbacks(); if real then LBPT:FireReducedCallbacks() end;	end;--aded reduced callbacks
		elseif (callBacksActivated.eclipseProb or callBacksActivated.stat) then
			function LBPT:ChangedState()	 if LBPT:RecalcEnergy() then return end 	LBPT:RecalcWays();	LBPT:FireCallbacks();												end;--added stat analysis 
		else
			function LBPT:ChangedState() 	 if LBPT:RecalcEnergy() then return end 						LBPT:FireCallbacks();												end;--only full callbacks (most common)
		end
		
	else 	
			function LBPT:ChangedState() 	vars.changedState=true	end;--Default, no callbacks, just waiting till someone calls GetEclipseEnergyInfo()
	end
	UpdateSpellcastSentEvent()
end
local function UpdateEuphoria()	vars.euphoria = select(5,GetTalentInfo(1,7)) * .12; end --Checked on shapeshift_forms_updated on load, on Player_login on reload
local function CheckEcplipseBuff() vars.eclipse = (UnitBuff('player',select(1,GetSpellInfo(data.SolarEclipse.spellId))) and 100) or (UnitBuff('player',select(1,GetSpellInfo(data.LunarEclipse.spellId))) and -100) end

--Loading
frame:SetScript("OnEvent",  function(self, event, ...) 	LBPT[event](self,...)	end);
frame:RegisterEvent("PLAYER_LOGIN"); 
function LBPT:PLAYER_LOGIN() playerGUID=UnitGUID("player");vars.isDruid = select(2,UnitClass('player'))=="DRUID"; if vars.isDruid then LibBalancePowerTracker:RegisterFunctionsLog() LBPT:ReCheck();end end;

function LBPT:ReCheck()
	vars.isBalance = GetSpellCooldown(data.SS.name)~=nil;
	UpdateSpellcastSentEvent()
	UpdateEuphoria()
	CheckEcplipseBuff()
	
	if options.enabled and vars.isDruid then
		LibBalancePowerTrackerEventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");	 
		LibBalancePowerTrackerEventFrame:RegisterEvent("CHARACTER_POINTS_CHANGED");	
		LibBalancePowerTrackerEventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
	else
		LibBalancePowerTrackerEventFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED");	 
		LibBalancePowerTrackerEventFrame:UnregisterEvent("CHARACTER_POINTS_CHANGED");
		LibBalancePowerTrackerEventFrame:UnregisterEvent("UPDATE_SHAPESHIFT_FORMS");
	end
		
	if options.enabled and vars.isBalance then
		if options.foresee then
			LibBalancePowerTrackerEventFrame:RegisterEvent("UNIT_SPELLCAST_START");
			LibBalancePowerTrackerEventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
			LBPT:CreateCombatLogFunction(true)
		else
			LibBalancePowerTrackerEventFrame:UnregisterEvent("UNIT_SPELLCAST_START");
			LibBalancePowerTrackerEventFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
			LBPT:CreateCombatLogFunction(false)
		end
		LibBalancePowerTrackerEventFrame:RegisterEvent("PLAYER_DEAD");
		LibBalancePowerTrackerEventFrame:RegisterEvent("ECLIPSE_DIRECTION_CHANGE");
		
		LibBalancePowerTrackerEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");	
		LibBalancePowerTrackerEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
		
		--Check tier
		LibBalancePowerTrackerEventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
		setmetatable(vars.tiers.tierPieceCount, {__index = function () return 0 end})
		for k in pairs(vars.tiers) do if tonumber(k) then LBPT:PLAYER_EQUIPMENT_CHANGED(k,GetInventoryItemID("player", k)) end end
		
		vars.spellQ:Clear();
		vars.direction = GetEclipseDirection()
		LBPT:ChangedState(true);
	else 
		LibBalancePowerTrackerEventFrame:UnregisterEvent("UNIT_SPELLCAST_START");
		LibBalancePowerTrackerEventFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
		LibBalancePowerTrackerEventFrame:UnregisterEvent("PLAYER_DEAD");
		LibBalancePowerTrackerEventFrame:UnregisterEvent("ECLIPSE_DIRECTION_CHANGE");	
		
		LibBalancePowerTrackerEventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");	
		LibBalancePowerTrackerEventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
		
		LibBalancePowerTrackerEventFrame:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
		
		--Reset values
		vars.spellQ:Clear();
		vars.computedEnergy,vars.direction,vars.computedVirtualEnergy,vars.vDirection,vars.computedVirtualEclipse = 0,"none",0,"none",false;
		vars.inverseCumulativeDistributionFunction = function() return 0,"none",0,"none",false; end
		vars.eclipseProb = 0
		
		--Propagate values
		LBPT:FireCallbacks()
		LBPT:FireReducedCallbacks()
		for k,v in pairs(statCallbacks) do v(vars.inverseCumulativeDistributionFunction);end;
		for k,v in pairs(eclipseProbCallbacks) do v(vars.eclipseProb);end;
	end
end


--Combat events-------------
local function UnitByName(name)
	if select(1,UnitName("target"))==name then return "target";
	elseif select(1,UnitName("mouseover"))==name then return "mouseover";
	elseif select(1,UnitName("focus"))==name then return "focus";
	elseif select(1,UnitName("player"))==name then return "player";
	elseif select(1,UnitName("targettarget"))==name then return "targettarget";
	end
	
	--boss
	for i=1,4 do if select(1,UnitName("boss"..i))==name then return "boss"..i; end end
	
	--arena
	if select(1,IsActiveBattlefieldArena()) then
		for i=1,5 do if select(1,UnitName("arena"..i))==name then return "arena"..i; end end
	end

	if GetNumRaidMembers()==0 then
		--party
		if GetNumPartyMembers() ~=0 then for i=1,5 do if select(1,UnitName("party"..i))==name then return "party"..i; end end end
	else
		--raid
		for i=1,40 do if select(1,UnitName("raid"..i))==name then return "raid"..i; end	end
	end

	return "target";
end
local spellsUsed = {
	[data.WR.name] = tonumber(data.WR.spellId),
	[data.SS.name] = tonumber(data.SS.spellId),
	[data.SF.name] = tonumber(data.SF.spellId),
	[data.WR.spellId] = tostring(data.WR.name),
	[data.SS.spellId] = tostring(data.SS.name),
	[data.SF.spellId] = tostring(data.SF.name),
}
do --COMBAT LOG HANDLER -------------------------------------------------------
	function LBPT:COMBAT_LOG_EVENT_UNFILTERED()
	end
	local function SetEclipseDirection(timestamp)
		local energy = UnitPower("player" , 8);
		if energy ==100 then vars.direction = "moon"; 		vars.ecTime,vars.eclipse = timestamp, 100
		elseif energy == -100 then vars.direction = "sun";	vars.ecTime,vars.eclipse = timestamp,-100
		elseif (vars.direction == "moon" and energy <=0) or (vars.direction == "sun"  and energy >=0) or (vars.direction == "none") then
			vars.eclipse=false;
		--elseif abs(energy)<=90 then vars.direction = GetEclipseDirection();
		end
	end
	local notEnergy = {
		[data.SF.spellId] = "moon",
		[data.WR.spellId] = "sun"
	}
	local eclipseEnergy = {
		[data.LunarEclipse.spellId] = -100,
		[data.SolarEclipse.spellId] =  100,
	}
	local unfilteredCombatLogEnergize = {
		[data.EE.spellId]	= function(amountEnergy)
								if amountEnergy > 10 then 
									vars.spellQ:RemoveFlyingSpell(data.SF.spellId)
								elseif actualizarEnergiaWR[amountEnergy] then
									vars.spellQ:RemoveFlyingSpell(data.WR.spellId)
									vars.lastWRenergy,vars.formerlastWRenergy = actualizarEnergiaWR[amountEnergy](vars.lastWRenergy,vars.formerlastWRenergy)
								end
							end,
		[data.SSE.spellId] 	= function() 
								vars.spellQ:RemoveFlyingSpell(data.SS.spellId)
							end,
	}	
	local unfilteredCombatLogTable = {
		SPELL_ENERGIZE 	= function(id,amount,typeEnergy,timestamp)	if (typeEnergy == 8) then
																		id = unfilteredCombatLogEnergize[id] 
																		if id then id(amount); end;

																		SetEclipseDirection(timestamp);
																		LBPT:ChangedState(true)
																	end
						end,
		SPELL_MISSED 	= function(id)	if spellsUsed[id] then
											vars.spellQ:RemoveFlyingSpell(id)
											LBPT:ChangedState();
										end;
						end,
		SPELL_DAMAGE 	= function(id,_,_,timestamp)	if notEnergy[id] == vars.direction then
															if abs(timestamp-vars.ecTime)<.5 then return end
		
															vars.spellQ:RemoveFlyingSpell(id)
															if id == data.WR.spellId then
																_,vars.lastWRenergy,vars.formerlastWRenergy = EnergyFromSpell(id,vars.direction,vars.computedEnergy,vars.lastWRenergy,vars.formerlastWRenergy)
															end
															LBPT:ChangedState()
														end;
						end,
		SPELL_CAST_FAILED = function(id,msg) if msg ~= SPELL_FAILED_NOT_READY and msg ~= SPELL_FAILED_SPELL_IN_PROGRESS and vars.spellQ:InterruptedCastingSpell(id) then LBPT:ChangedState() end end,
		--SPELL_AURA_APPLIED = function(id) if eclipseEnergy[id] then vars.eclipse = eclipseEnergy[id] end end,
		SPELL_AURA_REMOVED = function(id) if eclipseEnergy[id] and vars.eclipse then vars.eclipse = false LBPT:ChangedState() end end,
	}
	function LBPT:CreateCombatLogFunction(foresee)
		if foresee then
			function LBPT:COMBAT_LOG_EVENT_UNFILTERED(timestamp,event,_,gUIDor,_,_,_,destGUID,_,_,_,spellId,_,_,amountEnergy,typeEnergy)
				if (gUIDor == playerGUID) then 
					event = unfilteredCombatLogTable[event] 
					if event then event(spellId,amountEnergy,typeEnergy,timestamp) end
				elseif (destGUID == playerGUID) and event=="SPELL_INTERRUPT" then
					if vars.spellQ:InterruptedCastingSpell(amountEnergy) then LBPT:ChangedState() end
				end
			end
		else
			function LBPT:COMBAT_LOG_EVENT_UNFILTERED( timestamp,event,_,gUIDor,_,_,_,_,_,_,_,_,_,_,_,typeEnergy)
				if (gUIDor == playerGUID) and (event=="SPELL_ENERGIZE") and (typeEnergy == 8) then SetEclipseDirection(timestamp) LBPT:ChangedState(true) end;
			end
		end
	end
end
function LBPT:UNIT_SPELLCAST_SENT(unitID,name,_,target) 
	if unitID == "player" and spellsUsed[name] then
		unitID = UnitByName(target)
		vars.unitIsPCSent	= UnitIsPlayer(unitID);
		vars.unitLevelSent	= UnitLevel(unitID);
		if vars.unitLevelSent == -1 then vars.unitLevelSent = UnitLevel("player") + 3; end
	end
end
function LBPT:UNIT_SPELLCAST_START(unit,_,_,num,id)
	if unit == "player" and spellsUsed[id] then
		vars.spellQ:BeginCastingSpell(id,num,LBPT.MissChance())
		LBPT:ChangedState()
	end
end
function LBPT:UNIT_SPELLCAST_SUCCEEDED(unit,_,_,num,id)
	if unit == "player" and spellsUsed[id] then
		unit=timers[id];
		unit.timer:SetCooldown(GetTime(),unit.seconds)
		if vars.spellQ:FinishCastingSpell(id,num,LBPT.MissChance()) then
			LBPT:ChangedState()
		end
	end
end

function LBPT:PLAYER_DEAD() LibBalancePowerTrackerEventFrame:RegisterEvent("PLAYER_ALIVE"); vars.spellQ:Clear()	LBPT:ChangedState(true);	end; --Reset queue & clear energy when die

--Issues with dying because of a crit with 4p PvP bonus 
function LBPT:PLAYER_ALIVE() 
	LibBalancePowerTrackerEventFrame:UnregisterEvent("PLAYER_ALIVE"); 
	if (UnitPower("player",8) ~= 0) then	
		if not vars.pvpFrame then
			vars.pvpFrame = CreateFrame("Frame","LibBalancePowerTrackerPvPFrame",UIParent);
			vars.pvpFrame:SetScript("OnUpdate", function() if UnitPower("player",8)==0 then vars.pvpFrame:Hide(); LBPT:ChangedState(true);end;end); 
		end
		vars.pvpFrame:Show()
	end;
end; 


do --Tier bonus check
	local broadcasted = {}
	setmetatable(broadcasted, {__index = function () return 0 end})
	timers.broadcastTier:SetScript("OnHide",function() 
		for k,v in pairs(vars.tiers.tierPieceCount) do
			if broadcasted[k] ~= v then --broadcast
				if broadcasted[k] < v then --gained bonus
					for i = broadcasted[k]+1,v do
						if data.balanceTiersItemId[k]["bonus"..i.."p"] then print("|c00a080ffLibBalancePowerTracker|r: Tier"..k.." "..i.."p bonus detected.") end
					end
				else --lost bonus
					for i = v+1,broadcasted[k] do
						if data.balanceTiersItemId[k]["bonus"..i.."p"] then print("|c00a080ffLibBalancePowerTracker|r: No tier"..k.." "..i.."p bonus detected.") end
					end
				end
				broadcasted[k] = v
			end
		end
	end)
	function LBPT:PLAYER_EQUIPMENT_CHANGED(slot,hasItem)
		local setInSlot = vars.tiers[slot]
		if setInSlot then						--print("retirado objeto de "..slot)
			vars.tiers[slot]=false;
			vars.tiers.tierPieceCount[setInSlot]=vars.tiers.tierPieceCount[setInSlot]-1 --print("Tienes "..vars.tiers.tierPieceCount[setInSlot].." piezas de tier "..setInSlot)
			
			for i = 0,9 do		
				if vars.tiers.tierPieceCount[setInSlot] == i-1 and data.balanceTiersItemId[setInSlot]["bonus"..i.."p"] and LBPT.BonusTier[setInSlot][i].Off() then timers.broadcastTier:SetCooldown(GetTime(),1)  end
			end
		end
		
		if hasItem and setInSlot ~= nil then 				--print("se intenta poner una pieza en "..slot)
			local id = GetInventoryItemID("player", slot)	--print("el id de la pieza es "..tostring(id))
			for k,v in pairs(data.balanceTiersItemId) do	--print("buscando en tier "..k)
				if v[slot] and v[slot][id] then				--print("encontrado en tier "..k)
					vars.tiers[slot]=k;
					vars.tiers.tierPieceCount[k]=vars.tiers.tierPieceCount[k]+1 --print("Tienes "..vars.tiers.tierPieceCount[k].." piezas de tier "..k);
					
					for i = 0,9 do
						if vars.tiers.tierPieceCount[k] == i and v["bonus"..i.."p"] and LBPT.BonusTier[k][i].On() then timers.broadcastTier:SetCooldown(GetTime(),1) end
					end
					return
				end
			end
		end
	end
end

--Direction & energy when teleporting 
function LBPT:PLAYER_ENTERING_WORLD()		vars.spellQ:Clear();	LBPT:ChangedState(true); end; 
function LBPT:ECLIPSE_DIRECTION_CHANGE(dir) if dir == "none" then 	vars.direction = dir; LBPT:ChangedState(true); end end; 

--Talent change events
function LBPT:ACTIVE_TALENT_GROUP_CHANGED() LBPT:ReCheck(); end; 
function LBPT:CHARACTER_POINTS_CHANGED()	LBPT:ReCheck(); end;
--Talent check events
function LBPT:UPDATE_SHAPESHIFT_FORMS()	vars.direction = GetEclipseDirection() UpdateEuphoria(); CheckEcplipseBuff(); LBPT:ChangedState(true); end;

--ChangedState
function LBPT:ChangedState() vars.changedState=true end;--will be changed when registeriong callbacks (UpdateFunctions())

do --Recalc Energy function
	--Staying at 0 energy bug workaround
	local reallyZeroEnergy=false;
	local timeShown = 0;
	frame:SetScript("OnShow",	function() timeShown = GetTime()+.5; end); 
	frame:SetScript("OnUpdate", function()	if UnitPower("player",8) ~= 0  then frame:Hide(); LBPT:ChangedState(true); 
											elseif (timeShown < GetTime()) then reallyZeroEnergy = true LBPT:ChangedState(true) frame:Hide(); 
											elseif (elements == 0) then frame:Hide(); 
											end; end); 


	--Recalc Energy function
	local function ExtraEnergy(energy,direction) --computes extra energy
		local getNext = vars.spellQ:iterator();
		local v = getNext();
		local temp,ultimoWR,penutlimoWR,eclipse = 0,vars.lastWRenergy,vars.formerlastWRenergy,vars.eclipse
		
		while v do
			temp,ultimoWR,penutlimoWR = EnergyFromSpell(v.n,direction,energy,ultimoWR,penutlimoWR,false,eclipse)
			energy = energy + temp
			v = getNext();
		
			if energy>=100 then 
				energy = 100
				direction = "moon"
				eclipse = energy
			elseif energy<=-100 then 
				energy = -100 
				direction = "sun";
				eclipse = energy;
			elseif (direction == "moon" and energy <=0) or (direction == "sun"  and energy >=0) or (direction == "none") then
				eclipse = false;
			end
		end

		return energy,direction,eclipse
	end
	
	function LBPT:RecalcEnergy()
		local energy = UnitPower("player" , 8);

		if energy == 0 then
			if not reallyZeroEnergy then 
				frame:Show()
				return true
			end
		else 
			reallyZeroEnergy=false
		end
		
		vars.computedEnergy,vars.changedState = energy, false;
		
		if options.foresee then
			vars.spellQ:RemoveTimedOutFlyingSpell(4);
			vars.computedVirtualEnergy,vars.vDirection,vars.computedVirtualEclipse = ExtraEnergy(energy,vars.direction)
			return
		end
		
		vars.computedVirtualEnergy,vars.vDirection,vars.computedVirtualEclipse = energy,vars.direction,false;
	end
end

do --Tree ADT functions
	local function TreeEnergyFromSpell(id,direction,energy,vE,lWR,fWR,double)
		local temp,lWR,fWR = EnergyFromSpell(id,direction,energy,lWR,fWR,double,vE);
		energy = energy + temp;
		
		if energy>=100 then			return    100,   "moon",  100,lWR,fWR;
		elseif energy<=-100 then 	return   -100,    "sun", -100,lWR,fWR;
		elseif (direction == "moon" and energy <=0) or (direction == "sun"  and energy >=0) or (direction == "none") then
									return energy,direction,false,lWR,fWR;
		else						return energy,direction,   vE,lWR,fWR;
		end
	end
	local function TreeApplySpell(parentOriginal,sonMiss,sonNormal,sonDouble,element)
		local prob, energy, direction, virtualEclipse, lWR,fWR = parentOriginal.prob,parentOriginal.energy,parentOriginal.direction,parentOriginal.virtualEclipse, parentOriginal.lWR,parentOriginal.fWR;
			
		if prob == 0 then sonMiss.prob,sonNormal.prob,sonDouble.prob = 0,0,0; return; end
		
		local euphoriaProb = ((((direction == "moon" and energy >=-40) or (direction == "sun"  and energy <=40) or (direction == "none")) and not virtualEclipse ) and vars.euphoria) or 0;

		sonMiss.prob = prob * element.mc;
		sonDouble.prob = prob *(1-element.mc)* euphoriaProb 
		sonNormal.prob = prob *(1-element.mc)*(1-euphoriaProb)
		
		if sonMiss.prob ~=0 then sonMiss.energy,sonMiss.direction,sonMiss.virtualEclipse,sonMiss.lWR,sonMiss.fWR = energy,direction,virtualEclipse,lWR,fWR;end
		if sonDouble.prob~=0 then sonDouble.energy,sonDouble.direction,sonDouble.virtualEclipse,sonDouble.lWR,sonDouble.fWR = TreeEnergyFromSpell(element.n,direction,energy,virtualEclipse,lWR,fWR,true);end
		if sonNormal.prob~=0 then sonNormal.energy,sonNormal.direction,sonNormal.virtualEclipse,sonNormal.lWR,sonNormal.fWR = TreeEnergyFromSpell(element.n,direction,energy,virtualEclipse,lWR,fWR);end
	end
	local function checkNext(node,now) --return true si debemos pasar al siguiente (insertaremos cuando encontremos uno con energia mayor)
		return node.energy > now.energy
	end
	function LBPT:RecalcWays(forced)
		local direction,energy,getNext = vars.direction,UnitPower("player" , 8),vars.spellQ:iterator();
		
		--Aclarar que tenemos en cuenta que el %miss se calcula cuando el hechizo se envía, también contamos con 
		--que euforia no actúa como la tabla de ataques mele (se hacen dos tiradas independientes, la primera para 
		--ver si el hechizo acierta y la segunda para ver si salta euforia)
		
		--[[ WAYTREE as a Table (First child is miss, second is normal and third is Euphoria
		--(1)(2)(3)(4)(5)(6)(7)(8)(9)(10)(11)(12)(13)(14)(15)(16)(17)(18)(19)(20)(21)(22)(23)(24)(25)(26)(27)--]]
		
		local tempTable,wayEnd,v,level,idFirstSpell  = vars.wayTable, 1,getNext(),0,false;
		if not tempTable[1] then tempTable[1] = {} end
			if v then idFirstSpell = v.n end
			tempTable[1].lWR = vars.lastWRenergy
			tempTable[1].fWR = vars.formerlastWRenergy
			tempTable[1].prob = 1;
			tempTable[1].energy = energy;
			tempTable[1].direction = direction;
			tempTable[1].virtualEclipse = vars.eclipse;
		
		while v and level <= vars.max_levels do
			for i = 1,wayEnd do 
				if not tempTable[i+wayEnd] then  tempTable[i+wayEnd] = {} end
				if not tempTable[i+2*wayEnd] then tempTable[i+2*wayEnd] = {} end
				TreeApplySpell(tempTable[i],tempTable[i], tempTable[i+wayEnd] , tempTable[i+2*wayEnd] ,v)
			end
			wayEnd,v,level=wayEnd*3,getNext(),level+1;
		end
		
		if callBacksActivated.eclipseProb or forced then --Eclipse probability calc if only the eclipse calc is selected
			local a,vE = 0,false
			for i=1,wayEnd do 
				if tempTable[i].prob>0 and tempTable[i].direction ~= direction then
					vE,a = tempTable[i].direction,a + tempTable[i].prob;
				end;
			end;
			if vE == "sun" then
				a=-a
			end
			
			if vars.eclipseProb ~= a then --Eclipse chance has changed
				vars.eclipseProb = a;for k,v in pairs(eclipseProbCallbacks) do v(a);end;
			end
		end
		
		if callBacksActivated.stat or forced then
			--función de distribución como lista doblemente enlazada (cumulative distribution as doubly linked list) 
			local first = false;
			local last;
			local now;
			
			for i = 1,wayEnd do 
				if tempTable[i].energy and tempTable[i].prob>0 then
					if not first then --si está vacía la inicializamos
						first=tempTable[i];
						last =tempTable[i];
						tempTable[i].nextItem = nil;
						tempTable[i].previousItem = nil;		
					else --si no está vacía, nos ponemos en el primero y evaluamos, si tenemos que insertar, insertamos, si no, pasamos al siguiente
						now = first;
						while now do
							if checkNext(tempTable[i],now,direction) then  --no debemos insertar, sino pasar al siguiente
								if now.nextItem then  --hay siguiente																			
									now = now.nextItem;
								else -- no hay siguiente, insertamos al final de la lista
									tempTable[i].previousItem = now;
									tempTable[i].nextItem = nil;
									now.nextItem = tempTable[i]
									last = tempTable[i];
									now = false;
								end
							elseif (tempTable[i].energy == now.energy) and (tempTable[i].virtualEclipse == now.virtualEclipse) then --no insertamos, actualizamos el valor
								now.prob=now.prob+tempTable[i].prob
								now = false;
							else -- hay que insertar, moviendo el item una posicion a la derecha
								if now.previousItem then --hay anterior (no es el primero), hay que desplazar los valores una posición a la derecha
									tempTable[i].previousItem = now.previousItem;
									tempTable[i].nextItem = now;
									now.previousItem.nextItem = tempTable[i];
									now.previousItem = tempTable[i];
									now=false;
								else --es el primero, hay que insertar al principio de la tabla 
									tempTable[i].previousItem = nil;
									tempTable[i].nextItem = now;
									first=tempTable[i];
									now.previousItem = tempTable[i];
									now=false;
								end
							end
						end 
					end
				end
			end
			
			if first.energy == -100 then
				local now,temp = first.nextItem;	
				while now do 
					temp = now
					if now.direction == first.direction then 
						now.previousItem.nextItem = now.nextItem
						now.nextItem.previousItem = now.previousItem
						now.previousItem = nil
						now.nextItem = first
						first.previousItem = now
						first = now
					end
					now = temp.nextItem;	
				end
			elseif last.energy == 100 then
				local now,temp = last.previousItem;	
				while now do 
					temp = now
					if now.direction == last.direction then 
						now.previousItem.nextItem = now.nextItem
						now.nextItem.previousItem = now.previousItem
						now.previousItem = last
						now.nextItem = nil
						last.nextItem = now
						last = now
					end
					now = temp.previousItem;	
				end
			end

			--[[now=first;
			print("BEGIN")
			while now do
				print(now.energy..": "..tostring(now.virtualEclipse).." = "..now.prob)
				now = now.nextItem;
			end
			print("END")--]]
			
			--funcion (valor) devuelve la mínima energía que tendrás con un valor% de seguridad
			-- "tienes un valor*100% de tener como mínimo funcion(valor) energía
			if (direction == "sun") or (direction=="none" and idFirstSpell == data.SF.spellId) or (direction=="none" and idFirstSpell == data.SS.spellId and energy>=0) then --empiezo comprobando probabilidades desde el final
				vars.inverseCumulativeDistributionFunction = 	function(value) 
					if value>1 then value = 1 
					elseif value <0 then value = 0 end 
					local last = last;		
					while last do 
						value=value-last.prob;	
						if value<=0 then 
							return energy,direction,last.energy,last.direction,last.virtualEclipse;		
						else last = last.previousItem;	
						end 
					end	
				end	
			else --empiezo comprobando probabilidades desde el principio
				vars.inverseCumulativeDistributionFunction = function(value) 
					if value>1 then value = 1 elseif value <0 then value = 0 end 
					local first = first;	
					while first do 
						value=value-first.prob;	
						if value<=0 then 
							return energy,direction,first.energy,first.direction,first.virtualEclipse;	
						else 
							first = first.nextItem 	
						end	
					end	
				end	
			end
			for k,v in pairs(statCallbacks) do v(vars.inverseCumulativeDistributionFunction);end;
		end
	end
end

--Calling functions
function LBPT:FireCallbacks() 			for k,v in pairs(callbacks) 		do v(vars.computedEnergy,vars.direction,vars.computedVirtualEnergy,vars.vDirection,vars.computedVirtualEclipse); 	end; end;
function LBPT:FireReducedCallbacks() 	for k,v in pairs(reducedCallbacks) 	do v(vars.computedEnergy,vars.direction); 																	end; end;
--Called functions
function LibBalancePowerTracker:GetEclipseEnergyInfo(forced)	if vars.changedState or forced then LBPT:RecalcEnergy() end return vars.computedEnergy,vars.direction,vars.computedVirtualEnergy,vars.vDirection,vars.computedVirtualEclipse;	end;
function LibBalancePowerTracker:GetEclipseChance(forced)		if (not callBacksActivated.eclipseProb) or vars.changedState or forced then LBPT:RecalcEnergy()	LBPT:RecalcWays(not callBacksActivated.eclipseProb)	end return vars.eclipseProb; end;
function LibBalancePowerTracker:GetEnergyFunction(forced)		if (not callBacksActivated.stat) 		or vars.changedState or forced then LBPT:RecalcEnergy()	LBPT:RecalcWays(not callBacksActivated.stat )		end return vars.inverseCumulativeDistributionFunction; end;
function LibBalancePowerTracker:RegisterReducedCallback(callback)
	lastCallback=lastCallback+1
	elements=elements+1
	reducedCallbacks[lastCallback]=callback;
	local energy,direction = LibBalancePowerTracker:GetEclipseEnergyInfo()
	callback(energy,direction)
	UpdateFunctions()
	return lastCallback
end
function LibBalancePowerTracker:RegisterFullCallback(callback)
	lastCallback=lastCallback+1
	elements=elements+1
	callbacks[lastCallback]=callback;
	callback(LibBalancePowerTracker:GetEclipseEnergyInfo())
	UpdateFunctions()
	return lastCallback
end
function LibBalancePowerTracker:RegisterEclipseProbCallback(callback)
	lastCallback=lastCallback+1
	elements=elements+1
	LBPT:RecalcWays()
	eclipseProbCallbacks[lastCallback]=callback;
	callback(LibBalancePowerTracker:GetEclipseChance())
	UpdateFunctions()
	return lastCallback
end
function LibBalancePowerTracker:RegisterStatCallback(callback)
	lastCallback=lastCallback+1
	elements=elements+1
	statCallbacks[lastCallback]=callback;
	callback(LibBalancePowerTracker:GetEnergyFunction())
	UpdateFunctions()
	return lastCallback
end
function LibBalancePowerTracker:UnregisterCallback(id)
	if reducedCallbacks[id] then
		reducedCallbacks[id]=nil;
	elseif callbacks[id] then
		callbacks[id]=nil;
	elseif eclipseProbCallbacks[id] then
		eclipseProbCallbacks[id]=nil;
	elseif statCallbacks[id] then
		statCallbacks[id]=nil;
	else
		return true;
	end
	elements=elements-1
	UpdateFunctions()
end
function LibBalancePowerTracker:GetVersion()	return version[1],version[2],version[3]; end;
function LibBalancePowerTracker:GetEnabled()	return options.enabled; end;

--Log
function LibBalancePowerTracker:RegisterFunctionsLog()
	if LogBalancePowerTracker and LogBalancePowerTracker.Register and type(LogBalancePowerTracker.Register)=="function" then
		local logVars={energyCallbackId=false, playing=false};
		local tierTableTemp={};
		setmetatable(tierTableTemp, {__index = function () return 0 end})
		local function CompareTierTables(new)
			for k,v in pairs(new) do
				local bef = tierTableTemp[k]
				if v ~= bef then
					tierTableTemp[k] = v;
					if v<bef then
						--lost?
						if v == 3 and data.balanceTiersItemId[k].bonus4p then return "4off"..k end
						if v == 1 and data.balanceTiersItemId[k].bonus2p then return "2off"..k end
					else
						--gain?
						if v == 4 and data.balanceTiersItemId[k].bonus4p then return "4on"..k end
						if v == 2 and data.balanceTiersItemId[k].bonus2p then return "2on"..k end
					end
				end
			end
		end
		local tempEnergy,tempvEnergy,tempDir,tempvDir,tempRE=0,0,"none","none",false;
		
		LogBalancePowerTracker.Register(
			vars.spellQ.FromNumberToTable, --Function to turn numbers into tables 
			function(functionToCall) --function to call when log is enabled/disabled (to disable it, just call it with no parameters
				if functionToCall and type(functionToCall)=="function" then
					frame:SetScript("OnEvent",  function(self, event, ...) 	
													LBPT[event](self,...)
													if event ~= "PLAYER_EQUIPMENT_CHANGED" then
														functionToCall(event,vars.computedEnergy,vars.direction,vars.computedVirtualEnergy,vars.vDirection,vars.spellQ:tonumber(),...) 
													else
														local tierChanged = CompareTierTables(vars.tiers.tierPieceCount)
														if tierChanged then
															functionToCall("TIER_CHANGE",vars.computedEnergy,vars.direction,vars.computedVirtualEnergy,vars.vDirection,vars.spellQ:tonumber(),tierChanged)
														end
													end
												end);
					for k,v in pairs(timers) do	if tonumber(k)~= nil then v.timer:SetScript("OnHide",function() if vars.spellQ:RemoveAllSpellsById(k) then LBPT:ChangedState() functionToCall("TIMER",vars.computedEnergy,vars.direction,vars.computedVirtualEnergy,vars.vDirection,vars.spellQ:tonumber(),k) end end)	end end
				
					return vars.computedEnergy,vars.direction,vars.computedVirtualEnergy,vars.vDirection,vars.spellQ:tonumber()
				else
					frame:SetScript("OnEvent",  function(self, event, ...) 	LBPT[event](self,...)	end);
					for k,v in pairs(timers) do	if tonumber(k)~= nil then v.timer:SetScript("OnHide",function() if vars.spellQ:RemoveAllSpellsById(k) then LBPT:ChangedState() end end)	end end
				end
			end,
			function(enable) --function to call when enable/disable playing a log
				if (not logVars.playing) and (not LibBalancePowerTracker:GetEnabled()) then print("|c00a080ffLibBalancePowerTracker|r: LBPT is disabled, enable it before trying to run a log.") return end
				logVars.playing=enable;
				if enable then
					function LibBalancePowerTracker:GetEclipseEnergyInfo()	return tempEnergy,tempvEnergy,tempDir,tempvDir,tempRE;	end;
					options.enabled=false 
					LBPT:ReCheck() 
					print("|c00a080ffLibBalancePowerTracker|r: Disabled (Playing a log).")
				else
					function LibBalancePowerTracker:GetEclipseEnergyInfo(forced)	if vars.changedState or forced then LBPT:RecalcEnergy() end return vars.computedEnergy,vars.direction,vars.computedVirtualEnergy,vars.vDirection,vars.computedVirtualEclipse;	end;
					options.enabled=true  
					LBPT:ReCheck() 
					print("|c00a080ffLibBalancePowerTracker|r: Enabled (Stopped playing a log).")
				end
			end,
			function(energy,dir,vEnergy,vDir,virtualEclipse) --function to call to display custom values
				if not energy then
					for k,v in pairs(callbacks) 		do v(vars.computedEnergy,vars.direction,vars.computedVirtualEnergy,vars.vDirection,vars.computedVirtualEclipse);	end; 
					for k,v in pairs(reducedCallbacks) 	do v(vars.computedEnergy,vars.direction) end;
				else
					if not logVars.playing then print("|c00a080ffLibBalancePowerTracker|r: Must be running a log to use this function.") return end;
					tempEnergy,tempvEnergy,tempDir,tempvDir,tempRE = energy,dir,vEnergy,vDir,virtualEclipse;
					for k,v in pairs(callbacks) do v(energy,dir,vEnergy,vDir,virtualEclipse); end 
					for k,v in pairs(reducedCallbacks) 	do v(energy,dir); end
				end
			end
		)
	end
end


----TIER MODIFIER FUCNTION (At the end, so it sees and can modify all locals, sometimes I'll need to remove do-end blocks)
LBPT.BonusTier={
	[12]={
		[4]={
			On  = 	function()
						--SF changes--------------------------------------------
						energyFromSpell[data.SF.spellId].sun = function(_,ultimoWR,penultimoWR,eclipse) 
							if eclipse then
								return data.SF.energy,ultimoWR,penultimoWR 
							else 
								return data.SF.energy+5,ultimoWR,penultimoWR 
							end
						end
						energyFromSpell[data.SF.spellId].none = function(_,ultimoWR,penultimoWR) 
							return data.SF.energy+5,ultimoWR,penultimoWR 
						end
						
						doubleEnergyFromSpell[data.SF.spellId].sun  = function(_,ultimoWR,penultimoWR) 
							return 2*data.SF.energy+5,ultimoWR,penultimoWR 
						end
						doubleEnergyFromSpell[data.SF.spellId].none = function(_,ultimoWR,penultimoWR) 
							return 2*data.SF.energy+5,ultimoWR,penultimoWR 
						end
						---------------------------------------------------------

						--WR changes---------------------------------------------
						--[[ after   ---   you get when you gain/lose bonus
							13 14			16 17
							16 17			13 14
							14 13			17 16
							17 16 			14 13
							13 13			17 17
							17 17			13 13
							30 works as if it doesn't exist
							the cycle is 16,16,17,16,16,17
							euphoria procs are always 30
						--]]
						local nextTieredWRenergy = { --ultimo, penultimo
							[-13] = {
								[-13] = -17,
								[-14] = -17,
							},
							[-14] = {
								[-13] = -16,
								[-14] = -16,  --unreachable
							},
							[-16] = {
								[-16] = -17,  --unreachable
								[-17] = -17,
							},
							[-17] = {
								[-16] = -17,
								[-17] = -16,
							},
						}
						nextWRenergy[-16] = {
							[-16] = -14, --unreachable
							[-17] = -14,
						}
						nextWRenergy[-17] = {
							[-16] = -13,
							[-17] = -13,
						}
						
						actualizarEnergiaWR[-13] = function(ultimo,penultimo) 
							if 	ultimo < -15 then	
								if penultimo == -17 then
									return -13,-14
								else
									return -13,-13
								end
							else	
								return -13,ultimo
							end
						end
						actualizarEnergiaWR[-27] = function(ultimo,penultimo) 
							if 	ultimo == -13 then	
								if penultimo == -14 then
									return -14,-13
								else
									return -13,-14
								end
							else
								if penultimo == -17 then
									return -13,-14
								else
									return -14,-13
								end
							end
						end
						actualizarEnergiaWR[-16] = function() return -16,-17 end
						actualizarEnergiaWR[-17] = function(ultimo,penultimo) 
							if 	ultimo > -15 then	
								if penultimo == -13 then
									return -17,-16
								else
									return -17,-17
								end
							else	
								return -17,ultimo
							end
						end
						actualizarEnergiaWR[-30]=function(ultimo,penultimo) return ultimo,penultimo end
						
						energyFromSpell[data.WR.spellId].moon = function(_,ultimoWR,penultimoWR,eclipse) 
							local n;
							if eclipse then
								n = nextWRenergy[ultimoWR][penultimoWR];
							else
								n = nextTieredWRenergy[ultimoWR][penultimoWR];
							end
							return n,actualizarEnergiaWR[n](ultimoWR,penultimoWR); 
						end
						energyFromSpell[data.WR.spellId].sun = function(_,ultimoWR,penultimoWR,eclipse) 
							local n;
							if eclipse then
								n = nextWRenergy[ultimoWR][penultimoWR];
							else
								n = nextTieredWRenergy[ultimoWR][penultimoWR];
							end
							return 0,actualizarEnergiaWR[n](ultimoWR,penultimoWR); 
						end
						energyFromSpell[data.WR.spellId].none = function(_,ultimoWR,penultimoWR) 
							local n = nextTieredWRenergy[ultimoWR][penultimoWR];
							return n,actualizarEnergiaWR[n](ultimoWR,penultimoWR); 
						end
						
						doubleEnergyFromSpell[data.WR.spellId].moon = function(_,ultimoWR,penultimoWR) return -30,ultimoWR,penultimoWR; end
						doubleEnergyFromSpell[data.WR.spellId].sun  = function(_,ultimoWR,penultimoWR) return -30,ultimoWR,penultimoWR; end
						doubleEnergyFromSpell[data.WR.spellId].none = function(_,ultimoWR,penultimoWR) return -30,ultimoWR,penultimoWR; end
	
						return true;
					end,
			Off = 	function() 
						--SF changes--------------------------------------------
						energyFromSpell[data.SF.spellId].sun  = function(_,ultimoWR,penultimoWR) return data.SF.energy,ultimoWR,penultimoWR end
						energyFromSpell[data.SF.spellId].none = function(_,ultimoWR,penultimoWR) return data.SF.energy,ultimoWR,penultimoWR end
												
						doubleEnergyFromSpell[data.SF.spellId].sun = function(_,ultimoWR,penultimoWR) return 2*data.SF.energy,ultimoWR,penultimoWR end
						doubleEnergyFromSpell[data.SF.spellId].none=function (_,ultimoWR,penultimoWR) return 2*data.SF.energy,ultimoWR,penultimoWR end
						---------------------------------------------------------	
						
						--WR changes---------------------------------------------
						energyFromSpell[data.WR.spellId].moon = function(_,ultimoWR,penultimoWR) 
							local n = nextWRenergy[ultimoWR][penultimoWR];
							return n,actualizarEnergiaWR[n](ultimoWR,penultimoWR); 
						end
						energyFromSpell[data.WR.spellId].sun = function(_,ultimoWR,penultimoWR) 
							local n = nextWRenergy[ultimoWR][penultimoWR];
							return 0,actualizarEnergiaWR[n](ultimoWR,penultimoWR); 
						end
						energyFromSpell[data.WR.spellId].none = function(_,ultimoWR,penultimoWR) 
							local n = nextWRenergy[ultimoWR][penultimoWR];
							return n,actualizarEnergiaWR[n](ultimoWR,penultimoWR); 
						end
						
						doubleEnergyFromSpell[data.WR.spellId].moon = function(_,ultimoWR,penultimoWR) 
							local n1 = nextWRenergy[ultimoWR][penultimoWR];
							local n2 = nextWRenergy[n1][ultimoWR];
							return n1+n2,actualizarEnergiaWR[n1+n2](ultimoWR,penultimoWR); 
						end
						doubleEnergyFromSpell[data.WR.spellId].sun  = function(_,ultimoWR,penultimoWR) 
							local n1 = nextWRenergy[ultimoWR][penultimoWR];
							local n2 = nextWRenergy[n1][ultimoWR];
							return 0,actualizarEnergiaWR[n1+n2](ultimoWR,penultimoWR); 
						end
						doubleEnergyFromSpell[data.WR.spellId].none = function(_,ultimoWR,penultimoWR) 
							local n1 = nextWRenergy[ultimoWR][penultimoWR];
							local n2 = nextWRenergy[n1][ultimoWR];
							return n1+n2,actualizarEnergiaWR[n1+n2](ultimoWR,penultimoWR); 
						end
						------------------------------------------------------
						return true;
					end,
		},
	},
}
