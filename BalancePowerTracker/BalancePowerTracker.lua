local libCompatibilityIssues = false;
--[[
Interface: 4.2.0
Title: BalancePowerTracker
Version: 1.2.2
Author: Kurohoshi (EU-Minahonda)

--INFO
	BalancePowerTracker is an addon designed to provide a highly configurable bar to track Lunar/Solar energy, Eclipse direction and Eclipse buff.
	It also can fire wanrings whe you gain Eclipse and provides a nice feature: Foresee energy (see below).

	LibSharedMedia, LibButtonFacade and MSBT support.

	FORESEE ENERGY:
	Foresee Energy is a feature the addon uses to analize the spells you have cast and/or you are casting but are yet to land and computes
	the energy sum of them. This allows the addon to distinguish between two kinds of each variable: One real, the one you have at the moment
	and other virtual, the one you'll have when all flying spells and the spell you are casting land.
	Foresee Energy works assuming the following:
		-You're hit capped (All your spells will land).
		-You're not going to proc Euphoria (2x energy gain).
			·If you proc it, it will update immediately, this only means you will reach Eclipse earlier than the addon predicted the moment
			before the Eupforia proc.
	All the features with the 'virtual' tag (virtual Energy, virtual Eclipse ...) rely on Foresee Energy.
	(Author's note: I feel Foresee Energy is the heart of BPT, I think without this option I wouldn't have made this addon, also it has taken up
	most of the time invested in the addon, however, I understand people value the choice to turn this off. At least, give it a try!)

	You can configure each of the indicators (bar,text,icons,arrow) of the addon to either display virtual or real info.
	Also, you can configure the warnings to fire when you gain virtual Eclipse, this means BPT will fire a warning when the energy sum from all
	the flying spells and the one you're casting will proc Eclipse, so you can switch nukes.

	ADDON AUTHORS:
	BPT will maintain a public table with the following values, should another addons need it:
	BalancePowerTracker_SharedInfo = {
		Enabled = function(enabled) --Enables/Disables BPT
		Shown	= function(shown)  	--Show/Hide BPT
		Foresee = function(enabled) --Start/Stop Foresee energy function
		realEnergy 	= Real energy
		virtualEnergy 	= Virtual energy
		reachEnd 	= if virtualEnergy reachs 100 or -100 during its computation, the value is stored, false otherwise.
		realDirection 	= Real Eclipse direction
		virtualDirection 	= Virtual Eclipse direction
		eclipse 	=  SpellId of the Eclipse buff you have, false if not Eclipse
		virtualEclipse 	= If virtual Lunar eclipse then "L" elseif virtual Solar eclipse then "S" else false end
		foreseeEnergy 	= BPT foreseeEnergy option
		enabled 	= BPT enabled option
		version 	= BPT version
		hidden	= true if bar is hidden (alpha = 0 isn't hidden)
		style 	= Table storing information and functions for skins
	}

--KNOWN BUGS
	Sometimes, if the target disappears (only if it's a pet and it's unsummoned) while a spell is flying, the spell would not be erased immediately.

--CHANGELOG
v 1.2.2 FIX; Lua error when Shooting stars proc

v 1.2.1 FIX: Tier 12 fully supported now
		CHANGE: LibBalancePowerTracker updated
		CHANGE: Minor change due to reachEnd converted into VirtualEcipse (still using reachEnd)

v 1.2.0 FIX: Now working in 4.2 patch.
		FIX: Updated libraries.
		FEATURE: BalancePowerTracker_Pipe: now you can use BPT's values in PowerAuras when this module is loaded.
		FEATURE: BalancePowerTracker_Log: Found a bug? Please, log it with this tool.
		CHANGE: BalancePowerTracker_Options: BPT's options were moved into a new AddOn in order to free a little memory.

v 1.1.8 FIX: Now working in 4.1 patch.

v 1.1.7 FIX: MSBT displaying "Move me!" when having alert warning turned off.
		FEATURE: You can configure BPT to show/hide Eclipse spell effect using virtual info.

v 1.1.6 FIX: Fixed still more issues with loading/storing settings (the ones that weren't corrected in v1.1.5, I think I've got all)

v 1.1.5 FIX: Fixed issues with loading/storing settings

v 1.1.4 CHANGE: Updated LibBalancePowerTracker.
		FEATURE: Added sound effects alerts.
		CHANGE: Minor improvements to code.
		CHANGE: Updated to use the most recent ACE3 libs

v 1.1.3 FEATURE: Custom form show/hide
		FIX: Check Eclipse buff on teleport (for when entering arena)
		FEATURE: Option to display lunar energy as negative energy
		CHANGE: Updated LibBalancePowerTracker to the last build (1.0.3)
		FIX: Reset works with callbacks.
		FEATURE: Eclipse Chance calculation (Beta stage): See advanced tab.
		FETAURE: Statistically Energy calculation (Beta stage): See advanced tab.

v 1.1.2 FEATURE: Added option to change icon texture to media tab.
		FIX: Original icons fixed
		CHANGE: Icon offset range changed to [-30,30]
		FEATURE: Added warning when you interrupt/fail to cast the spell that was going to give you Eclipse
		FEATURE: Added other glow.
			-LibBalancePowerTracker updated to include PvP bonus and improved eclipse direction fetching

v 1.1.1 CHANGE: Oops, forgot to remove unused libraries, updated the others.
		FEATURE: Added option to change relative point.
		FIX: When deactivating LBF, the icons scale correctly.
		CHANGE: Minor interface changes to allow the use of external skins.

v 1.1.0 CHANGE: Massive changes to reduce CPU usage by 70%
				- Energy track moved to library

v 1.0.8	FIX: Showing addon when visible was not enabled
		FEATURE: BalancePowerTracker_SharedInfo.hidden added
		FEATURE: BalancePowerTracker_SharedInfo.enabled added
		FEATURE: MSBT support
		FEATURE: Text color and size can be changed
		FEATURE: Icon offset can be changed
		FIX: Position sliders gap reduced
		CHANGE: Some functions moved from ADDON_LOADED to PLAYER_LOGIN shouldn't be any problem
		FIX: Removed LibButtonFacade, but ButtonFacade is still supported
		CHANGE: Hiding behaviour improved
		FIX: Arrow not working like it should after teleporting

v 1.0.7	FIX: Showing default blizz frame when getting out of vehicle
		FIX: Not showing the foresee energy bar when reaching end
		FIX: Bar not updating when teleporting & changing form at the same time
		FIX: Enlarging both icons when there was no eclipse direction
		FEATURE: Arrow can be scaled
		FEATURE: Eclipse icons can be hidden
		FEATURE: Show addon when not in Caster/Moonkin Form option
		FEATURE: Border color can be changed
		FEATURE: Added option to color the entire bar based on direction (You can select the info used to color the bar)
		FEATURE: /bpt & /balancepowertracker show the config window
		CHANGE: You can now select the info displayed on the icons (before, it used arrow's info)
		CHANGE: Icons can be scaled
		FEATURE: Original Icons can be selected (Need some tweaks)
		FEATURE: ButtonFacade support
		FEATURE: Bar can be set to vertical or horizontal
		FEATURE: Added public functions to enable/disable/show/hide the addon and to start/stop foreseeing energy

v 1.0.6	Not detecting instant SS bug fixed (I didn't find this one on time)

v 1.0.5	Created & using SpellQueue ADT, easier to maintain code
		In text you can configure which energy should be displayed
		In arrow you can configure which info should be displayed
		You can hide the former "addEnergy" bar without losing the benefits of Foresee energy
		Add energy renamed to "Foresee energy"
		Options clarified

v 1.0.4	Perfomance improved: CPU usage reduced by aprox. 65-70%!
		Alpha OOC added!
		Fixed textures
		Fixed not showing Virtual Eclipse on instant SS cast bug
		Share Info and Same Color options removed
		Options Revamped
		Added screenflash warning
		Added function to enlarge the Eclipse Icon you should aim to

v 1.0.3 Uptaded "add energy" to the last ptr build (13082)
		You can choose between arrow instead and spark (if you choose arrow, the text will move so you can see the arrow)
		You can hide the energy text
		New function added: Warnings
		Bunch of minor bugs fixes
v 1.0.2 Uptaded "add energy" to the last ptr build (13033):
			SS fixed energy
			fixed WR sometimes 14 energy
			smoothly!
			unregister its events when not using it, to free CPU
		Fixed checking form when not having all forms trained
		Info box in style tab
		Strata and alpha can be changed
v 1.0.1 Fixed Blizz Frame showing when not Balance and some bugs also with Blizz Frame & Power tracker
		Fixed missing lib
v 1.0.0 Release
--]]

--Globals
SLASH_BALANCEPOWERTRACKER1,SLASH_BALANCEPOWERTRACKER2= '/balancepowertracker','/bpt';
BalancePowerTracker_DB={
	default={},
	colors={},
	free={},
	warningsoptions={},
	warningsflasher={},
	warningsalert={},
	warningsmsbt={},
	lbf = {},
};
if not BalancePowerTracker_SharedInfo then BalancePowerTracker_SharedInfo={};end
if not BalancePowerTracker_SharedInfo.style then BalancePowerTracker_SharedInfo.style={} end

--Locals
local BalancePowerTracker = {
	options = {},
	barColor = {},
	defaults = {
		options = {
			x = 0,
			y = 0,
			point = "CENTER",
			strata ="HIGH",
			alpha=1,
			alphaOOC=.5,
			enabled = true,
			foreseeEnergy = true,
			probEclipse = false,
			probEclipseFontSize = 10,
			confidence = .8,
			statEclipse = false,
			addForeseenEnergyToBar = true,
			hideBlizzards = true,
			moveSparkOnly = true,
			width = 140,
			height = 14,
			scale = 1,
			styleName = "simple",
			extMod=false,
			highlightIcons  = true,
			dynamicGlow = false,
			virtualSpellEffects = false,
			visible = true,
			showOOF = false, --show out of form
			showOIM = false, --show only in moonkin
			showCustom = false,
			showCustomTable={
				["1"] = false, --cat
				["5"] = false, --bear
				["31"] = true, --moonkin
				["27"] = false, --flight
				["3"] = false, --travel
				["4"] = false, --aquatic
				["nil"] = true, --humanoid
			},
			showText=true,
			moveText=true,
			showVirtualOnText=true,
			autoFontSizeText=true,
			absoluteText=true,
			fontSizeText = 14,
			usearrow = true,
			arrowScale =1,
			showVirtualOnSpark = true,
			hideIcon = false,
			bigIcons =false,
			bigIconScale=1.4,
			iconOffset = 4,
			showVirtualOnIcon = true,
			colorBarDirection = false,
			showVirtualOnColoredBar = true,
			lbf=false,
			originalEclipseIcons = false,
			vertical = false,
			normalIconScale =1.2,
		},
		barColor={
			solarEnergyBar        	= { r =   1, g = .55, b =  0, a = 1,},
			virtualSolarEnergyBar 	= { r =   1, g = .66, b =.16, a = 1,},
			lunarEnergyBar        	= { r = .05, g = .21, b =.73, a = 1,},
			virtualLunarEnergyBar 	= { r = .12, g = .56, b =  1, a = 1,},
			spark                	= { r =   1, g =   1, b =  1, a = 1,},
			text                	= { r =   1, g =   1, b =  1, a = 1,},
			border                	= { r =   1, g =   1, b =  1, a = 1,},
			background				= { r =   0, g =   0, b =  0, a = 1,},
		},
		free = {
			name = "BPT: Freestyle",
			usesMedia=true,
			background = "Interface\\Tooltips\\UI-Tooltip-Background",
			bar = "Interface\\TARGETINGFRAME\\UI-TargetingFrame-BarFill",
			spark = "Interface\\CastingBar\\UI-CastingBar-Spark",
			edge = "Interface\\None",
			solarIconHighlight = "Interface\\GLUES\\CHARACTERCREATE\\UI-CharacterCreate-IconGlow",
			lunarIconHighlight = "Interface\\GLUES\\CHARACTERCREATE\\UI-CharacterCreate-IconGlow",
			iconLunar = select(3,GetSpellInfo(48518)),
			iconSolar = select(3,GetSpellInfo(48517)),
			font = "Fonts\\FRIZQT__.TTF",
			insets = {left = 2,right = 2,top = 2, bottom = 2},
			edgesize=12,
			inset=2,
			info = "Use Media tab to configure textures.",
		},
		warningsoptions = {
			x=0,
			y=120,
			point = "CENTER",
			fontSize = 30,
			move = false,
			sound = false,
			sounds = {
				warnLunar = "Interface\\Quiet.ogg",
				warnSolar = "Interface\\Quiet.ogg",
				warnVLunar = "Interface\\Quiet.ogg",
				warnVSolar = "Interface\\Quiet.ogg",
				warnVFailed = "Interface\\Quiet.ogg",
			},
			warnLunar = true,
			warnSolar = true,
			warnVLunar = true,
			warnVSolar = true,
			warnVFailed = false,
		},
		warningsmsbt ={
			enabled = false,
			font = nil,
			fontSize = 20,
			sticky = false,
			scrollArea = nil,
		},
		warningsalert = {
			enabled = true,
		},
		warningsflasher = {
			enabled = false,
			alpha = .25,
		},
	},
	vars={
		version = GetAddOnMetadata("BalancePowerTracker", "Version"),
		move = false,
		isBalance = false,
		isDruid = false,
		playerGUID = false,
		eclipse = false,
		virtualEclipse=false,
		sparkYOffset = 0,
		functBlizzOnEvent=false, --Stores the blizz funtion from EclipseBarFrame
		functBlizzOnShow=false, --Stores the blizz funtion from EclipseBarFrame
		tainted = false,
		lbfdisabled = true,
		msbtdisabled = true,
		callbackId = false,
		probEclipseCallbackId=false,
	},
	spells={
		WR = {name = GetSpellInfo(5176) ,energy = 13,spellId=5176}, -- name & energy Wrath
		SF = {name = GetSpellInfo(2912) ,energy = 20,spellId=2912}, -- name & energy Starfire
		SS = {name = GetSpellInfo(78674)  ,energy = 15,spellId=78674}, -- name StarSurge
		LE = {name = GetSpellInfo(48518) , icon = select(3,GetSpellInfo(48518)), spellId=48518}, -- name & icon Lunar Eclipse
		SE = {name = GetSpellInfo(48517) , icon = select(3,GetSpellInfo(48517)), spellId=48517}, -- name & icon Solar Eclipse
		NG = {name = GetSpellInfo(16880)}, -- name Nature's Grace
		LG = {name = GetSpellInfo(33591)}, -- name Lunar guidance
		EE = {spellId = 89265}, -- Eclipse Energy spell
		SSE = {spellId = 86605}, --Starsurge Energy spell
	},
	frames={
		background = CreateFrame("Frame","BalancePowerTrackerBackgroundFrame",UIParent),
	},
	warnings = {
		options = {},
		flasher = {},
		alert = {},
		msbt ={},
	},
	style={
		simple = {
			name = "BPT: Simple",
			usesMedia=false,
			background = "Interface\\Tooltips\\UI-Tooltip-Background",
			bar = "Interface\\TARGETINGFRAME\\UI-TargetingFrame-BarFill",
			spark = "Interface\\CastingBar\\UI-CastingBar-Spark",
			edge = "Interface\\Tooltips\\UI-Tooltip-Border",
			solarIconHighlight = "Interface\\GLUES\\CHARACTERCREATE\\UI-CharacterCreate-IconGlow",
			lunarIconHighlight = "Interface\\GLUES\\CHARACTERCREATE\\UI-CharacterCreate-IconGlow",
			iconLunar = select(3,GetSpellInfo(48518)),
			iconSolar = select(3,GetSpellInfo(48517)),
			font = "Fonts\\FRIZQT__.TTF",
			insets = {left = 2,right = 2,top = 2, bottom = 2},
			edgesize=12,
			inset=3,
		},
		classic = {
			name = "BPT: Classic",
			usesMedia=false,
			background = "Interface\\Tooltips\\UI-Tooltip-Background",
			bar = "Interface\\TARGETINGFRAME\\UI-TargetingFrame-BarFill",
			spark = "Interface\\MAINMENUBAR\\UI-ExhaustionTickNormal",
			edge = "Interface\\DialogFrame\\UI-DialogBox-Border",
			solarIconHighlight = "Interface\\GLUES\\CHARACTERCREATE\\UI-CharacterCreate-IconGlow",
			lunarIconHighlight = "Interface\\GLUES\\CHARACTERCREATE\\UI-CharacterCreate-IconGlow",
			iconLunar = select(3,GetSpellInfo(48518)),
			iconSolar = select(3,GetSpellInfo(48517)),
			font = "Fonts\\FRIZQT__.TTF",
			insets = {left = 2,right = 2,top = 2, bottom = 2},
			edgesize=20,
			inset=6,
		},
		free = {},
	},
	media={
		textures={
			["Interface\\Tooltips\\UI-Tooltip-Background"] = "BPT: Blizz Background",
			["Interface\\TARGETINGFRAME\\UI-TargetingFrame-BarFill"]="BPT: Blizz BarFill",
		},
		borders={
			["Interface\\None"] = "None",
			["Interface\\DialogFrame\\UI-DialogBox-Border"] = "Blizzard Border Dialog",
			["Interface\\Tooltips\\UI-Tooltip-Border"] = "Blizzard Tooltip",
		},
		fonts={
			["Fonts\\FRIZQT__.TTF"] = "Friz Quadrata TT",
		},
		sound = {
			["Interface\\Quiet.ogg"] = "None",
		},
	},
	strataTable = {
		"PARENT",
		"BACKGROUND",
		"LOW",
		"MEDIUM",
		"HIGH",
		"DIALOG",
		"FULLSCREEN",
		"FULLSCREEN_DIALOG",
		"TOOLTIP",
	},
	eclipseMarkerCoords =  {
		none = { 0.914, 1.0, 0.82, 1.0 },
		sun	= { 0.914, 1.0, 0.641, 0.82 },
		moon = { 1.0, 0.914, 0.641, 0.82 },
	},
	eclipseMarkerCoordsV =  {
		none = {1,0.82,0.914,0.82,1,1,0.914,1},
		sun = {1,0.641,0.914,0.641,1,0.82,0.914,0.82},
		moon = {0.914,0.641,1,0.641,0.914,0.82,1,0.82},
	},
	db = { --LibButtonFacade options
	},
}

BalancePowerTrackerBackgroundFrame:SetScript("OnEvent", function(self, event, ...) BalancePowerTracker[event](self,...) end);
BalancePowerTrackerBackgroundFrame:RegisterEvent("ADDON_LOADED");

--Public Functions --ONLY PUBLIC FUNCTIONS!
BalancePowerTracker_SharedInfo.Enabled = function(enabled) BalancePowerTracker.options.enabled=enabled; BalancePowerTracker:ReCheck() end
BalancePowerTracker_SharedInfo.Shown = 	function(shown) BalancePowerTracker.options.visible=shown;
											if not BalancePowerTracker.options.visible then
												BalancePowerTracker.frames.background:SetAlpha(0);
											elseif not UnitAffectingCombat("player") then
												BalancePowerTracker.frames.background:SetAlpha(BalancePowerTracker.options.alphaOOC);
											else
												BalancePowerTracker.frames.background:SetAlpha(alpha);
											end
										end
BalancePowerTracker_SharedInfo.Foresee = function(enabled) BalancePowerTracker.options.foreseeEnergy=enabled ; BalancePowerTracker:RegisterAddEnergy() BalancePowerTracker:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo())  end
BalancePowerTracker_SharedInfo.Update = function(energy,direction,vEnergy,vDirection,reachEnd,eclipse)
	if energy then BalancePowerTracker:RecalcEnergy(energy,direction,vEnergy,vDirection,reachEnd) end
	if eclipse == "none" then
		BalancePowerTracker:UpdateEclipse()
	elseif eclipse == "solar" then
		local temp = BalancePowerTracker.vars.eclipse
		BalancePowerTracker.vars.eclipse = BalancePowerTracker.spells.SE.spellId
		BalancePowerTracker:Warning(true,BalancePowerTracker.spells.SE.spellId)
		BalancePowerTracker:UpdateEclipse()
		BalancePowerTracker.vars.eclipse = temp
	elseif eclipse == "lunar" then
		local temp = BalancePowerTracker.vars.eclipse
		BalancePowerTracker.vars.eclipse = BalancePowerTracker.spells.LE.spellId
		BalancePowerTracker:Warning(true,BalancePowerTracker.spells.LE.spellId)
		BalancePowerTracker:UpdateEclipse()
		BalancePowerTracker.vars.eclipse = temp
	end
end

--Loading Events
function BalancePowerTracker:ADDON_LOADED(name) --Initialize addon (register events & load vars)
	if name ~= "BalancePowerTracker" then
		return
	end

	local _,class=UnitClass('player');

 	if class ~= "DRUID" then --If isn't druid, we finish here
		BalancePowerTracker.options.enabled = false
		BalancePowerTracker.vars.isDruid = false
		BalancePowerTracker.vars.isBalance = false;
		print("|c00a080ffBalancePowerTracker|r: Won't work.");
	else
		BalancePowerTracker.vars.isDruid = true;

		--Loading events
		BalancePowerTrackerBackgroundFrame:RegisterEvent("PLAYER_LOGOUT");
		BalancePowerTrackerBackgroundFrame:RegisterEvent("PLAYER_LOGIN");
		BalancePowerTrackerBackgroundFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");

		--Recalc events
		BalancePowerTrackerBackgroundFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
		BalancePowerTrackerBackgroundFrame:RegisterEvent("CHARACTER_POINTS_CHANGED");

		--Show/hide events
		BalancePowerTrackerBackgroundFrame:RegisterEvent("UNIT_ENTERED_VEHICLE");
		BalancePowerTrackerBackgroundFrame:RegisterEvent("UNIT_EXITED_VEHICLE");
		BalancePowerTrackerBackgroundFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
		BalancePowerTrackerBackgroundFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
		BalancePowerTrackerBackgroundFrame:RegisterEvent("PLAYER_REGEN_DISABLED");

		BalancePowerTracker.vars.functBlizzOnEvent = EclipseBarFrame:GetScript("OnEvent")
		BalancePowerTracker.vars.functBlizzOnShow = EclipseBarFrame:GetScript("OnShow")

		BalancePowerTracker:LoadVars()

		BalancePowerTracker_SharedInfo.enabled = BalancePowerTracker.options.enabled
	end
end
function BalancePowerTracker:PLAYER_LOGIN() --Finish loading addon (loads libs & options), Creates Initial Interface & fetchs player guid
	BalancePowerTracker:MSBT_Init()  --Initializes MSBT support

	BalancePowerTracker:ButtonFacade_Init() --Initializes Button Facade

	BalancePowerTracker:LibSharedMedia_Load()
	BalancePowerTracker:LibSharedMedia_Registered();

	BalancePowerTracker:ReadyToCreateOptions();

	print("|c00a080ffBalancePowerTracker v"..BalancePowerTracker.vars.version.."|r: Loaded!");

	if BalancePowerTracker_SharedInfo.style[BalancePowerTracker.options.extMod] then
		print("|c00a080ffBalancePowerTracker|r: "..BalancePowerTracker.options.extMod.." module loaded!");
		BalancePowerTracker_SharedInfo.style[BalancePowerTracker.options.extMod].Loaded()
	elseif BalancePowerTracker.options.extMod then
		print("|c00a080ffBalancePowerTracker|r: "..tostring(BalancePowerTracker.options.extMod).." couldn't be loaded!");
		BalancePowerTracker.options.extMod=false
	end

	-------------------------FINISH LOADING-BEGIN CREATING ADDON------------------------------------

	BalancePowerTracker.vars.playerGUID=UnitGUID("player")
	BalancePowerTracker:IsBalanceDruid() --Spells -> isMoonkin?
	BalancePowerTracker:RegisterCombatLogEvent() --Register/unregister Combat log events

	BalancePowerTracker:CreateInterface() --Creates Interface, checks eclipse buff on reload (on load it's not available), and forces redraw

	BalancePowerTracker:CheckBlizzardFrameStatus() -- Forms & EclipseBarFrame -> Show/Hide default frame
	BalancePowerTracker:CheckHiddenStatus(); --Forms -> Check Addon Hidden status

	BalancePowerTracker:RegisterCallback()
	BalancePowerTracker:RegisterProbEclipseCallback()
end
function BalancePowerTracker:UPDATE_SHAPESHIFT_FORMS() --Check eclipse buff on load, on reload, it's available at player_login (also, checks HiddenStatus when teleporting, should your form be canceled)
	BalancePowerTracker:CheckEcplipseBuff()
	BalancePowerTracker:CheckHiddenStatus()
end

--Logout Events
function BalancePowerTracker:PLAYER_LOGOUT() --SaveVars
	BalancePowerTracker:SaveVars()
end

--Callback functions
function BalancePowerTracker:RegisterCallback()
	if libCompatibilityIssues then
		if not BalancePowerTracker.frames.issueframe then BalancePowerTracker.frames.issueframe=CreateFrame("Frame");end
		local e,d=0,"none";
		BalancePowerTracker.frames.issueframe:SetScript("OnUpdate",function()
			if e~=UnitPower("player",SPELL_POWER_ECLIPSE) then e=UnitPower("player",SPELL_POWER_ECLIPSE);BalancePowerTracker:RecalcEnergy(e,d,e,d,false) end
			if d~=GetEclipseDirection() then d=GetEclipseDirection();BalancePowerTracker:RecalcEnergy(e,d,e,d,false) end
		end)
		return
	end;

	if BalancePowerTracker.vars.callbackId then LibBalancePowerTracker:UnregisterCallback(BalancePowerTracker.vars.callbackId) end
	if BalancePowerTracker.options.statEclipse then
		BalancePowerTracker.vars.callbackId = LibBalancePowerTracker:RegisterStatCallback(function(f) BalancePowerTracker:RecalcEnergy(f(BalancePowerTracker.options.confidence)) end);
	elseif BalancePowerTracker.options.foreseeEnergy then
		BalancePowerTracker.vars.callbackId = LibBalancePowerTracker:RegisterFullCallback(function(...) BalancePowerTracker:RecalcEnergy(...) end);
	else
		BalancePowerTracker.vars.callbackId = LibBalancePowerTracker:RegisterReducedCallback(function(energy,direction) BalancePowerTracker:Update(energy,energy,false,direction,direction) end);
	end
end
function BalancePowerTracker:RegisterProbEclipseCallback()
	if libCompatibilityIssues then
		BalancePowerTrackerSolarEclipseProbText:Hide();
		BalancePowerTrackerLunarEclipseProbText:Hide();
		return
	end;

	if BalancePowerTracker.vars.probEclipseCallbackId then LibBalancePowerTracker:UnregisterCallback(BalancePowerTracker.vars.probEclipseCallbackId) end

	if BalancePowerTracker.options.probEclipse then
		BalancePowerTrackerSolarEclipseProbText:Show()
		BalancePowerTrackerLunarEclipseProbText:Show()
		BalancePowerTracker.vars.probEclipseCallbackId = LibBalancePowerTracker:RegisterEclipseProbCallback(function(value)
																												if value <0 then
																													BalancePowerTrackerLunarEclipseProbText:SetText(abs(floor(value*100+.5)))
																												elseif value >0 then
																													BalancePowerTrackerSolarEclipseProbText:SetText(abs(floor(value*100+.5)))
																												else
																													BalancePowerTrackerSolarEclipseProbText:SetText("0");
																													BalancePowerTrackerLunarEclipseProbText:SetText("0");
																												end
																											end)
	else
		BalancePowerTrackerSolarEclipseProbText:Hide();
		BalancePowerTrackerLunarEclipseProbText:Hide();
	end
end

--Interface funtions
function BalancePowerTracker:CreateInterface() --Creates & redraws the basic Interface
	local scale = BalancePowerTracker.options.scale
	local height = BalancePowerTracker.options.height
	local width = BalancePowerTracker.options.width
	local styleName = BalancePowerTracker.options.styleName
	local style = BalancePowerTracker.style[styleName]
	local heightBack=height+2*style.inset
	local widthBack=width+2*style.inset
	local edgesize = style.edgesize
	local sideicon = BalancePowerTracker.options.normalIconScale*heightBack
	local iconOffset =  BalancePowerTracker.options.iconOffset
	local alpha = BalancePowerTracker.options.alpha

	--Background
	BalancePowerTracker.frames.background:SetFrameStrata(BalancePowerTracker.options.strata)
	BalancePowerTracker.frames.background:SetMovable(true)
	BalancePowerTracker.frames.background:EnableMouse(false)
	BalancePowerTracker.frames.background:SetClampedToScreen(true)
	BalancePowerTracker.frames.background:SetScript("OnShow", function() BalancePowerTracker:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo()) end)
	if BalancePowerTracker.vars.move then
		BalancePowerTracker.frames.background:SetScript("OnMouseDown", function(self) self:StartMoving() end)
		BalancePowerTracker.frames.background:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); BalancePowerTracker.options.point,_,_,BalancePowerTracker.options.x,BalancePowerTracker.options.y = self:GetPoint() end)
		BalancePowerTracker.frames.background:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() BalancePowerTracker.options.point,_,_,BalancePowerTracker.options.x,BalancePowerTracker.options.y = self:GetPoint() end)
		BalancePowerTracker.frames.background:EnableMouse(true)
	else
		BalancePowerTracker.frames.background:SetScript("OnMouseDown", nil)
		BalancePowerTracker.frames.background:SetScript("OnMouseUp", nil)
		BalancePowerTracker.frames.background:SetScript("OnDragStop", nil)
		BalancePowerTracker.frames.background:EnableMouse(false)
	end
	BalancePowerTracker.frames.background:ClearAllPoints();
	BalancePowerTracker.frames.background:SetPoint(BalancePowerTracker.options.point,BalancePowerTracker.options.x,BalancePowerTracker.options.y)

	if BalancePowerTracker.options.vertical then
		BalancePowerTracker.frames.background:SetWidth(heightBack)
		BalancePowerTracker.frames.background:SetHeight(widthBack)
	else
		BalancePowerTracker.frames.background:SetWidth(widthBack)
		BalancePowerTracker.frames.background:SetHeight(heightBack)
	end

	BalancePowerTracker.frames.background:SetScale(scale)
	BalancePowerTracker.frames.background:SetBackdrop({
		edgeFile = style.edge,
		tile = false, tileSize = 0, edgeSize = edgesize,
		insets = style.insets
	})
	local color = BalancePowerTracker.barColor.border
	BalancePowerTracker.frames.background:SetBackdropBorderColor(color.r, color.g, color.b, color.a)

	if not BalancePowerTracker.options.visible then
		BalancePowerTracker.frames.background:SetAlpha(0);
	elseif not UnitAffectingCombat("player") then
		BalancePowerTracker.frames.background:SetAlpha(BalancePowerTracker.options.alphaOOC);
	else
		BalancePowerTracker.frames.background:SetAlpha(alpha);
	end

	-- Background Texture
	if not BalancePowerTracker.frames.background.tex then
		BalancePowerTracker.frames.background.tex = BalancePowerTrackerBackgroundFrame:CreateTexture(nil, "BACKGROUND")
	end
	BalancePowerTracker.frames.background.tex:SetDrawLayer( "BACKGROUND" ,0)
	BalancePowerTracker.frames.background.tex:ClearAllPoints();
	BalancePowerTracker.frames.background.tex:SetTexture(style.background)
	BalancePowerTracker.frames.background.tex:SetPoint("CENTER")
	if BalancePowerTracker.options.vertical then
		BalancePowerTracker.frames.background.tex:SetWidth(height)
		BalancePowerTracker.frames.background.tex:SetHeight(width)
		BalancePowerTracker.frames.background.tex:SetTexCoord(1,0,0,0,1,1,0,1)
	else
		BalancePowerTracker.frames.background.tex:SetWidth(width)
		BalancePowerTracker.frames.background.tex:SetHeight(height)
		BalancePowerTracker.frames.background.tex:SetTexCoord(0,1,0,1)
	end
	color = BalancePowerTracker.barColor.background
	BalancePowerTracker.frames.background.tex:SetGradientAlpha("VERTICAL",color.r, color.g, color.b, color.a, color.r, color.g, color.b, color.a)
	BalancePowerTracker.frames.background.tex:Show()


	--Lunar energy
	local lColor = BalancePowerTracker.barColor.lunarEnergyBar
	if not BalancePowerTracker.frames.background.lenergy then
		BalancePowerTracker.frames.background.lenergy = BalancePowerTrackerBackgroundFrame:CreateTexture(nil, "ARTWORK")
	end
	BalancePowerTracker.frames.background.lenergy:SetDrawLayer( "ARTWORK" ,0)
	BalancePowerTracker.frames.background.lenergy:ClearAllPoints();
	BalancePowerTracker.frames.background.lenergy:SetTexture(style.bar)
	if BalancePowerTracker.options.vertical then
		BalancePowerTracker.frames.background.lenergy:SetWidth(height)
		BalancePowerTracker.frames.background.lenergy:SetHeight(width/2)
		BalancePowerTracker.frames.background.lenergy:SetPoint("TOP",BalancePowerTrackerBackgroundFrame,"CENTER")
		BalancePowerTracker.frames.background.lenergy:SetTexCoord(.5,0,0,0,.5,1,0,1)
	else
		BalancePowerTracker.frames.background.lenergy:SetWidth(width/2)
		BalancePowerTracker.frames.background.lenergy:SetHeight(height)
		BalancePowerTracker.frames.background.lenergy:SetPoint("RIGHT",BalancePowerTrackerBackgroundFrame,"CENTER")
		BalancePowerTracker.frames.background.lenergy:SetTexCoord(0,.5,0,1)
	end
	BalancePowerTracker.frames.background.lenergy:SetGradientAlpha("VERTICAL",lColor.r, lColor.g, lColor.b, lColor.a, lColor.r, lColor.g, lColor.b, lColor.a)
	BalancePowerTracker.frames.background.lenergy:Show()

	--Solar energy
	local sColor = BalancePowerTracker.barColor.solarEnergyBar
	if not BalancePowerTracker.frames.background.senergy then
		BalancePowerTracker.frames.background.senergy = BalancePowerTrackerBackgroundFrame:CreateTexture(nil, "ARTWORK")
	end
	BalancePowerTracker.frames.background.senergy:SetDrawLayer( "ARTWORK" ,0)
	BalancePowerTracker.frames.background.senergy:ClearAllPoints();
	BalancePowerTracker.frames.background.senergy:SetTexture(style.bar)
	if BalancePowerTracker.options.vertical then
		BalancePowerTracker.frames.background.senergy:SetPoint("BOTTOM",BalancePowerTrackerBackgroundFrame,"CENTER")
		BalancePowerTracker.frames.background.senergy:SetWidth(height)
		BalancePowerTracker.frames.background.senergy:SetHeight(width/2)
		BalancePowerTracker.frames.background.senergy:SetTexCoord(1,0, .5,0, 1,1,.5,1 )
	else
		BalancePowerTracker.frames.background.senergy:SetPoint("LEFT",BalancePowerTrackerBackgroundFrame,"CENTER")
		BalancePowerTracker.frames.background.senergy:SetWidth(width/2)
		BalancePowerTracker.frames.background.senergy:SetHeight(height)
		BalancePowerTracker.frames.background.senergy:SetTexCoord(.5,1,0,1)
	end
	BalancePowerTracker.frames.background.senergy:SetGradientAlpha("VERTICAL",sColor.r, sColor.g, sColor.b, sColor.a, sColor.r, sColor.g, sColor.b, sColor.a)
	BalancePowerTracker.frames.background.senergy:Show()

	BalancePowerTracker.vars.barDirection = "none";

	--Between energy
	local bColor = BalancePowerTracker.barColor.virtualLunarEnergyBar
	if not BalancePowerTracker.frames.background.benergy then
		BalancePowerTracker.frames.background.benergy = BalancePowerTrackerBackgroundFrame:CreateTexture(nil, "ARTWORK")
	end
	BalancePowerTracker.frames.background.benergy:SetDrawLayer( "ARTWORK" ,1)
	BalancePowerTracker.frames.background.benergy:ClearAllPoints();
	BalancePowerTracker.frames.background.benergy:SetPoint("CENTER")
	if BalancePowerTracker.options.vertical then
		BalancePowerTracker.frames.background.benergy:SetWidth(height)
		BalancePowerTracker.frames.background.benergy:SetHeight(width/2)
	else
		BalancePowerTracker.frames.background.benergy:SetWidth(width/2)
		BalancePowerTracker.frames.background.benergy:SetHeight(height)
	end
	BalancePowerTracker.frames.background.benergy:SetTexture(style.bar)
	BalancePowerTracker.frames.background.benergy:Hide()

	--Text
	if not BalancePowerTracker.frames.background.energyText then
		BalancePowerTracker.frames.background.energyText=BalancePowerTrackerBackgroundFrame:CreateFontString("BalancePowerTrackerEnergyText","OVERLAY","GameFontNormal")
	end
	BalancePowerTracker.frames.background.energyText:SetDrawLayer( "OVERLAY" ,0)
	BalancePowerTracker.frames.background.energyText:ClearAllPoints();
	BalancePowerTracker.frames.background.energyText:SetPoint("CENTER",0,0)
	if BalancePowerTracker.options.autoFontSizeText then
		BalancePowerTracker.frames.background.energyText:SetFont(style.font, max(height*0.9,14))
	else
		BalancePowerTracker.frames.background.energyText:SetFont(style.font,BalancePowerTracker.options.fontSizeText)
	end
	BalancePowerTracker.frames.background.energyText:SetText("0")
	color = BalancePowerTracker.barColor.text
	BalancePowerTracker.frames.background.energyText:SetTextColor(color.r, color.g, color.b, color.a)
	if BalancePowerTracker.options.showText then
		BalancePowerTracker.frames.background.energyText:Show()
	else
		BalancePowerTracker.frames.background.energyText:Hide()
	end

	--Spark
	local sparkColor = BalancePowerTracker.barColor.spark
	if not BalancePowerTracker.frames.background.spark then
		BalancePowerTracker.frames.background.spark = BalancePowerTrackerBackgroundFrame:CreateTexture(nil, "OVERLAY")
	end
	BalancePowerTracker.frames.background.spark:SetDrawLayer( "OVERLAY" ,0)
	BalancePowerTracker.frames.background.spark:ClearAllPoints();
	BalancePowerTracker.frames.background.spark:SetPoint("CENTER",0,1)
	if BalancePowerTracker.options.usearrow then
		BalancePowerTracker.vars.sparkYOffset = 1
		BalancePowerTracker.frames.background.spark:SetHeight(max(height*1.5,20)*BalancePowerTracker.options.arrowScale)
		BalancePowerTracker.frames.background.spark:SetWidth(max(height*1.5,20)*BalancePowerTracker.options.arrowScale)
		BalancePowerTracker.frames.background.spark:SetTexture("Interface\\PlayerFrame\\UI-DruidEclipse")
		BalancePowerTracker.frames.background.spark:SetBlendMode("ADD")
		BalancePowerTracker.frames.background.spark.direction = "none"
		if BalancePowerTracker.options.vertical then
			BalancePowerTracker.frames.background.spark:SetTexCoord(1,0.82,0.914,0.82,1,1,0.914,1);
		else
			BalancePowerTracker.frames.background.spark:SetTexCoord(1.0,0.914,0.82, 1.0)
		end
	else
		BalancePowerTracker.vars.sparkYOffset = -1
		BalancePowerTracker.frames.background.spark:SetHeight(height*3.2)
		BalancePowerTracker.frames.background.spark:SetWidth(height*3.2)
		BalancePowerTracker.frames.background.spark:SetTexture(sparkColor.r, sparkColor.g, sparkColor.b, sparkColor.a)
		BalancePowerTracker.frames.background.spark:SetTexture(style.spark)
		if BalancePowerTracker.options.vertical then
			BalancePowerTracker.frames.background.spark:SetTexCoord(1,0,0,0,1,1,0,1)
		else
			BalancePowerTracker.frames.background.spark:SetTexCoord(0,1,0,1)
		end
		if BalancePowerTracker.options.styleName == "classic" then
			BalancePowerTracker.frames.background.spark:SetBlendMode("BLEND")
		else
			BalancePowerTracker.frames.background.spark:SetBlendMode("ADD")
		end
	end


	--Lunar Eclipse Frame
	if not BalancePowerTracker.frames.lEclipseIcon then
		BalancePowerTracker.frames.lEclipseIcon = CreateFrame("Button","BalancePowerTrackerLunarEclipseIconFrame",BalancePowerTrackerBackgroundFrame)
	end
	BalancePowerTracker.frames.lEclipseIcon:EnableMouse(false)
	BalancePowerTracker.frames.lEclipseIcon:ClearAllPoints();
	if BalancePowerTracker.options.vertical then
		BalancePowerTracker.frames.lEclipseIcon:SetPoint("TOP",BalancePowerTrackerBackgroundFrame,"BOTTOM",0,-iconOffset)
	else
		BalancePowerTracker.frames.lEclipseIcon:SetPoint("RIGHT",BalancePowerTrackerBackgroundFrame,"LEFT",-iconOffset,0)
	end
	BalancePowerTracker.frames.lEclipseIcon:SetWidth(sideicon)
	BalancePowerTracker.frames.lEclipseIcon:SetHeight(sideicon)
	BalancePowerTracker.frames.lEclipseIcon:SetFrameStrata(BalancePowerTracker.options.strata)

	--Solar Eclipse Frame
	if not BalancePowerTracker.frames.sEclipseIcon then
		BalancePowerTracker.frames.sEclipseIcon = CreateFrame("Button","BalancePowerTrackerSolarEclipseIconFrame",BalancePowerTrackerBackgroundFrame)
	end
	BalancePowerTracker.frames.sEclipseIcon:EnableMouse(false)
	BalancePowerTracker.frames.sEclipseIcon:ClearAllPoints();
	if BalancePowerTracker.options.vertical then
		BalancePowerTracker.frames.sEclipseIcon:SetPoint("BOTTOM",BalancePowerTrackerBackgroundFrame,"TOP",0,iconOffset)
	else
		BalancePowerTracker.frames.sEclipseIcon:SetPoint("LEFT",BalancePowerTrackerBackgroundFrame,"RIGHT",iconOffset,0)
	end
	BalancePowerTracker.frames.sEclipseIcon:SetWidth(sideicon)
	BalancePowerTracker.frames.sEclipseIcon:SetHeight(sideicon)
	BalancePowerTracker.frames.sEclipseIcon:SetFrameStrata(BalancePowerTracker.options.strata)

	if BalancePowerTracker.options.hideIcon then
		BalancePowerTracker.frames.lEclipseIcon:Hide();
		BalancePowerTracker.frames.sEclipseIcon:Hide();
	else
		BalancePowerTracker.frames.lEclipseIcon:Show();
		BalancePowerTracker.frames.sEclipseIcon:Show();
	end

	BalancePowerTracker.frames.lEclipseIcon:SetScale(1)
	BalancePowerTracker.frames.sEclipseIcon:SetScale(1)
	BalancePowerTracker.vars.iconsDirection = "none";
	ActionButton_HideOverlayGlow(BalancePowerTracker.frames.lEclipseIcon)
	ActionButton_HideOverlayGlow(BalancePowerTracker.frames.sEclipseIcon)

	--Lunar Icon texture
	if not BalancePowerTracker.frames.lEclipseIcon.tex then
		BalancePowerTracker.frames.lEclipseIcon.tex = BalancePowerTrackerLunarEclipseIconFrame:CreateTexture("BalancePowerTrackerLunarEclipseIconFrameIcon", "ARTWORK",nil,0)
	end
	BalancePowerTracker.frames.lEclipseIcon.tex:SetDrawLayer( "ARTWORK" ,0)
	BalancePowerTracker.frames.lEclipseIcon.tex:ClearAllPoints();
	BalancePowerTracker.frames.lEclipseIcon.tex:SetPoint("CENTER")
	BalancePowerTracker.frames.lEclipseIcon.tex:Show()
	BalancePowerTracker.frames.lEclipseIcon.tex:SetWidth(sideicon)
	BalancePowerTracker.frames.lEclipseIcon.tex:SetHeight(sideicon)

	--Solar Icon texture
	if not BalancePowerTracker.frames.sEclipseIcon.tex then
		BalancePowerTracker.frames.sEclipseIcon.tex = BalancePowerTrackerSolarEclipseIconFrame:CreateTexture("BalancePowerTrackerSolarEclipseIconFrameIcon", "ARTWORK",nil,0)
	end
	BalancePowerTracker.frames.sEclipseIcon.tex:SetDrawLayer( "ARTWORK" ,0)
	BalancePowerTracker.frames.sEclipseIcon.tex:ClearAllPoints();
	BalancePowerTracker.frames.sEclipseIcon.tex:SetPoint("CENTER")
	BalancePowerTracker.frames.sEclipseIcon.tex:Show()
	BalancePowerTracker.frames.sEclipseIcon.tex:SetWidth(sideicon)
	BalancePowerTracker.frames.sEclipseIcon.tex:SetHeight(sideicon)

	--Lunar Icon Highlight
	if not BalancePowerTracker.frames.lEclipseIcon.highlight then
		BalancePowerTracker.frames.lEclipseIcon.highlight = BalancePowerTrackerLunarEclipseIconFrame:CreateTexture(nil, "ARTWORK",nil,1)
	end
	BalancePowerTracker.frames.lEclipseIcon.highlight:SetDrawLayer( "ARTWORK" ,1)
	BalancePowerTracker.frames.lEclipseIcon.highlight:ClearAllPoints();
	BalancePowerTracker.frames.lEclipseIcon.highlight:SetPoint("CENTER")
	BalancePowerTracker.frames.lEclipseIcon.highlight:Hide()

	--Solar Icon Highlight
	if not BalancePowerTracker.frames.sEclipseIcon.highlight then
		BalancePowerTracker.frames.sEclipseIcon.highlight = BalancePowerTrackerSolarEclipseIconFrame:CreateTexture(nil, "ARTWORK",nil,1)
	end
	BalancePowerTracker.frames.sEclipseIcon.highlight:SetDrawLayer( "ARTWORK" ,1)
	BalancePowerTracker.frames.sEclipseIcon.highlight:ClearAllPoints();
	BalancePowerTracker.frames.sEclipseIcon.highlight:SetPoint("CENTER")
	BalancePowerTracker.frames.sEclipseIcon.highlight:Hide()

	if BalancePowerTracker.options.originalEclipseIcons then
		if not BalancePowerTracker.vars.lbfdisabled then
			BalancePowerTracker:ButtonFacade_Reskin()
		end
		BalancePowerTracker.frames.lEclipseIcon.tex:SetTexture("Interface\\PlayerFrame\\UI-DruidEclipse")
		BalancePowerTracker.frames.sEclipseIcon.tex:SetTexture("Interface\\PlayerFrame\\UI-DruidEclipse")
		BalancePowerTracker.frames.sEclipseIcon.highlight:SetTexture(nil)
		BalancePowerTracker.frames.lEclipseIcon.highlight:SetTexture(nil)
		BalancePowerTracker.frames.lEclipseIcon.highlight:SetBlendMode("BLEND")
		BalancePowerTracker.frames.sEclipseIcon.highlight:SetBlendMode("BLEND")
		BalancePowerTracker.frames.sEclipseIcon.highlight:SetWidth(sideicon)
		BalancePowerTracker.frames.sEclipseIcon.highlight:SetHeight(sideicon)
		BalancePowerTracker.frames.lEclipseIcon.highlight:SetWidth(sideicon)
		BalancePowerTracker.frames.lEclipseIcon.highlight:SetHeight(sideicon)
		BalancePowerTracker.frames.sEclipseIcon.tex:SetTexCoord(0.55859375,0.72656250,0.00781250,0.35937500)
		BalancePowerTracker.frames.lEclipseIcon.tex:SetTexCoord(0.73437500,0.90234375,0.00781250,0.35937500)
	else
		BalancePowerTracker.frames.lEclipseIcon.tex:SetTexture(style.iconLunar)
		BalancePowerTracker.frames.sEclipseIcon.tex:SetTexture(style.iconSolar)
		BalancePowerTracker.frames.sEclipseIcon.highlight:SetTexture(style.solarIconHighlight)
		BalancePowerTracker.frames.lEclipseIcon.highlight:SetTexture(style.lunarIconHighlight)
		BalancePowerTracker.frames.lEclipseIcon.highlight:SetBlendMode("ADD")
		BalancePowerTracker.frames.sEclipseIcon.highlight:SetBlendMode("ADD")
		BalancePowerTracker.frames.sEclipseIcon.highlight:SetWidth(sideicon*1.65)
		BalancePowerTracker.frames.sEclipseIcon.highlight:SetHeight(sideicon*1.65)
		BalancePowerTracker.frames.lEclipseIcon.highlight:SetWidth(sideicon*1.65)
		BalancePowerTracker.frames.lEclipseIcon.highlight:SetHeight(sideicon*1.65)
		BalancePowerTracker.frames.sEclipseIcon.tex:SetTexCoord(0,1,0,1)
		BalancePowerTracker.frames.lEclipseIcon.tex:SetTexCoord(0,1,0,1)
		BalancePowerTracker.frames.sEclipseIcon.highlight:SetTexCoord(0,1,0,1)
		BalancePowerTracker.frames.lEclipseIcon.highlight:SetTexCoord(0,1,0,1)
		if not BalancePowerTracker.vars.lbfdisabled then
			BalancePowerTracker:ButtonFacade_Reskin()
		end
	end

	-- Warning Background
	color = BalancePowerTracker.barColor.background
	if not BalancePowerTracker.warnings.background then
		BalancePowerTracker.warnings.background = CreateFrame("Frame","BalancePowerTrackerWarningsBackgroundFrame",UIParent)
	end
	BalancePowerTracker.warnings.background:SetFrameStrata(BalancePowerTracker.options.strata)
	BalancePowerTracker.warnings.background:SetMovable(true)
	BalancePowerTracker.warnings.background:ClearAllPoints();
	BalancePowerTracker.warnings.background:SetPoint(BalancePowerTracker.warnings.options.point,BalancePowerTracker.warnings.options.x,BalancePowerTracker.warnings.options.y)
	BalancePowerTracker.warnings.background:SetClampedToScreen(true)
		BalancePowerTracker.warnings.background:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = nil,
		tile = false, tileSize = 0, edgeSize = 12,
		insets = {top =2, bottom=2, left =2, right =2,},
	})
	BalancePowerTracker.warnings.background:SetWidth(BalancePowerTracker.warnings.options.fontSize*10)
	BalancePowerTracker.warnings.background:SetHeight(BalancePowerTracker.warnings.options.fontSize*1.2)
	BalancePowerTracker.warnings.background:SetScale(scale)
	if BalancePowerTracker.warnings.options.move then
		BalancePowerTracker.warnings.background:SetScript("OnMouseDown", function(self) self:StartMoving() end)
		BalancePowerTracker.warnings.background:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); BalancePowerTracker.warnings.options.point,_,_,BalancePowerTracker.warnings.options.x,BalancePowerTracker.warnings.options.y = self:GetPoint() end)
		BalancePowerTracker.warnings.background:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); BalancePowerTracker.warnings.options.point,_,_,BalancePowerTracker.warnings.options.x,BalancePowerTracker.warnings.options.y = self:GetPoint() end)
		BalancePowerTracker.warnings.background:EnableMouse(true)
		BalancePowerTracker.warnings.background:SetBackdropColor(color.r, color.g, color.b, color.a)
		BalancePowerTracker.warnings.background:Show();
	else
		BalancePowerTracker.warnings.background:SetScript("OnMouseDown", nil)
		BalancePowerTracker.warnings.background:SetScript("OnMouseUp", nil)
		BalancePowerTracker.warnings.background:SetScript("OnDragStop", nil)
		BalancePowerTracker.warnings.background:EnableMouse(false)
		BalancePowerTracker.warnings.background:SetBackdropColor(color.r, color.g, color.b, 0)
		BalancePowerTracker.warnings.background:Hide();
	end

	--Warning Text
	if not BalancePowerTracker.warnings.text then
		BalancePowerTracker.warnings.text=BalancePowerTrackerWarningsBackgroundFrame:CreateFontString("BalancePowerTrackerWarningText","OVERLAY","GameFontNormal")
	end
	BalancePowerTracker.warnings.text:ClearAllPoints();
	BalancePowerTracker.warnings.text:SetPoint("CENTER",0,0)
	BalancePowerTracker.warnings.text:SetFont(style.font,BalancePowerTracker.warnings.options.fontSize)
	BalancePowerTracker.warnings.text:SetText("Move Me!")
	BalancePowerTracker.warnings.text:SetTextColor(1, 1, 1, 1)

	--Flash frame
	if not BalancePowerTracker.frames.flash then
		BalancePowerTracker.frames.flash = CreateFrame("Frame", "BalancePowerTrackerFlashFrame",UIParent)
	end
	BalancePowerTracker.frames.flash:SetToplevel(true)
	BalancePowerTracker.frames.flash:SetFrameStrata("FULLSCREEN_DIALOG")
	BalancePowerTracker.frames.flash:SetAllPoints(UIParent)
	BalancePowerTracker.frames.flash:EnableMouse(false)
	BalancePowerTracker.frames.flash:Hide()
	if not BalancePowerTracker.frames.flash.texture then
		BalancePowerTracker.frames.flash.texture = BalancePowerTracker.frames.flash:CreateTexture(nil, "BACKGROUND")
	end
	BalancePowerTracker.frames.flash.texture:SetTexture(0.0,1.0,1.0,.15)
	BalancePowerTracker.frames.flash.texture:SetAllPoints(UIParent)
	BalancePowerTracker.frames.flash.texture:SetAlpha(1)
	BalancePowerTracker.frames.flash.texture:SetBlendMode("ADD")


	--SolarEclipse Prob Text
	if not BalancePowerTracker.frames.solareclipseprob then
		BalancePowerTracker.frames.solareclipseprob = BalancePowerTrackerSolarEclipseIconFrame:CreateFontString("BalancePowerTrackerSolarEclipseProbText","OVERLAY","GameFontNormal")
	end
	BalancePowerTracker.frames.solareclipseprob:ClearAllPoints();
	BalancePowerTracker.frames.solareclipseprob:SetPoint("CENTER",0,0)
	BalancePowerTracker.frames.solareclipseprob:SetFont(style.font,BalancePowerTracker.options.probEclipseFontSize)
	BalancePowerTracker.frames.solareclipseprob:SetText("0%")
	BalancePowerTracker.frames.solareclipseprob:SetTextColor(1, 1, 1, 1)
	--LunarEclipse Prob Text
	if not BalancePowerTracker.frames.lunareclipseprob then
		BalancePowerTracker.frames.lunareclipseprob = BalancePowerTrackerLunarEclipseIconFrame:CreateFontString("BalancePowerTrackerLunarEclipseProbText","OVERLAY","GameFontNormal")
	end
	BalancePowerTracker.frames.lunareclipseprob:ClearAllPoints();
	BalancePowerTracker.frames.lunareclipseprob:SetPoint("CENTER",0,0)
	BalancePowerTracker.frames.lunareclipseprob:SetFont(style.font,BalancePowerTracker.options.probEclipseFontSize)
	BalancePowerTracker.frames.lunareclipseprob:SetText("0%")
	BalancePowerTracker.frames.lunareclipseprob:SetTextColor(1, 1, 1, 1)


	if BalancePowerTracker.options.extMod then BalancePowerTracker_SharedInfo.style[BalancePowerTracker.options.extMod].Redraw(BalancePowerTracker.frames,BalancePowerTracker.options) end

	BalancePowerTracker:CheckEcplipseBuff() --Checks Eclipse buff whenever you redraw interface
	BalancePowerTracker:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo())  --Forces Redraw Interface
end
function BalancePowerTracker:Move() -- Enables moving the frame
	BalancePowerTracker.vars.move = not BalancePowerTracker.vars.move

	if BalancePowerTracker.vars.move then
		BalancePowerTracker.frames.background:SetScript("OnMouseDown", function(self) self:StartMoving() end)
		BalancePowerTracker.frames.background:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); BalancePowerTracker.options.point,_,_,BalancePowerTracker.options.x,BalancePowerTracker.options.y = self:GetPoint() end)
		BalancePowerTracker.frames.background:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() BalancePowerTracker.options.point,_,_,BalancePowerTracker.options.x,BalancePowerTracker.options.y = self:GetPoint() end)
		BalancePowerTracker.frames.background:EnableMouse(true)
	else
		BalancePowerTracker.frames.background:SetScript("OnMouseDown", nil)
		BalancePowerTracker.frames.background:SetScript("OnMouseUp", nil)
		BalancePowerTracker.frames.background:SetScript("OnDragStop", nil)
		BalancePowerTracker.frames.background:EnableMouse(false)
	end

	if BalancePowerTracker.options.extMod then BalancePowerTracker_SharedInfo.style[BalancePowerTracker.options.extMod].Move(BalancePowerTracker.frames,BalancePowerTracker.vars.move) end
	return BalancePowerTracker.vars.move
end
function BalancePowerTracker.warnings:Move() -- Enables moving the frame
	BalancePowerTracker.warnings.options.move = not BalancePowerTracker.warnings.options.move

	local color = BalancePowerTracker.barColor.background

	if BalancePowerTracker.warnings.options.move then
		BalancePowerTracker.warnings.background:SetScript("OnMouseDown", function(self) self:StartMoving() end)
		BalancePowerTracker.warnings.background:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); BalancePowerTracker.warnings.options.point,_,_,BalancePowerTracker.warnings.options.x,BalancePowerTracker.warnings.options.y = self:GetPoint() end)
		BalancePowerTracker.warnings.background:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); BalancePowerTracker.warnings.options.point,_,_,BalancePowerTracker.warnings.options.x,BalancePowerTracker.warnings.options.y = self:GetPoint() end)
		BalancePowerTracker.warnings.background:EnableMouse(true)
		BalancePowerTracker.warnings.text:SetText("Move Me!")
		BalancePowerTracker.warnings.text:SetTextColor(1, 1, 1, 1)
		BalancePowerTracker.warnings.background:SetBackdropColor(color.r, color.g, color.b, color.a)
		BalancePowerTracker.warnings.background:Show();
	else
		BalancePowerTracker.warnings.background:SetScript("OnMouseDown", nil)
		BalancePowerTracker.warnings.background:SetScript("OnMouseUp", nil)
		BalancePowerTracker.warnings.background:SetScript("OnDragStop", nil)
		BalancePowerTracker.warnings.background:EnableMouse(false)
		BalancePowerTracker.warnings.background:SetBackdropColor(color.r, color.g, color.b, 0)
		BalancePowerTracker.warnings.background:Hide();
	end

	return BalancePowerTracker.warnings.options.move
end

--Events to check default frame visibility
--Only loading events & recheck
function BalancePowerTracker:CheckBlizzardFrameStatus() --shows & hides default blizzard frame
	--available on login when load, on entering when reload
	if (BalancePowerTracker.vars.isBalance) and (BalancePowerTracker.options.hideBlizzards and BalancePowerTracker.options.enabled) then
		EclipseBarFrame:Hide();
		EclipseBarFrame:SetScript("OnEvent", nil)
		EclipseBarFrame:SetScript("OnShow", function()	EclipseBarFrame:Hide() end)
		BalancePowerTracker.vars.tainted=true;
	elseif BalancePowerTracker.vars.tainted then
		local nStance = GetShapeshiftFormID()
		EclipseBarFrame:SetScript("OnEvent", BalancePowerTracker.vars.functBlizzOnEvent)
		EclipseBarFrame:SetScript("OnShow", BalancePowerTracker.vars.functBlizzOnShow)

		if BalancePowerTracker.vars.isBalance and (nStance == MOONKIN_FORM or not nStance) and not UnitHasVehicleUI("player") then
			EclipseBarFrame:Show();
		else
			EclipseBarFrame:Hide();
		end
	end
end

-- Events to recheck the talents
function BalancePowerTracker:ACTIVE_TALENT_GROUP_CHANGED() --Update SS energy & isBalance when changing specs
	BalancePowerTracker:ReCheck()
end
function BalancePowerTracker:CHARACTER_POINTS_CHANGED() --Update SS energy & isBalance spending a talent point
	BalancePowerTracker:ReCheck()
end
function BalancePowerTracker:ReCheck() --calls IsBalance, CheckBlizzardFrameStatus, CheckHiddenStatus & forces redraw frames
	BalancePowerTracker:IsBalanceDruid() --Spells -> isMoonkin?
	BalancePowerTracker:RegisterCombatLogEvent() --Register/unregister Combat log events
	BalancePowerTracker:CheckBlizzardFrameStatus() -- Forms & EclipseBarFrame -> Show/Hide default frame
	BalancePowerTracker:CheckHiddenStatus(); --Forms -> Check Addon Hidden status
	BalancePowerTracker:RecalcEnergy(LibBalancePowerTracker:GetEclipseEnergyInfo())  --Forces redraw
end
function BalancePowerTracker:IsBalanceDruid() --Modifies BalancePowerTracker.vars.isBalance
	--Available post login
	BalancePowerTracker.vars.isBalance = (GetSpellCooldown(BalancePowerTracker.spells.SS.name)~=nil)
end
function BalancePowerTracker:RegisterCombatLogEvent() --register & unregister combat log events
	if BalancePowerTracker.vars.isBalance and BalancePowerTracker.options.enabled then
		BalancePowerTrackerBackgroundFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	else
		BalancePowerTrackerBackgroundFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	end
end

--Events to check addon visibility
function BalancePowerTracker:PLAYER_REGEN_ENABLED() --Set alpha to Out of combat alpha
	if not BalancePowerTracker.options.visible then
		BalancePowerTracker.frames.background:SetAlpha(0);
	else
		BalancePowerTracker.frames.background:SetAlpha(BalancePowerTracker.options.alphaOOC);
	end
end
function BalancePowerTracker:PLAYER_REGEN_DISABLED() --Set alpha to Combat alpha
	if not BalancePowerTracker.options.visible then
		BalancePowerTracker.frames.background:SetAlpha(0);
	else
		BalancePowerTracker.frames.background:SetAlpha(BalancePowerTracker.options.alpha);
	end
end
function BalancePowerTracker:UPDATE_SHAPESHIFT_FORM() -- hide/show background in forms
	BalancePowerTracker:CheckHiddenStatus()
end
function BalancePowerTracker:UNIT_ENTERED_VEHICLE(UnitId) -- hide background in vehicle
	if UnitId == "player" then
		BalancePowerTracker:CheckHiddenStatus()
	end
end
function BalancePowerTracker:UNIT_EXITED_VEHICLE(UnitId) -- show background out of vehicle
	if UnitId == "player" then
		BalancePowerTracker:CheckHiddenStatus()
	end
end
function BalancePowerTracker:CheckHiddenStatus() -- Shows or hides addon (via background:Hide
	--available on login
	if (not BalancePowerTracker.options.enabled) or UnitHasVehicleUI("player") then
		BalancePowerTracker.frames.background:Hide();
		BalancePowerTracker_SharedInfo.hidden = true
		return
	end

	local nStance = GetShapeshiftFormID()
	if BalancePowerTracker.vars.isBalance and (((not BalancePowerTracker.options.showCustom) and (nStance==MOONKIN_FORM or (not (BalancePowerTracker.options.showOIM or nStance)) or BalancePowerTracker.options.showOOF)) or (BalancePowerTracker.options.showCustom and BalancePowerTracker.options.showCustomTable[tostring(nStance)])) then
		BalancePowerTracker.frames.background:Show();
		BalancePowerTracker_SharedInfo.hidden = false
	else
		BalancePowerTracker.frames.background:Hide();
		BalancePowerTracker_SharedInfo.hidden = true
	end
end

--Update
function BalancePowerTracker:RecalcEnergy(energy,direction,vEnergy,vDirection,reachEnd)
	reachEnd = (direction ~= vDirection) and ((vDirection == "sun" and -100) or (vDirection == "moon" and 100)) 
	
	if reachEnd and not (BalancePowerTracker.vars.virtualEclipse or BalancePowerTracker.vars.eclipse) then --Activate virtual Eclipse
		if reachEnd==100 then
			BalancePowerTracker.vars.virtualEclipse = "S";
			BalancePowerTracker:Warning(false,"S")
			BalancePowerTracker:UpdateEclipse()
		elseif reachEnd==-100 then
			BalancePowerTracker.vars.virtualEclipse = "L";
			BalancePowerTracker:Warning(false,"L")
			BalancePowerTracker:UpdateEclipse()
		end
	elseif BalancePowerTracker.vars.virtualEclipse and not reachEnd then  --No virtual Eclipse
		BalancePowerTracker:Warning(false,BalancePowerTracker.vars.virtualEclipse.."Failed")
		BalancePowerTracker.vars.virtualEclipse = false
		BalancePowerTracker:UpdateEclipse()
	end

	BalancePowerTracker:Update(energy,vEnergy,reachEnd,direction,vDirection)
end
function BalancePowerTracker:Update(realEnergy,virtualEnergy,reachEnd,realDirection,virtualDirection)
	if  BalancePowerTracker.frames.background:IsShown() then
		if BalancePowerTracker.options.extMod and BalancePowerTracker_SharedInfo.style[BalancePowerTracker.options.extMod].OnUpdate(BalancePowerTracker.frames,BalancePowerTracker.options, realEnergy,virtualEnergy,realDirection,virtualDirection,reachEnd) then return end

		BalancePowerTracker:UpdateSharedInfo(realEnergy,virtualEnergy,realDirection,virtualDirection,reachEnd);
		if BalancePowerTracker.options.visible then
			if BalancePowerTracker.options.vertical then
				BalancePowerTracker:UpdateVerticalFrames(realEnergy,virtualEnergy,realDirection,virtualDirection,reachEnd)
			else
				BalancePowerTracker:UpdateFrames(realEnergy,virtualEnergy,realDirection,virtualDirection,reachEnd)
			end
		end
	end
end
function BalancePowerTracker:UpdateSharedInfo(realEnergy,virtualEnergy,realDirection,virtualDirection,reachEnd) --Updates Shared Info
	BalancePowerTracker_SharedInfo.reachEnd = reachEnd
	BalancePowerTracker_SharedInfo.realEnergy = realEnergy
	BalancePowerTracker_SharedInfo.virtualEnergy = virtualEnergy
	BalancePowerTracker_SharedInfo.realDirection = realDirection
	BalancePowerTracker_SharedInfo.virtualDirection = virtualDirection
	BalancePowerTracker_SharedInfo.version =  BalancePowerTracker.vars.version
	BalancePowerTracker_SharedInfo.eclipse =  BalancePowerTracker.vars.eclipse
	BalancePowerTracker_SharedInfo.virtualEclipse = BalancePowerTracker.vars.virtualEclipse
	BalancePowerTracker_SharedInfo.foreseeEnergy = BalancePowerTracker.options.foreseeEnergy
end
--    	interface functions
function BalancePowerTracker:UpdateFrames(realEnergy,virtualEnergy,realDirection,virtualDirection,reachEnd) -- Redraws frames accordingly
	if BalancePowerTracker.options.colorBarDirection then
		if BalancePowerTracker.options.showVirtualOnColoredBar then
			BalancePowerTracker:ColorBarDirection(virtualDirection,virtualEnergy)
		else
			BalancePowerTracker:ColorBarDirection(realDirection,realEnergy)
		end
	end

	if BalancePowerTracker.options.showVirtualOnIcon then
		BalancePowerTracker:UpdateIconScale(virtualDirection,virtualEnergy)
	else
		BalancePowerTracker:UpdateIconScale(realDirection,realEnergy)
	end

	local width = BalancePowerTracker.options.width

	if BalancePowerTracker.options.addForeseenEnergyToBar then --Updates foresee energy bar only if addForeseenEnergy is on
		if reachEnd and reachEnd~=virtualEnergy then
			BalancePowerTracker:BetweenEnergyWidth(reachEnd/200,virtualEnergy/200,width);
			if not BalancePowerTracker.options.moveSparkOnly then BalancePowerTracker:EnergyWidth(reachEnd/200,width); end --Updates bar width only if growbars is on
		else
			BalancePowerTracker:BetweenEnergyWidth(realEnergy/200,virtualEnergy/200,width);
			if not BalancePowerTracker.options.moveSparkOnly then BalancePowerTracker:EnergyWidth(realEnergy/200,width); end --Updates bar width only if growbars is on
		end
	else
		if not BalancePowerTracker.options.moveSparkOnly then BalancePowerTracker:EnergyWidth(realEnergy/200,width); end --Updates bar width only if growbars is on
	end

	if BalancePowerTracker.options.showVirtualOnSpark then
		BalancePowerTracker:UpdateSpark(virtualEnergy/200,width,virtualDirection);
	else
		BalancePowerTracker:UpdateSpark(realEnergy/200,width,realDirection);
		virtualDirection = realDirection --In case you want to take text out of the way
	end

	if BalancePowerTracker.options.showText and BalancePowerTracker.options.showVirtualOnText then
		BalancePowerTracker:UpdateEnergyText(virtualEnergy,virtualDirection);
	elseif BalancePowerTracker.options.showText then
		BalancePowerTracker:UpdateEnergyText(realEnergy,virtualDirection);
	end
end
function BalancePowerTracker:UpdateVerticalFrames(realEnergy,virtualEnergy,realDirection,virtualDirection,reachEnd) --Copy of UpdateFrames, only for vertical bars
	if BalancePowerTracker.options.colorBarDirection then
		if BalancePowerTracker.options.showVirtualOnColoredBar then
			BalancePowerTracker:ColorBarDirection(virtualDirection,virtualEnergy)
		else
			BalancePowerTracker:ColorBarDirection(realDirection,realEnergy)
		end
	end

	if BalancePowerTracker.options.showVirtualOnIcon then
		BalancePowerTracker:UpdateIconScale(virtualDirection,virtualEnergy)
	else
		BalancePowerTracker:UpdateIconScale(realDirection,realEnergy)
	end

	local width = BalancePowerTracker.options.width

	if BalancePowerTracker.options.addForeseenEnergyToBar then --Updates foresee energy bar only if addForeseenEnergy is on
		if reachEnd and reachEnd~=virtualEnergy then
			BalancePowerTracker:BetweenEnergyWidthV(reachEnd/200,virtualEnergy/200,width);
			if not BalancePowerTracker.options.moveSparkOnly then BalancePowerTracker:EnergyWidthV(reachEnd/200,width);	end --Updates bar width only if growbars is on
		else
			BalancePowerTracker:BetweenEnergyWidthV(realEnergy/200,virtualEnergy/200,width);
			if not BalancePowerTracker.options.moveSparkOnly then BalancePowerTracker:EnergyWidthV(realEnergy/200,width); end --Updates bar width only if growbars is on
		end
	else
		if not BalancePowerTracker.options.moveSparkOnly then BalancePowerTracker:EnergyWidthV(realEnergy/200,width); end --Updates bar width only if growbars is on
	end

	if BalancePowerTracker.options.showVirtualOnSpark then
		BalancePowerTracker:UpdateSparkV(virtualEnergy/200,width,virtualDirection);
	else
		BalancePowerTracker:UpdateSparkV(realEnergy/200,width,realDirection);
		virtualDirection = realDirection --In case you want to take text out of the way
	end

	if BalancePowerTracker.options.showText and BalancePowerTracker.options.showVirtualOnText then
		BalancePowerTracker:UpdateEnergyTextV(virtualEnergy,virtualDirection);
	elseif BalancePowerTracker.options.showText then
		BalancePowerTracker:UpdateEnergyTextV(realEnergy,virtualDirection);
	end
end
--functions called by both UpdateFrames
function BalancePowerTracker:UpdateIconScale(direction,energy)
	if (direction == BalancePowerTracker.vars.iconsDirection and direction ~= "none") or (not BalancePowerTracker.options.bigIcons) then return end
	BalancePowerTracker.vars.iconsDirection = direction;

	if (direction == "moon" or (direction == "none" and energy < 0)) then
		BalancePowerTracker.frames.lEclipseIcon:SetScale(BalancePowerTracker.options.bigIconScale)
		BalancePowerTracker.frames.sEclipseIcon:SetScale(1)
	elseif (direction == "sun" or (direction == "none" and energy > 0)) then
		BalancePowerTracker.frames.lEclipseIcon:SetScale(1)
		BalancePowerTracker.frames.sEclipseIcon:SetScale(BalancePowerTracker.options.bigIconScale)
	elseif (direction == "none") and (energy == 0) then
		BalancePowerTracker.frames.lEclipseIcon:SetScale(BalancePowerTracker.options.bigIconScale)
		BalancePowerTracker.frames.sEclipseIcon:SetScale(BalancePowerTracker.options.bigIconScale)
	end
end
function BalancePowerTracker:ColorBetweenBarDirection(direction)
	if direction == BalancePowerTracker.vars.virtualBarDirection then
		return
	elseif direction == 0 then
		local bColor = BalancePowerTracker.barColor.virtualSolarEnergyBar;
		BalancePowerTracker.vars.virtualBarDirection = 0;
		BalancePowerTracker.frames.background.benergy:SetGradientAlpha("VERTICAL",bColor.r, bColor.g, bColor.b, bColor.a, bColor.r, bColor.g, bColor.b, bColor.a)
	elseif direction == 1 then
		local bColor = BalancePowerTracker.barColor.virtualLunarEnergyBar;
		BalancePowerTracker.vars.virtualBarDirection = 1;
		BalancePowerTracker.frames.background.benergy:SetGradientAlpha("VERTICAL",bColor.r, bColor.g, bColor.b, bColor.a, bColor.r, bColor.g, bColor.b, bColor.a)
	end
end
function BalancePowerTracker:ColorBarDirection(direction,energy)
	if BalancePowerTracker.vars.barDirection == direction and direction ~= "none" then return end;
	BalancePowerTracker.vars.barDirection = direction

	local lColor = BalancePowerTracker.barColor.lunarEnergyBar
	local sColor = BalancePowerTracker.barColor.solarEnergyBar;
	if direction == "moon" or (direction == "none" and energy < 0) then
		BalancePowerTracker.frames.background.lenergy:SetGradientAlpha("VERTICAL",sColor.r, sColor.g, sColor.b, sColor.a, sColor.r, sColor.g, sColor.b, sColor.a)
		BalancePowerTracker.frames.background.senergy:SetGradientAlpha("VERTICAL",sColor.r, sColor.g, sColor.b, sColor.a, sColor.r, sColor.g, sColor.b, sColor.a)
	elseif direction == "sun" or (direction == "none" and energy > 0) then
		BalancePowerTracker.frames.background.lenergy:SetGradientAlpha("VERTICAL",lColor.r, lColor.g, lColor.b, lColor.a, lColor.r, lColor.g, lColor.b, lColor.a)
		BalancePowerTracker.frames.background.senergy:SetGradientAlpha("VERTICAL",lColor.r, lColor.g, lColor.b, lColor.a, lColor.r, lColor.g, lColor.b, lColor.a)
	else
		BalancePowerTracker.frames.background.lenergy:SetGradientAlpha("VERTICAL",lColor.r, lColor.g, lColor.b, lColor.a, lColor.r, lColor.g, lColor.b, lColor.a)
		BalancePowerTracker.frames.background.senergy:SetGradientAlpha("VERTICAL",sColor.r, sColor.g, sColor.b, sColor.a, sColor.r, sColor.g, sColor.b, sColor.a)
	end
end
--horizontal Interface Options
function BalancePowerTracker:EnergyWidth(normalizedEnergy,width) -- Modifies the Solar/Lunar energy bar width & hides it if necesary
	if normalizedEnergy < 0 then
		BalancePowerTracker.frames.background.lenergy:SetWidth(-1* normalizedEnergy * width)
		BalancePowerTracker.frames.background.lenergy:SetTexCoord(.5 + normalizedEnergy,.5,0,1)
		BalancePowerTracker.frames.background.lenergy:Show()
		BalancePowerTracker.frames.background.senergy:Hide()
	elseif normalizedEnergy > 0 then
		BalancePowerTracker.frames.background.senergy:SetWidth(normalizedEnergy * width)
		BalancePowerTracker.frames.background.senergy:SetTexCoord(.5,.5 + normalizedEnergy,0,1)
		BalancePowerTracker.frames.background.senergy:Show()
		BalancePowerTracker.frames.background.lenergy:Hide()
	else
		BalancePowerTracker.frames.background.senergy:Hide()
		BalancePowerTracker.frames.background.lenergy:Hide()
	end
end
function BalancePowerTracker:BetweenEnergyWidth(normEnergyFrom,normEnergyTo,width) -- Modifies the Between energy bar width & position & hides it if necesary
	if normEnergyFrom==normEnergyTo then
		BalancePowerTracker.frames.background.benergy:Hide()
	else
		BalancePowerTracker.frames.background.benergy:ClearAllPoints();

		if normEnergyFrom<normEnergyTo then
			BalancePowerTracker.frames.background.benergy:SetWidth((normEnergyTo-normEnergyFrom)*width);
			BalancePowerTracker.frames.background.benergy:SetTexCoord(.5 + normEnergyFrom,.5 + normEnergyTo,0,1)
			BalancePowerTracker.frames.background.benergy:SetPoint("LEFT",BalancePowerTrackerBackgroundFrame,"CENTER",normEnergyFrom*width,0)
			BalancePowerTracker:ColorBetweenBarDirection(0)
		else
			BalancePowerTracker.frames.background.benergy:SetWidth((normEnergyFrom-normEnergyTo)*width);
			BalancePowerTracker.frames.background.benergy:SetTexCoord(.5 + normEnergyTo,.5 + normEnergyFrom,0,1)
			BalancePowerTracker.frames.background.benergy:SetPoint("RIGHT",BalancePowerTrackerBackgroundFrame,"CENTER",normEnergyFrom*width,0);
			BalancePowerTracker:ColorBetweenBarDirection(1)
		end
		BalancePowerTracker.frames.background.benergy:Show()
	end
end
function BalancePowerTracker:UpdateEnergyText(energy,direction) --Updates energy text based on normalized energy (energy/200)
	BalancePowerTracker.frames.background.energyText:SetText((BalancePowerTracker.options.absoluteText and abs(energy)) or energy);

	if BalancePowerTracker.options.moveText then
		BalancePowerTracker.frames.background.energyText:ClearAllPoints();
		if energy<0 or (energy == 0 and direction =="moon")  then
			BalancePowerTracker.frames.background.energyText:SetPoint("LEFT",BalancePowerTrackerBackgroundFrame,"CENTER",1,0)
		else
			BalancePowerTracker.frames.background.energyText:SetPoint("RIGHT",BalancePowerTrackerBackgroundFrame,"CENTER",-1,0)
		end
	end
end
function BalancePowerTracker:UpdateSpark(normEnergy,range,direction) --Updates Spark position based on normalized energy
	BalancePowerTracker.frames.background.spark:ClearAllPoints();
	BalancePowerTracker.frames.background.spark:SetPoint("CENTER",normEnergy*range,BalancePowerTracker.vars.sparkYOffset)
	if BalancePowerTracker.options.usearrow and direction~=BalancePowerTracker.frames.background.spark.direction then
		BalancePowerTracker.frames.background.spark:SetTexCoord(unpack(BalancePowerTracker.eclipseMarkerCoords[direction]));
		BalancePowerTracker.frames.background.spark.direction=direction
	end
end
--vertical Interface functions --Copy of the above, only modified to change vertical settings (too much CPU to check on every function, better use a bit more memory)
function BalancePowerTracker:EnergyWidthV(normalizedEnergy,width) -- Modifies the Solar/Lunar energy bar width & hides it if necesary
	if normalizedEnergy < 0 then
		BalancePowerTracker.frames.background.lenergy:SetHeight(-1* normalizedEnergy * width)
		BalancePowerTracker.frames.background.lenergy:SetTexCoord(.5 ,0,.5 + normalizedEnergy, 0,.5 ,1,.5+ normalizedEnergy,1)
		BalancePowerTracker.frames.background.lenergy:Show()
		BalancePowerTracker.frames.background.senergy:Hide()
	elseif normalizedEnergy > 0 then
		BalancePowerTracker.frames.background.senergy:SetHeight(normalizedEnergy * width)
		BalancePowerTracker.frames.background.senergy:SetTexCoord(.5 + normalizedEnergy,0,.5,0,.5 + normalizedEnergy,1,.5,1)
		BalancePowerTracker.frames.background.senergy:Show()
		BalancePowerTracker.frames.background.lenergy:Hide()
	else
		BalancePowerTracker.frames.background.senergy:Hide()
		BalancePowerTracker.frames.background.lenergy:Hide()
	end
end
function BalancePowerTracker:BetweenEnergyWidthV(normEnergyFrom,normEnergyTo,width) -- Modifies the Between energy bar width & position & hides it if necesary
	if normEnergyFrom==normEnergyTo then
		BalancePowerTracker.frames.background.benergy:Hide()
	else
		BalancePowerTracker.frames.background.benergy:ClearAllPoints();
		if normEnergyFrom<normEnergyTo then
			BalancePowerTracker.frames.background.benergy:SetHeight((normEnergyTo-normEnergyFrom)*width);
			BalancePowerTracker.frames.background.benergy:SetTexCoord(.5 + normEnergyTo,0,.5 + normEnergyFrom,0,.5 + normEnergyTo,1,.5 + normEnergyFrom,1)
			BalancePowerTracker.frames.background.benergy:SetPoint("BOTTOM",BalancePowerTrackerBackgroundFrame,"CENTER",0,normEnergyFrom*width)
			BalancePowerTracker:ColorBetweenBarDirection(0)
		else
			BalancePowerTracker.frames.background.benergy:SetHeight((normEnergyFrom-normEnergyTo)*width);
			BalancePowerTracker.frames.background.benergy:SetTexCoord(.5 + normEnergyFrom,0,.5 + normEnergyTo,0,.5 + normEnergyFrom,1,.5 + normEnergyTo,1)
			BalancePowerTracker.frames.background.benergy:SetPoint("TOP",BalancePowerTrackerBackgroundFrame,"CENTER",0,normEnergyFrom*width);
			BalancePowerTracker:ColorBetweenBarDirection(1)
		end
		BalancePowerTracker.frames.background.benergy:Show()
	end
end
function BalancePowerTracker:UpdateEnergyTextV(energy,direction) --Updates energy text based on normalized energy (energy/200)
	BalancePowerTracker.frames.background.energyText:SetText((BalancePowerTracker.options.absoluteText and abs(energy)) or energy);

	if BalancePowerTracker.options.moveText then
		BalancePowerTracker.frames.background.energyText:ClearAllPoints();
		if energy<0 or (energy == 0 and direction =="moon")  then
			BalancePowerTracker.frames.background.energyText:SetPoint("BOTTOM",BalancePowerTrackerBackgroundFrame,"CENTER",0,1)
		else
			BalancePowerTracker.frames.background.energyText:SetPoint("TOP",BalancePowerTrackerBackgroundFrame,"CENTER",0,-1)
		end
	end
end
function BalancePowerTracker:UpdateSparkV(normEnergy,range,direction) --Updates Spark position based on normalized energy
	BalancePowerTracker.frames.background.spark:ClearAllPoints();
	BalancePowerTracker.frames.background.spark:SetPoint("CENTER",-1*BalancePowerTracker.vars.sparkYOffset,normEnergy*range)
	if BalancePowerTracker.options.usearrow and direction~=BalancePowerTracker.frames.background.spark.direction then
		BalancePowerTracker.frames.background.spark:SetTexCoord(unpack(BalancePowerTracker.eclipseMarkerCoordsV[direction]));
		BalancePowerTracker.frames.background.spark.direction=direction
	end
end

--Update Eclipse
function BalancePowerTracker:CheckEcplipseBuff()--function to check eclipse buff on load
	if UnitBuff('player',BalancePowerTracker.spells.SE.name) then
		BalancePowerTracker.vars.eclipse = BalancePowerTracker.spells.SE.spellId
	elseif UnitBuff('player',BalancePowerTracker.spells.LE.name) then
		BalancePowerTracker.vars.eclipse = BalancePowerTracker.spells.LE.spellId
	else
		BalancePowerTracker.vars.eclipse = false
	end
	BalancePowerTracker:UpdateEclipse()
end
function BalancePowerTracker:UpdateEclipse() --Updates Eclipse-related info

	if not (BalancePowerTracker.vars.eclipse or BalancePowerTracker.vars.virtualEclipse) then --No eclipse
		if BalancePowerTracker.options.virtualSpellEffects then
			SpellActivationOverlay_OnEvent(SpellActivationOverlayFrame,  "SPELL_ACTIVATION_OVERLAY_HIDE", 93430)
			SpellActivationOverlay_OnEvent(SpellActivationOverlayFrame,  "SPELL_ACTIVATION_OVERLAY_HIDE", 93431)
		end
		if BalancePowerTracker.options.extMod and BalancePowerTracker_SharedInfo.style[BalancePowerTracker.options.extMod].NoEclipse(BalancePowerTracker.frames,BalancePowerTracker.options) then return end

		BalancePowerTracker.frames.lEclipseIcon.highlight:Hide()
		BalancePowerTracker.frames.sEclipseIcon.highlight:Hide()
		ActionButton_HideOverlayGlow(BalancePowerTracker.frames.lEclipseIcon)
		ActionButton_HideOverlayGlow(BalancePowerTracker.frames.sEclipseIcon)
	else
		if (BalancePowerTracker.vars.virtualEclipse=="L") then -- virtual lunar eclipse
			if BalancePowerTracker.options.virtualSpellEffects then SpellActivationOverlay_OnEvent(SpellActivationOverlayFrame,  "SPELL_ACTIVATION_OVERLAY_SHOW", 93431, "TEXTURES\\SPELLACTIVATIONOVERLAYS\\ECLIPSE_MOON.BLP", "TopLeft", 1, 244, 244, 244) end

			if BalancePowerTracker.options.extMod and BalancePowerTracker_SharedInfo.style[BalancePowerTracker.options.extMod].vLunarEclipse(BalancePowerTracker.frames,BalancePowerTracker.options) then return end

			if BalancePowerTracker.options.highlightIcons and BalancePowerTracker.options.showVirtualOnIcon and not BalancePowerTracker.options.originalEclipseIcons then
				if  BalancePowerTracker.options.dynamicGlow then
					ActionButton_ShowOverlayGlow(BalancePowerTracker.frames.lEclipseIcon)
					BalancePowerTracker.frames.lEclipseIcon.highlight:Hide()
				else
					ActionButton_HideOverlayGlow(BalancePowerTracker.frames.lEclipseIcon)
					BalancePowerTracker.frames.lEclipseIcon.highlight:Show()
				end
			else
				ActionButton_HideOverlayGlow(BalancePowerTracker.frames.lEclipseIcon)
				BalancePowerTracker.frames.lEclipseIcon.highlight:Hide()
			end

			ActionButton_HideOverlayGlow(BalancePowerTracker.frames.sEclipseIcon)
			BalancePowerTracker.frames.sEclipseIcon.highlight:Hide()
		elseif(BalancePowerTracker.vars.eclipse==BalancePowerTracker.spells.LE.spellId)then --Lunar Eclipse
			if BalancePowerTracker.options.extMod and BalancePowerTracker_SharedInfo.style[BalancePowerTracker.options.extMod].LunarEclipse(BalancePowerTracker.frames,BalancePowerTracker.options) then return end

			if BalancePowerTracker.options.highlightIcons and not BalancePowerTracker.options.originalEclipseIcons then
				if  BalancePowerTracker.options.dynamicGlow then
					ActionButton_ShowOverlayGlow(BalancePowerTracker.frames.lEclipseIcon)
					BalancePowerTracker.frames.lEclipseIcon.highlight:Hide()
				else
					ActionButton_HideOverlayGlow(BalancePowerTracker.frames.lEclipseIcon)
					BalancePowerTracker.frames.lEclipseIcon.highlight:Show()
				end
			else
				ActionButton_HideOverlayGlow(BalancePowerTracker.frames.lEclipseIcon)
				BalancePowerTracker.frames.lEclipseIcon.highlight:Hide()
			end

			ActionButton_HideOverlayGlow(BalancePowerTracker.frames.sEclipseIcon)
			BalancePowerTracker.frames.sEclipseIcon.highlight:Hide()
		elseif (BalancePowerTracker.vars.virtualEclipse=="S") then--virtual solar eclipse
			if BalancePowerTracker.options.virtualSpellEffects then SpellActivationOverlay_OnEvent(SpellActivationOverlayFrame,  "SPELL_ACTIVATION_OVERLAY_SHOW", 93430, "TEXTURES\\SPELLACTIVATIONOVERLAYS\\ECLIPSE_SUN.BLP", "TopRight", 1, 244, 244, 244) end

			if BalancePowerTracker.options.extMod and BalancePowerTracker_SharedInfo.style[BalancePowerTracker.options.extMod].vSolarEclipse(BalancePowerTracker.frames,BalancePowerTracker.options) then return end

			if BalancePowerTracker.options.highlightIcons and BalancePowerTracker.options.showVirtualOnIcon and not BalancePowerTracker.options.originalEclipseIcons then
				if  BalancePowerTracker.options.dynamicGlow then
					ActionButton_ShowOverlayGlow(BalancePowerTracker.frames.sEclipseIcon)
					BalancePowerTracker.frames.sEclipseIcon.highlight:Hide()
				else
					ActionButton_HideOverlayGlow(BalancePowerTracker.frames.sEclipseIcon)
					BalancePowerTracker.frames.sEclipseIcon.highlight:Show()
				end
			else
				ActionButton_HideOverlayGlow(BalancePowerTracker.frames.sEclipseIcon)
				BalancePowerTracker.frames.sEclipseIcon.highlight:Hide()
			end

			ActionButton_HideOverlayGlow(BalancePowerTracker.frames.lEclipseIcon)
			BalancePowerTracker.frames.lEclipseIcon.highlight:Hide()
		elseif(BalancePowerTracker.vars.eclipse == BalancePowerTracker.spells.SE.spellId) then --Solar Eclipse
			if BalancePowerTracker.options.extMod and BalancePowerTracker_SharedInfo.style[BalancePowerTracker.options.extMod].SolarEclipse(BalancePowerTracker.frames,BalancePowerTracker.options) then return end

			if BalancePowerTracker.options.highlightIcons and not BalancePowerTracker.options.originalEclipseIcons then
				if  BalancePowerTracker.options.dynamicGlow then
					ActionButton_ShowOverlayGlow(BalancePowerTracker.frames.sEclipseIcon)
					BalancePowerTracker.frames.sEclipseIcon.highlight:Hide()
				else
					ActionButton_HideOverlayGlow(BalancePowerTracker.frames.sEclipseIcon)
					BalancePowerTracker.frames.sEclipseIcon.highlight:Show()
				end
			else
				ActionButton_HideOverlayGlow(BalancePowerTracker.frames.sEclipseIcon)
				BalancePowerTracker.frames.sEclipseIcon.highlight:Hide()
			end

			ActionButton_HideOverlayGlow(BalancePowerTracker.frames.lEclipseIcon)
			BalancePowerTracker.frames.lEclipseIcon.highlight:Hide()
		end
	end
end
local WarningKeys = {
	[tostring(BalancePowerTracker.spells.LE.spellId)]	= {key = "warnLunar",   colorKey="lunarEnergyBar",			name=tostring(BalancePowerTracker.spells.LE.name)},
	[tostring(BalancePowerTracker.spells.SE.spellId)]	= {key = "warnSolar",   colorKey="solarEnergyBar",			name=tostring(BalancePowerTracker.spells.SE.name)},
	L 													= {key = "warnVLunar",  colorKey="virtualLunarEnergyBar",	name=tostring(BalancePowerTracker.spells.LE.name.." soon!")},
	S 													= {key = "warnVSolar",  colorKey="virtualSolarEnergyBar",	name=tostring(BalancePowerTracker.spells.SE.name.." soon!")},
	LFailed 											= {key = "warnVFailed", colorKey="virtualLunarEnergyBar",	name=tostring(BalancePowerTracker.spells.LE.name.." failed!")},
	SFailed 											= {key = "warnVFailed", colorKey="virtualSolarEnergyBar",	name=tostring(BalancePowerTracker.spells.SE.name.." failed!")},
}
function BalancePowerTracker:Warning(real, eclipse) --handles warnings
	local temp = WarningKeys[tostring(eclipse)]
	local warn = BalancePowerTracker.warnings.options[temp.key]
	local color = BalancePowerTracker.barColor[temp.colorKey];

	if warn and BalancePowerTracker.warnings.alert.enabled then
		BalancePowerTracker.warnings.text:SetText(temp.name)
		BalancePowerTracker.warnings.text:SetTextColor(color.r,color.g,color.b,1)
		UIFrameFlash(BalancePowerTrackerWarningsBackgroundFrame, 0, 0, 2, false,2,0 )
	end
	if warn and BalancePowerTracker.warnings.flasher.enabled then
		BalancePowerTracker.frames.flash.texture:SetTexture(color.r,color.g,color.b,BalancePowerTracker.warnings.flasher.alpha)
		UIFrameFlash(BalancePowerTracker.frames.flash, 0.20, 0.70, 2, false, 0.1, 0)
	end
	if warn and BalancePowerTracker.warnings.msbt.enabled then
		MikSBT.DisplayMessage(temp.name, BalancePowerTracker.warnings.msbt.scrollArea, BalancePowerTracker.warnings.msbt.sticky, color.r*255,color.g*255,color.b*255, BalancePowerTracker.warnings.msbt.fontSize, BalancePowerTracker.warnings.msbt.font, nil, nil)
	end

	if BalancePowerTracker.warnings.options.sound then PlaySoundFile(tostring(BalancePowerTracker.warnings.options.sounds[temp.key])) end
end

--Combat events
function BalancePowerTracker:COMBAT_LOG_EVENT_UNFILTERED(_,event,_,gUIDor,_,_,_,_,_,_,_,spellId) -- eclipse related functions
	if gUIDor ~= BalancePowerTracker.vars.playerGUID then return end

	if (spellId == BalancePowerTracker.spells.LE.spellId) or (spellId == BalancePowerTracker.spells.SE.spellId) then
		if (event == 'SPELL_AURA_APPLIED')  then--Gaining Eclipse
			BalancePowerTracker.vars.virtualEclipse = false
			BalancePowerTracker.vars.eclipse = spellId
			BalancePowerTracker:Warning(true,spellId)
			BalancePowerTracker:UpdateEclipse()
		elseif (event == 'SPELL_AURA_REMOVED') then --losing Eclipse
			BalancePowerTracker.vars.eclipse = false;
			BalancePowerTracker:UpdateEclipse()
		end
	end
end

--/slash command
function SlashCmdList.BALANCEPOWERTRACKER(msg, editbox) --Slash command function
	if not BalancePowerTracker.vars.isDruid then
		print("|c00a080ffBalancePowerTracker|r: To configure BalancePowerTracker, log with a druid.")
		return
	end
	BPTLoader.load("OPT")
	InterfaceOptionsFrame_OpenToCategory("BalancePowerTracker")
end

-- Options
local function MyTableDeepCopy(origin,destiny,default)
	if not origin then origin = {} end

	for k, v in pairs(default) do
		if type(v) == "table" then
			destiny[k]={};
			MyTableDeepCopy(origin[k],destiny[k],default[k])
		elseif origin[k] ~= nil then
			destiny[k] = origin[k]
		else
			destiny[k] = v;
		end
	end
end
local function printTable(k,t,l)k,l=k..":",l or 0;for i=1,l do k="_"..k;end	if type(t)~="table"then print(k,tostring(t))return end print(k)for k,v in pairs(t)do printTable(k,v,l+1)end end --prints table t with title k, don't use l
function BalancePowerTracker:ResetOptions() --Resets Options
	BalancePowerTracker.options = {};
	BalancePowerTracker.barColor = {};
	BalancePowerTracker.style.free = {};
	BalancePowerTracker.warnings.options = {};
	BalancePowerTracker.warnings.flasher = {};
	BalancePowerTracker.warnings.alert	= {};
	BalancePowerTracker.warnings.msbt	= {};

	MyTableDeepCopy(nil	,BalancePowerTracker.options			,BalancePowerTracker.defaults.options)
	MyTableDeepCopy(nil	,BalancePowerTracker.barColor			,BalancePowerTracker.defaults.barColor)
	MyTableDeepCopy(nil	,BalancePowerTracker.style.free			,BalancePowerTracker.defaults.free)
	MyTableDeepCopy(nil	,BalancePowerTracker.warnings.options	,BalancePowerTracker.defaults.warningsoptions)
	MyTableDeepCopy(nil	,BalancePowerTracker.warnings.flasher	,BalancePowerTracker.defaults.warningsflasher)
	MyTableDeepCopy(nil	,BalancePowerTracker.warnings.alert		,BalancePowerTracker.defaults.warningsalert)
	MyTableDeepCopy(nil	,BalancePowerTracker.warnings.msbt		,BalancePowerTracker.defaults.warningsmsbt)

	BalancePowerTracker.db = {};
end
function BalancePowerTracker:LoadVars() --Load vars
	MyTableDeepCopy(BalancePowerTracker_DB.default			,BalancePowerTracker.options			,BalancePowerTracker.defaults.options)
	MyTableDeepCopy(BalancePowerTracker_DB.colors 			,BalancePowerTracker.barColor			,BalancePowerTracker.defaults.barColor)
	MyTableDeepCopy(BalancePowerTracker_DB.free   			,BalancePowerTracker.style.free			,BalancePowerTracker.defaults.free)
	MyTableDeepCopy(nil										,BalancePowerTracker.db 				,BalancePowerTracker_DB.lbf)
	MyTableDeepCopy(BalancePowerTracker_DB.warningsoptions	,BalancePowerTracker.warnings.options	,BalancePowerTracker.defaults.warningsoptions)
	MyTableDeepCopy(BalancePowerTracker_DB.warningsflasher	,BalancePowerTracker.warnings.flasher	,BalancePowerTracker.defaults.warningsflasher)
	MyTableDeepCopy(BalancePowerTracker_DB.warningsalert	,BalancePowerTracker.warnings.alert		,BalancePowerTracker.defaults.warningsalert)
	MyTableDeepCopy(nil										,BalancePowerTracker.warnings.msbt		,BalancePowerTracker_DB.warningsmsbt)
end
function BalancePowerTracker:SaveVars() --Saves vars
	local modules = BalancePowerTracker_DB.modules
	BalancePowerTracker_DB={
		default={},
		colors={},
		free={},
		warningsoptions={},
		warningsflasher={},
		warningsalert={},
		warningsmsbt={},
		lbf = {},
	};
	BalancePowerTracker_DB.modules = modules;

	for k, v in pairs(BalancePowerTracker.options) do
		BalancePowerTracker_DB.default[k] = v;
	end
	for k, v in pairs(BalancePowerTracker.barColor) do
		BalancePowerTracker_DB.colors[k] = v;
	end
	for k, v in pairs(BalancePowerTracker.style.free) do
		BalancePowerTracker_DB.free[k] = v;
	end
	for k, v in pairs(BalancePowerTracker.warnings.options) do
		BalancePowerTracker_DB.warningsoptions[k] = v;
	end
	for k, v in pairs(BalancePowerTracker.warnings.alert) do
		BalancePowerTracker_DB.warningsalert[k] = v;
	end
	for k, v in pairs(BalancePowerTracker.warnings.flasher) do
		BalancePowerTracker_DB.warningsflasher[k] = v;
	end
	for k, v in pairs(BalancePowerTracker.warnings.msbt) do
		BalancePowerTracker_DB.warningsmsbt[k] = v;
	end
	for k, v in pairs(BalancePowerTracker.db) do
		BalancePowerTracker_DB.lbf[k] = v;
	end
end

do
	local ready = false;
	local funct = false;
	function BalancePowerTracker:ReadyToCreateOptions()
		ready=true
		if funct then funct(BalancePowerTracker); end
	end
	function BalancePowerTracker_SharedInfo:CreateOptions(func)
		funct=func
		if ready then funct(BalancePowerTracker); end
	end
end

-- Libsharedmedia
local media
function BalancePowerTracker:LibSharedMedia_Load()
	media = LibStub:GetLibrary("LibSharedMedia-3.0",true);
	if not media then return end
	media.RegisterCallback(self, "LibSharedMedia_Registered")
end
function BalancePowerTracker:LibSharedMedia_Registered()
	if not media then return end
	for k, v in pairs(media:List("statusbar")) do
		BalancePowerTracker.media.textures[media:Fetch("statusbar", v)] = v;
	end
	for k, v in pairs(media:List("border")) do
		BalancePowerTracker.media.borders[media:Fetch("border", v)] = v;
	end
	for k, v in pairs(media:List("font")) do
		BalancePowerTracker.media.fonts[media:Fetch("font", v)] = v;
	end
	for k, v in pairs(media:List("sound")) do
		BalancePowerTracker.media.sound[media:Fetch("sound", v)] = v;
	end
end

-- ButtonFacade
local LBF
function BalancePowerTracker:ButtonFacade_Init()
	LBF = LibStub("LibButtonFacade", true)

	if not LBF then
		BalancePowerTracker.options.lbf=false
		BalancePowerTracker.vars.lbfdisabled = true
		return
	else
		BalancePowerTracker.vars.lbfdisabled = false
		LBF:RegisterSkinCallback("BalancePowerTracker",	function(_,SkinID, Gloss, Backdrop, _,_, Colors)
														BalancePowerTracker.db["Skin"] = SkinID
														BalancePowerTracker.db["Gloss"] = Gloss
														BalancePowerTracker.db["Backdrop"] = Backdrop
														BalancePowerTracker.db["Colors"] = Colors
													end,nil)
	end
end
function BalancePowerTracker:ButtonFacade_Reskin()
	local Group = LBF:Group("BalancePowerTracker")

	Group:AddButton(BalancePowerTracker.frames.sEclipseIcon)
	Group:AddButton(BalancePowerTracker.frames.lEclipseIcon)

	if BalancePowerTracker.db.Skin then
		Group:Skin(BalancePowerTracker.db.Skin, BalancePowerTracker.db.Gloss,BalancePowerTracker.db.Backdrop, BalancePowerTracker.db.Colors)
	else
		Group:Skin("Blizzard")
	end

	if (not BalancePowerTracker.options.lbf) or BalancePowerTracker.options.originalEclipseIcons then
		Group:RemoveButton(BalancePowerTracker.frames.sEclipseIcon,false)
		Group:RemoveButton(BalancePowerTracker.frames.lEclipseIcon,false)
	end
end

--MSBT
function BalancePowerTracker:MSBT_Init()
	if MikSBT then
		BalancePowerTracker.vars.msbtdisabled = false
	else
		BalancePowerTracker.vars.msbtdisabled = true
		BalancePowerTracker.warnings.msbt.enabled = false
	end
end


--My DOT tracker
local function createDotTracker(userGUID)
	local dotTracker ={
		myGUID = userGUID,
		dotsIds = {},
		eventFrame = CreateFrame("Frame","BPTDoTTrackerFrame",UIParent),
	}
	dotTracker.eventFrame.parent = dotTracker
	
	function dotTracker:AddDoT(DoTid,baseTickTime,defaulttime,functionToCallWhenDataChanged)
		self.dotsIds[DoTid]={
			tickTimeNow = function() return baseTickTime*select(7,GetSpellInfo(5176))/(2500-select(5,GetTalentInfo(1,2))*500/3) end,
			defTime  = defaulttime,
			funcToCall = (type(functionToCallWhenDataChanged)=="function") and functionToCallWhenDataChanged,
		}
	end

	function dotTracker:RemoveDoT(DoTid)
		self.dotsIds[DoTid]=nil
	end

	function dotTracker:Start()
		self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self.eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		self.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	end

	function dotTracker:Stop(DoTid)
		self.eventFrame:UnregisterAllEvents()
	end

	function dotTracker.UnitFromGuid(Guid)
		if select(1,UnitGUID("target"))==Guid then return "target";
		elseif select(1,UnitGUID("mouseover"))==Guid then return "mouseover";
		elseif select(1,UnitGUID("focus"))==Guid then return "focus";
		elseif select(1,UnitGUID("targettarget"))==Guid then return "targettarget";
		end
		--boss
		for i=1,4 do if select(1,UnitGUID("boss"..i))==Guid then return "boss"..i; end end
		--arena
		if select(1,IsActiveBattlefieldArena()) then
			for i=1,5 do if select(1,UnitGUID("arena"..i))==Guid then return "arena"..i; end end
		end
	end
	
	function dotTracker:PLAYER_TARGET_CHANGED()
		local targetGUID = UnitGUID("target")
		if targetGUID then
			for spellId,v in pairs(self.dotsIds) do 
				local dotTable = v[targetGUID]
				
				if dotTable and dotTable.used and dotTable.timeEnd > GetTime() then
					--print(dotTable.hasBeenTargeted)
					if dotTable.hasBeenTargeted then 
						return
					else
						--print("actulizado "..spellId.." de "..targetGUID)
						dotTable.timeEnd = select(7,UnitDebuff("target", select(1,GetSpellInfo(spellId)) ,nil, "PLAYER"))
						dotTable.ticksTillEnd = floor(((dotTable.timeEnd - GetTime())/dotTable.tickTime)+.5)
					end
				else
					local timeEnd = select(7,UnitDebuff("target", select(1,GetSpellInfo(spellId)) ,nil, "PLAYER"))
					if not timeEnd then return end
					
					if not dotTable then self.dotsIds[spellId][targetGUID] = {} dotTable = self.dotsIds[spellId][targetGUID] end
					dotTable.used = true
					dotTable.hasBeenTargeted = true
					dotTable.timeEnd = timeEnd
					dotTable.applyTimestamp = -1
					dotTable.tickTime = -1
					dotTable.ticksTillEnd = -1
					--print("creado"..spellId.." de "..targetGUID)
				end
				
				if v.funcToCall then v.funcToCall(targetGUID) end
			end
		end
	end	
	
	function dotTracker:UNIT_SPELLCAST_SUCCEEDED(unit,_,_,_,id)
		if unit == "player" and self.dotsIds[id] then 
			self.NG = (UnitBuff("player", select(1,GetSpellInfo(16880))) and true) or false 
			self.dotsIds[id].tickTimeOnCast = self.dotsIds[id].tickTimeNow() 
		end
	end
	
	function dotTracker:COMBAT_LOG_EVENT_UNFILTERED(timestamp,event,_,gUIDor,_,_,_,destGUID,_,_,_,spellId)
		if (gUIDor == self.myGUID and self.dotsIds[spellId]) then
			local dotTable = self.dotsIds[spellId][destGUID]
			if not dotTable then self.dotsIds[spellId][destGUID] = {} dotTable = self.dotsIds[spellId][destGUID] end
			
			local onlyTick
			
			if event == "SPELL_PERIODIC_DAMAGE" then
				if dotTable.used then
					if dotTable.timeEnd < GetTime() then
						dotTable.used = false
					else
						dotTable.ticksTillEnd = floor(((dotTable.timeEnd - GetTime())/dotTable.tickTime)+.5)
						onlyTick = true
					end
					
					--print("Damage from "..spellId.." on "..destGUID..": "..dotTable.ticksTillEnd)
				else 
					return
				end
			elseif event == "SPELL_AURA_REFRESH" then
				dotTable.used     = true
				if (not self.NG) and UnitBuff("player", select(1,GetSpellInfo(16880))) and self.dotsIds[spellId].tickTimeNow() < self.dotsIds[spellId].tickTimeOnCast then --descontar gracia de la naturaleza si la causó
					dotTable.tickTime =  self.dotsIds[spellId].tickTimeNow() *(1+  0.05*select(5,GetTalentInfo(1,1)))  
				else
					dotTable.tickTime = self.dotsIds[spellId].tickTimeNow()  
				end
				--print(dotTable.tickTime)
				
				dotTable.applyTimestamp = timestamp
				
				local unit = self.UnitFromGuid(destGUID)
				if unit then
					dotTable.hasBeenTargeted = true
					dotTable.timeEnd = select(7,UnitDebuff(unit, select(1,GetSpellInfo(spellId)) ,nil, "PLAYER"))
				else
					dotTable.hasBeenTargeted = false
					dotTable.timeEnd  = GetTime() + floor(self.dotsIds[spellId].defTime()/dotTable.tickTime+.5)*dotTable.tickTime + ((((dotTable.timeEnd or GetTime())-GetTime())*1000)%(dotTable.tickTime*1000))/1000
				end
				
				dotTable.ticksTillEnd = floor(((dotTable.timeEnd - GetTime())/dotTable.tickTime)+.75)
				
				--print("Refresh from "..spellId.." on "..destGUID.." cada "..dotTable.tickTime.."s: "..dotTable.ticksTillEnd)
				
			elseif event == "SPELL_AURA_APPLIED" then	
				if not dotTable then self.dotsIds[spellId][destGUID] = {} dotTable = self.dotsIds[spellId][destGUID] end
				
				dotTable.used = true
				
				if (not self.NG) and UnitBuff("player", select(1,GetSpellInfo(16880))) and self.dotsIds[spellId].tickTimeNow() < self.dotsIds[spellId].tickTimeOnCast then --descontar gracia de la naturaleza si la causó
					dotTable.tickTime =  self.dotsIds[spellId].tickTimeNow() *(1+  0.05*select(5,GetTalentInfo(1,1)))  
				else
					dotTable.tickTime = self.dotsIds[spellId].tickTimeNow()  
				end
				--print(dotTable.tickTime)
				
				dotTable.applyTimestamp = timestamp
				
				local unit = self.UnitFromGuid(destGUID)
				if unit then
					dotTable.hasBeenTargeted = true
					dotTable.timeEnd = select(7,UnitDebuff(unit, select(1,GetSpellInfo(spellId)) ,nil, "PLAYER"))
				else
					dotTable.hasBeenTargeted = false
					dotTable.timeEnd  = GetTime() + floor(self.dotsIds[spellId].defTime()/dotTable.tickTime+.5)*dotTable.tickTime
				end
				
				dotTable.ticksTillEnd = floor(((dotTable.timeEnd - GetTime())/dotTable.tickTime)+.5)
				
				--print("Apply from "..spellId.." on "..destGUID.." cada "..dotTable.tickTime.."s: "..dotTable.ticksTillEnd)
				
			elseif event == "SPELL_AURA_REMOVED" then
				dotTable.used = false
			else 
				return
			end

			if self.dotsIds[spellId].funcToCall then self.dotsIds[spellId].funcToCall(destGUID,onlyTick) end
		elseif self.dotsIds[spellId] and (event == "UNIT_DIED" or event == "UNIT_DESTROYED") then
			self.dotsIds[spellId][destGUID] = nil
			if self.dotsIds[spellId].funcToCall then self.dotsIds[spellId].funcToCall(destGUID) end
		end
	end
	dotTracker.eventFrame:SetScript("OnEvent",function(self,event,...) self.parent[event](self.parent,...) end)

	dotTracker:Start()
	return dotTracker
end

local dotTracker
function BPTDotTracker()
	if dotTracker then return end
	local allDots = {
		[5570]  = "InsectSwarm",
		[93402] = "Sunfire",
		[8921]  = "Moonfire",
	}
	
	dotTracker = createDotTracker(UnitGUID("player"))
	
	
	--IS icon
	local isIcon = CreateFrame("Button","BPTDoTTrackerISIconFrame",UIParent)
	isIcon:SetWidth(30)
	isIcon:SetHeight(30)
	isIcon:ClearAllPoints();
	isIcon:SetPoint("RIGHT",BalancePowerTrackerBackgroundFrame,"CENTER",-2,-25)

	local isTex = isIcon:CreateTexture("BPTDoTTrackerISIconFrameIcon", "ARTWORK",nil,0)
	isTex:ClearAllPoints();
	isTex:SetPoint("CENTER")
	isTex:Show()
	isTex:SetWidth(30)
	isTex:SetHeight(30)
	isTex:SetTexture(select(3,GetSpellInfo(5570)))
	isTex:SetTexCoord(0,1,0,1)

	local isText=isIcon:CreateFontString("BPTDoTTrackerISIconFrameTickCount","OVERLAY","GameFontNormal")
	isText:ClearAllPoints();
	isText:SetPoint("CENTER",0,0)
	isText:SetFont("Fonts\\FRIZQT__.TTF", 11,"OUTLINE")
	isText:SetText("0")
	isText:SetTextColor(1, 1, 1, 1)

	allDots[5570] = {text = isText,frame=isIcon};
	
	--MF icon
	local mfIcon = CreateFrame("Button","BPTDoTTrackerMFIconFrame",UIParent)
	mfIcon:SetWidth(30)
	mfIcon:SetHeight(30)
	mfIcon:ClearAllPoints();
	mfIcon:SetPoint("LEFT",BalancePowerTrackerBackgroundFrame,"CENTER",2,-25)

	local mfTex = mfIcon:CreateTexture("BPTDoTTrackerMFIconFrameIcon", "ARTWORK",nil,0)
	mfTex:ClearAllPoints();
	mfTex:SetPoint("CENTER")
	mfTex:Show()
	mfTex:SetWidth(30)
	mfTex:SetHeight(30)
	mfTex:SetTexture(select(3,GetSpellInfo(31579)))
	mfTex:SetTexCoord(0,1,0,1)

	local mfText=mfIcon:CreateFontString("BPTDoTTrackerMFIconFrameTickCount","OVERLAY","GameFontNormal")
	mfText:ClearAllPoints();
	mfText:SetPoint("CENTER",0,0)
	mfText:SetFont("Fonts\\FRIZQT__.TTF", 11,"OUTLINE")
	mfText:SetText("0")
	mfText:SetTextColor(1, 1, 1, 1)

	allDots[8921] = {text = mfText,frame=mfIcon};
	
	--SF icon
	local sfIcon = CreateFrame("Button","BPTDoTTrackerSFIconFrame",UIParent)
	sfIcon:SetWidth(30)
	sfIcon:SetHeight(30)
	sfIcon:ClearAllPoints();
	sfIcon:SetPoint("LEFT",BalancePowerTrackerBackgroundFrame,"CENTER",2,-25)

	local sfTex = sfIcon:CreateTexture("BPTDoTTrackerSFIconFrameIcon", "ARTWORK",nil,0)
	sfTex:ClearAllPoints();
	sfTex:SetPoint("CENTER")
	sfTex:Show()
	sfTex:SetWidth(30)
	sfTex:SetHeight(30)
	sfTex:SetTexture(select(3,GetSpellInfo(93402)))
	sfTex:SetTexCoord(0,1,0,1)

	local sfText=sfIcon:CreateFontString("BPTDoTTrackerSFIconFrameTickCount","OVERLAY","GameFontNormal")
	sfText:ClearAllPoints();
	sfText:SetPoint("CENTER",0,0)
	sfText:SetFont("Fonts\\FRIZQT__.TTF", 11,"OUTLINE")
	sfText:SetText("0")
	sfText:SetTextColor(1, 1, 1, 1)

	allDots[93402] = {text = sfText,frame=sfIcon};
	
	if not BalancePowerTracker.vars.lbfdisabled then
		local Group = LBF:Group("BalancePowerTracker")

		for _,v in pairs(allDots) do
			Group:AddButton(v.frame)
		end

		if BalancePowerTracker.db.Skin then
			Group:Skin(BalancePowerTracker.db.Skin, BalancePowerTracker.db.Gloss,BalancePowerTracker.db.Backdrop, BalancePowerTracker.db.Colors)
		else
			Group:Skin("Blizzard")
		end
	end
	
	for id,v in pairs(allDots) do
		dotTracker:AddDoT(
			id,
			2,
			function() 
				return 12+2*select(5,GetTalentInfo(1,4)) 
			end,
			function(i,t) 
				if UnitGUID("target")==i then
					if dotTracker.dotsIds[id][i].used and dotTracker.dotsIds[id][i].timeEnd>GetTime() then 
						if dotTracker.dotsIds[id][i].ticksTillEnd >0 then
							if not v.text:IsShown() then v.text:Show() end
							v.text:SetText(dotTracker.dotsIds[id][i].ticksTillEnd)
						else
							if v.text:IsShown() then v.text:Hide() end
						end
						
						if not (t or v.frame:IsShown()) then v.frame:Show() end
					elseif v.frame:IsShown() then
						v.frame:Hide()
					end
				end 
			end
		)
	end
	
	local function checkTarget()
		local targetGUID = UnitGUID("target")
		if targetGUID then
			for id,v in pairs(allDots) do
				local dotTable = dotTracker.dotsIds[id][targetGUID]
				
				if dotTable and dotTable.used and dotTable.timeEnd > GetTime() then
					if not v.frame:IsShown() then v.frame:Show() end
					
					if dotTable.ticksTillEnd >0 then
						if not v.text:IsShown() then v.text:Show() end
						v.text:SetText(dotTable.ticksTillEnd)
					else
						if v.text:IsShown() then v.text:Hide() end
					end
				else
					if v.frame:IsShown() then v.frame:Hide() end
				end
			end
		else
			for id,v in pairs(allDots) do 
				if v.frame:IsShown() then v.frame:Hide() end
			end
		end
	end
	
	local eventFrame = CreateFrame("Frame","BPTDoTTrackerEventFrame",UIParent)
	eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	eventFrame:SetScript("OnEvent",checkTarget )

	checkTarget()
end























