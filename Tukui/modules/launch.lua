------------------------------------------------------------------------
--	First Time Launch and On Login file
------------------------------------------------------------------------

local function install()
	SetCVar("buffDurations", 1)
	SetCVar("consolidateBuffs", 0)
	SetCVar("lootUnderMouse", 1)
	SetCVar("autoSelfCast", 1)
	SetCVar("mapQuestDifficulty", 1)
	SetCVar("scriptErrors", 1)
	SetCVar("nameplateShowFriends", 0)
	SetCVar("nameplateShowFriendlyPets", 0)
	SetCVar("nameplateShowFriendlyGuardians", 0)
	SetCVar("nameplateShowFriendlyTotems", 0)
	SetCVar("nameplateShowEnemies", 1)
	SetCVar("nameplateShowEnemyPets", 1)
	SetCVar("nameplateShowEnemyGuardians", 1)
	SetCVar("nameplateShowEnemyTotems", 1)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("screenshotQuality", 10)
  SetCVar("screenshotFormat", "png")
	SetCVar("cameraDistanceMax", 50)
	SetCVar("cameraDistanceMaxFactor", 3.4)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "im")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("ConversationMode", "inline")
	SetCVar("CombatDamage", 1)
	SetCVar("CombatHealing", 1)
	SetCVar("showTutorials", 0)
	SetCVar("showNewbieTips", 0)
	SetCVar("Maxfps", 120)
	SetCVar("autoDismountFlying", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("autoQuestProgress", 1)
	SetCVar("showLootSpam", 1)
	SetCVar("guildMemberNotify", 1)
	SetCVar("chatBubblesParty", 0)
	SetCVar("chatBubbles", 0)	
	SetCVar("UnitNameOwn", 0)
	SetCVar("UnitNameNPC", 0)
	SetCVar("UnitNameNonCombatCreatureName", 0)
	SetCVar("UnitNamePlayerGuild", 1)
	SetCVar("UnitNamePlayerPVPTitle", 1)
	SetCVar("UnitNameFriendlyPlayerName", 0)
	SetCVar("UnitNameFriendlyPetName", 0)
	SetCVar("UnitNameFriendlyGuardianName", 0)
	SetCVar("UnitNameFriendlyTotemName", 0)
	SetCVar("UnitNameEnemyPlayerName", 1)
	SetCVar("UnitNameEnemyPetName", 1)
	SetCVar("UnitNameEnemyGuardianName", 1)
	SetCVar("UnitNameEnemyTotemName", 1)
	SetCVar("UberTooltips", 1)
	SetCVar("removeChatDelay", 1)
	SetCVar("showVKeyCastbar", 1)
	SetCVar("colorblindMode", 0)
	SetCVar("bloatthreat", 0)
	SetCVar("bloattest", 0)
	SetCVar("showArenaEnemyFrames", 0)
	
	-- Var ok, now setting chat frames if using Tukui chats.	
	if (TukuiCF.chat.enable == true) and (not IsAddOnLoaded("Prat") or not IsAddOnLoaded("Chatter")) then					
		FCF_ResetChatWindows()
		FCF_SetLocked(ChatFrame1, 1)
		FCF_DockFrame(ChatFrame2)
		FCF_SetLocked(ChatFrame2, 1)
		FCF_OpenNewWindow(tukuilocal.chat_general)
		FCF_SetLocked(ChatFrame3, 1)
		FCF_DockFrame(ChatFrame3)

		FCF_OpenNewWindow(LOOT)
		FCF_UnDockFrame(ChatFrame4)
		FCF_SetLocked(ChatFrame4, 1)
		ChatFrame4:Show()

		for i = 1, NUM_CHAT_WINDOWS do
			local frame = _G[format("ChatFrame%s", i)]
			local chatFrameId = frame:GetID()
			local chatName = FCF_GetChatWindowInfo(chatFrameId)
			
			frame:SetSize(TukuiDB.Scale(TukuiCF["panels"].tinfowidth + 1), TukuiDB.Scale(111))
			
			-- this is the default width and height of tukui chats.
			SetChatWindowSavedDimensions(chatFrameId, TukuiDB.Scale(TukuiCF["panels"].tinfowidth + 1), TukuiDB.Scale(111))
			
			-- move general bottom left or Loot (if found) on right.
			if i == 1 then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", TukuiInfoLeft, "TOPLEFT", 0, TukuiDB.Scale(6))
			elseif i == 4 and chatName == LOOT then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", 0, TukuiDB.Scale(6))
			end
					
			-- save new default position and dimension
			FCF_SavePositionAndDimensions(frame)
			
			-- set default tukui font size
			FCF_SetChatWindowFontSize(nil, frame, 12)
			
			-- rename windows general and combat log
			if i == 1 then FCF_SetWindowName(frame, "G, S & W") end
			if i == 2 then FCF_SetWindowName(frame, "Log") end
		end
		
		ChatFrame_RemoveAllMessageGroups(ChatFrame1)
		ChatFrame_RemoveChannel(ChatFrame1, tukuilocal.chat_trade) -- erf, it seem we need to localize this now
		ChatFrame_RemoveChannel(ChatFrame1, tukuilocal.chat_general) -- erf, it seem we need to localize this now
		ChatFrame_RemoveChannel(ChatFrame1, tukuilocal.chat_defense) -- erf, it seem we need to localize this now
		ChatFrame_RemoveChannel(ChatFrame1, tukuilocal.chat_recrutment) -- erf, it seem we need to localize this now
		ChatFrame_RemoveChannel(ChatFrame1, tukuilocal.chat_lfg) -- erf, it seem we need to localize this now
		ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
		ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
		ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
		ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
		ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
		ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
		ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
		ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND")
		ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
		ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
		ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
		ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
		ChatFrame_AddMessageGroup(ChatFrame1, "DND")
		ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
		ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_CONVERSATION")
					
		-- Setup the spam chat frame
		ChatFrame_RemoveAllMessageGroups(ChatFrame3)
		ChatFrame_AddChannel(ChatFrame3, tukuilocal.chat_trade) -- erf, it seem we need to localize this now
		ChatFrame_AddChannel(ChatFrame3, tukuilocal.chat_general) -- erf, it seem we need to localize this now
		ChatFrame_AddChannel(ChatFrame3, tukuilocal.chat_defense) -- erf, it seem we need to localize this now
		ChatFrame_AddChannel(ChatFrame3, tukuilocal.chat_recrutment) -- erf, it seem we need to localize this now
		ChatFrame_AddChannel(ChatFrame3, tukuilocal.chat_lfg) -- erf, it seem we need to localize this now
				
		-- Setup the right chat
		ChatFrame_RemoveAllMessageGroups(ChatFrame4)
		ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_XP_GAIN")
		ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_HONOR_GAIN")
		ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_FACTION_CHANGE")
		ChatFrame_AddMessageGroup(ChatFrame4, "LOOT")
		ChatFrame_AddMessageGroup(ChatFrame4, "MONEY")
				
		-- enable classcolor automatically on login and on each character without doing /configure each time.
		ToggleChatColorNamesByClassGroup(true, "SAY")
		ToggleChatColorNamesByClassGroup(true, "EMOTE")
		ToggleChatColorNamesByClassGroup(true, "YELL")
		ToggleChatColorNamesByClassGroup(true, "GUILD")
		ToggleChatColorNamesByClassGroup(true, "OFFICER")
		ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
		ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
		ToggleChatColorNamesByClassGroup(true, "WHISPER")
		ToggleChatColorNamesByClassGroup(true, "PARTY")
		ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
		ToggleChatColorNamesByClassGroup(true, "RAID")
		ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
		ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
		ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
		ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")	
		ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	end

  -- Set up Skada frames (ChopsUI edit)
  if (IsAddOnLoaded("Skada")) then

    -- Switch the Skada profile to a character specific profile
    local skadaProfile = UnitName("player") .. " - " .. GetRealmName()
    Skada.db:SetProfile(skadaProfile)

    -- Reset Skada windows
    Skada.db.profile.windows = {}

    -- Figure out the size of the right chat frame and base our Skada windows on that
    local panelWidth = ChopsuiChatBackgroundRight:GetWidth() - TukuiDB.Scale(17)
    local panelHeight = ChopsuiChatBackgroundRight:GetHeight() - TukuiDB.Scale(17)

    -- Calculate the size of the Skada windows
    local windowWidth = panelWidth / 2
    local windowHeight = panelHeight
    local barHeight = windowHeight / 8
    local maxBars = math.floor(windowHeight / barHeight)
    
    -- Set some general Skada options
    Skada.db.profile.icon.hide = true
    Skada.db.profile.hidesolo = true

    -- Create a new window and position that to the bottom right of the screen
    Skada:CreateWindow("DPS")
    local skadaDpsWindow = Skada.db.profile.windows[1]
    skadaDpsWindow.barwidth = windowWidth
    skadaDpsWindow.barheight = barHeight
    skadaDpsWindow.barmax = maxBars
    skadaDpsWindow.barslocked = false
    skadaDpsWindow.enabletitle = false
    skadaDpsWindow.spark = false

    -- Create a new window and position that to the left of the first window
    Skada:CreateWindow("Threat")
    local skadaThreatWindow = Skada.db.profile.windows[2]
    skadaThreatWindow.barwidth = windowWidth
    skadaThreatWindow.barheight = barHeight
    skadaThreatWindow.barmax = maxBars
    skadaThreatWindow.barslocked = false
    skadaThreatWindow.enabletitle = false
    skadaThreatWindow.spark = false

  end

  -- Set up Deadly Bos Mods (ChopsUI edit)
  if (IsAddOnLoaded("DBM-Core") and IsAddOnLoaded("Tukui_DBM")) then

    UploadDBM() -- This is a local function (made public as a hack) inside Tukui_DBM that we just run to set things up properly.

    -- Set some general DBM options
    DBM.Options.ShowMinimapButton = false

    -- Position the boss health bar frame
    DBM.Options.HPFramePoint = "TOPLEFT"
    DBM.Options.HPFrameX = TukuiDB.Scale(88)
    DBM.Options.HPFrameY = TukuiDB.Scale(10)

    -- Position the DBM timer frame
    DBM.Bars:SetOption("TimerPoint", "LEFT")
    DBM.Bars:SetOption("TimerX", TukuiDB.Scale(141))
    DBM.Bars:SetOption("TimerY", 0)

    -- Position the DBM huge timer frame
    local hugeTimerOffset = oUF_Tukz_focustarget:GetTop() + TukuiDB.Scale(5)
    DBM.Bars:SetOption("HugeTimerPoint", "BOTTOM")
    DBM.Bars:SetOption("HugeTimerX", 0)
    DBM.Bars:SetOption("HugeTimerY", hugeTimerOffset)

  end

  -- Set up Auditor2 Broker
  if (IsAddOnLoaded("Broker_Auditor")) then

    -- Set cash format to "Graphical" to avoid eating up too much space in the info panel
    AuditorBroker.db.profile.cashFormat.Bar = "Graphical"

  end

  -- Set up Grid
  if (IsAddOnLoaded("Grid")) then

    local GridLayout = Grid:GetModule("GridLayout")
    local GridStatus = Grid:GetModule("GridStatus")
    local GridFrame = Grid:GetModule("GridFrame")
    local GridIndicatorCornerIcons = GridFrame:GetModule("GridIndicatorCornerIcons")
    local GridStatusAuras = GridStatus:GetModule("GridStatusAuras")
    local GridStatusAurasExt = GridStatus:GetModule("GridStatusAurasExt")

    local buffAuras = {
      ["stats"] = {
        ["1126"] = true,    -- Mark of the Wild
        ["90363"] = true,   -- Embrace of the Shale Spider
        ["20217"] = true,   -- Blessing of Kings
      },
      ["stamina"] = {
        ["21562"] = true,   -- Power Word: Fortitude
        ["469"] = true,     -- Commanding Shout
        ["6307"] = true,    -- Blood Pact
      },
      ["mana"] = {
        ["1459"] = true,    -- Arcane Brilliance
        ["61316"] = true,   -- Dalaran Brilliance
        ["54424"] = true,   -- Fel Intelligence
      },
      ["str_agi"] = {
        ["67330"] = true,   -- Horn of Winter
        ["93435"] = true,   -- Roar of Courage
        ["8075"] = true,    -- Strength of Earth Totem
        ["6673"] = true,    -- Battle Shout
      }
    }

    -- Switch the Grid profile to a character specific profile
    local gridProfile = UnitName("player") .. " - " .. GetRealmName()
    Grid.db:SetProfile(gridProfile)

    -- Set some general Grid options
    Grid.db.profile["minimap"] = {
      ["hide"] = true
    }
    GridLayout.db.profile["layouts"] = {
      ["solo"] = "None"
    }
    GridLayout.db.profile["layout"] = "None"

    -- Anchor the groups to the bottom left
    GridLayout.db.profile["groupAnchor"] = "BOTTOMLEFT"

    -- Horizontal groups
    GridLayout.db.profile["horizontal"] = true

    -- Lock the frame
    GridLayout.db.profile["hideTab"] = true
    GridLayout.db.profile["FrameLock"] = true

    -- Style the layout
    GridLayout.db.profile["Padding"] = 0
    GridLayout.db.profile["Spacing"] = 0
    GridLayout.db.profile["borderTexture"] = "None"
    GridLayout.db.profile["BackgroundA"] = 0
    GridLayout.db.profile["BackgroundR"] = 0
    GridLayout.db.profile["BackgroundG"] = 0
    GridLayout.db.profile["BackgroundB"] = 0

    -- Style the frame
    GridFrame.db.profile["font"] = "TelUI Font"
    GridFrame.db.profile["fontSize"] = 12
    GridFrame.db.profile["textlength"] = 12
    GridFrame.db.profile["texture"] = "TelUI Statusbar"
    GridFrame.db.profile["enableText2"] = true
    GridFrame.db.profile["orientation"] = "HORIZONTAL"
    GridFrame.db.profile["enableMouseoverHighlight"] = false
    GridFrame.db.profile["iconSize"] = 22

    -- Set up some frame defaults
    GridFrame.db.profile["statusmap"] = {
      ["border"] = {},
      ["corner1"] = {},
      ["corner2"] = {},
      ["corner3"] = {},
      ["corner4"] = {},
      ["icon"] = {},
      ["iconBRcornerright"] = {},
      ["text"] = {},
      ["text2"] = {}
    }
    GridFrame.db.profile["statusmap"]["border"]["alert_lowMana"] = false
    GridFrame.db.profile["statusmap"]["border"]["alert_lowHealth"] = false
    GridFrame.db.profile["statusmap"]["border"]["alert_aggro"] = true
    GridFrame.db.profile["statusmap"]["border"]["debuff_curse"] = true
    GridFrame.db.profile["statusmap"]["border"]["debuff_magic"] = true
    GridFrame.db.profile["statusmap"]["border"]["debuff_disease"] = true
    GridFrame.db.profile["statusmap"]["border"]["debuff_poison"] = true
    GridFrame.db.profile["statusmap"]["corner1"]["alert_heals"] = false
    GridFrame.db.profile["statusmap"]["corner3"]["debuff_curse"] = false
    GridFrame.db.profile["statusmap"]["corner3"]["debuff_poison"] = false
    GridFrame.db.profile["statusmap"]["corner3"]["debuff_disease"] = false
    GridFrame.db.profile["statusmap"]["corner3"]["debuff_magic"] = false
    GridFrame.db.profile["statusmap"]["corner4"]["alert_aggro"] = false
    GridFrame.db.profile["statusmap"]["icon"]["alert_RaidDebuff"] = false
    GridFrame.db.profile["statusmap"]["iconBRcornerright"]["alert_RaidDebuff"] = true
    GridFrame.db.profile["statusmap"]["text"]["alert_offline"] = false
    GridFrame.db.profile["statusmap"]["text"]["unit_healthDeficit"] = false
    GridFrame.db.profile["statusmap"]["text"]["debuff_Ghost"] = false
    GridFrame.db.profile["statusmap"]["text"]["alert_heals"] = false
    GridFrame.db.profile["statusmap"]["text"]["alert_death"] = false
    GridFrame.db.profile["statusmap"]["text"]["alert_feignDeath"] = false

    -- Set up corner icons
    GridIndicatorCornerIcons.db.profile["iconSizeTopLeftCorner"] = 16
    GridIndicatorCornerIcons.db.profile["iconSizeTopRightCorner"] = 16
    GridIndicatorCornerIcons.db.profile["iconSizeBottomLeftCorner"] = 16
    GridIndicatorCornerIcons.db.profile["iconSizeBottomRightCorner"] = 16
    GridIndicatorCornerIcons.db.profile["xoffset"] = 2
    GridIndicatorCornerIcons.db.profile["yoffset"] = -1

    -- Remove any old aura groups
    for name, _ in pairs(GridStatusAurasExt.db.profile.auraGroups) do
      GridStatusAurasExt:RemoveAuraGroup(name)
    end
    GridStatusAurasExt.db.profile.auraGroups = {}

    -- Re-initialize the aura extension to avoid a LUA error
    GridStatusAurasExt:OnInitialize()

    -- Set up new aura groups for the current class
    if TukuiDB.myclass == "DRUID" or TukuiDB.myclass == "PALADIN" then
      GridStatusAurasExt:NewAuraGroup("Missing Buff Group: Stats", "missing buffs")
      GridStatusAurasExt.db.profile["status_Missing Buff Group: Stats"].ids = buffAuras["stats"]
      GridFrame.db.profile["statusmap"]["iconBRcornerright"]["status_Missing Buff Group: Stats"] = true
    end
    if TukuiDB.myclass == "PRIEST" or TukuiDB.myclass == "WARLOCK" or TukuiDB.myclass == "WARRIOR" then
      GridStatusAurasExt:NewAuraGroup("Missing Buff Group: Stamina", "missing buffs")
      GridStatusAurasExt.db.profile["status_Missing Buff Group: Stamina"].ids = buffAuras["stamina"]
      GridFrame.db.profile["statusmap"]["iconBRcornerright"]["status_Missing Buff Group: Stamina"] = true
    end
    if TukuiDB.myclass == "MAGE" or TukuiDB.myclass == "WARLOCK" then
      GridStatusAurasExt:NewAuraGroup("Missing Buff Group: Mana", "missing buffs")
      GridStatusAurasExt.db.profile["status_Missing Buff Group: Mana"].ids = buffAuras["mana"]
      GridFrame.db.profile["statusmap"]["iconBRcornerright"]["status_Missing Buff Group: Mana"] = true
    end
    if TukuiDB.myclass == "DEATHKNIGHT" or TukuiDB.myclass == "SHAMAN" or TukuiDB.myclass == "WARRIOR" then
      GridStatusAurasExt:NewAuraGroup("Missing Buff Group: Agility/Strength", "missing buffs")
      GridStatusAurasExt.db.profile["status_Missing Buff Group: Agility/Strength"].ids = buffAuras["str_agi"]
      GridFrame.db.profile["statusmap"]["iconBRcornerright"]["status_Missing Buff Group: Agility/Strength"] = true
    end

    --------------------------------------------------------------------------
    -- PRIEST HEALING GRID SETUP
    --------------------------------------------------------------------------
    if TukuiDB.myclass == "PRIEST" then
      GridFrame.db.profile["statusmap"]["text2"]["unitShieldLeft"] = true
      GridFrame.db.profile["statusmap"]["corner1"]["debuff_WeakenedSoul"] = true
      GridFrame.db.profile["statusmap"]["corner2"]["alert_pom"] = true
      GridFrame.db.profile["statusmap"]["corner3"]["alert_gracestack"] = true
      GridFrame.db.profile["statusmap"]["corner4"]["alert_renew"] = true
      GridFrame.db.profile["statusmap"]["icon"]["debuff_curse"] = false
      GridFrame.db.profile["statusmap"]["icon"]["debuff_poison"] = false
      GridStatusAuras.db.profile["debuff_WeakenedSoul"] = {
        ["color"] = {
          ["b"] = 0,
          ["g"] = 0.4470588235294117,
          ["r"] = 0.8470588235294118
        }
      }
    end

  end
		   
	TukuiInstallv1200 = true
	
	-- reset unitframe position
	if TukuiCF["unitframes"].positionbychar == true then
		TukuiUFpos = {}
	else
		TukuiData.ufpos = {}
	end
			
	ReloadUI()
end

local function DisableTukui()
	DisableAddOn("Tukui")
	ReloadUI()
end

------------------------------------------------------------------------
--	Popups
------------------------------------------------------------------------

StaticPopupDialogs["DISABLE_UI"] = {
	text = tukuilocal.popup_disableui,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = DisableTukui,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["INSTALL_UI"] = {
	text = tukuilocal.popup_install,
	button1 = ACCEPT,
	button2 = CANCEL,
    OnAccept = install,
	OnCancel = function() TukuiInstallv1100 = true TukuiData.SetcVar = true end,
    timeout = 0,
    whileDead = 1,
}

StaticPopupDialogs["DISABLE_RAID"] = {
	text = tukuilocal.popup_2raidactive,
	button1 = "DPS - TANK",
	button2 = "HEAL",
	OnAccept = function() DisableAddOn("Tukui_Heal_Layout") EnableAddOn("Tukui_Dps_Layout") ReloadUI() end,
	OnCancel = function() EnableAddOn("Tukui_Heal_Layout") DisableAddOn("Tukui_Dps_Layout") ReloadUI() end,
	timeout = 0,
	whileDead = 1,
}

------------------------------------------------------------------------
--	On login function, look for some infos!
------------------------------------------------------------------------

local TukuiOnLogon = CreateFrame("Frame")
TukuiOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
TukuiOnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	if TukuiDB.getscreenresolution == "800x600"
		or TukuiDB.getscreenresolution == "1024x768"
		or TukuiDB.getscreenresolution == "720x576"
		or TukuiDB.getscreenresolution == "1024x600" -- eeepc reso
		or TukuiDB.getscreenresolution == "1152x864" then
			SetCVar("useUiScale", 0)
			StaticPopup_Show("DISABLE_UI")
	else
		SetCVar("useUiScale", 1)
		if TukuiCF["general"].multisampleprotect == true then
			SetMultisampleFormat(1)
		end
		if TukuiCF["general"].uiscale > 1 then TukuiCF["general"].uiscale = 1 end
		if TukuiCF["general"].uiscale < 0.64 then TukuiCF["general"].uiscale = 0.64 end
		SetCVar("uiScale", TukuiCF["general"].uiscale)
		if TukuiInstallv1200 ~= true then
			if (TukuiData == nil) then TukuiData = {} end
			StaticPopup_Show("INSTALL_UI")
		end
	end
	
	if (IsAddOnLoaded("Tukui_Dps_Layout") and IsAddOnLoaded("Tukui_Heal_Layout")) then
		StaticPopup_Show("DISABLE_RAID")
	end
	
	print(tukuilocal.core_welcome1..TukuiDB.version)
	print(tukuilocal.core_welcome2)
end)

------------------------------------------------------------------------
--	UI HELP
------------------------------------------------------------------------

-- Print Help Messages
local function UIHelp()
	print(" ")
	print(tukuilocal.core_uihelp1)
	print(tukuilocal.core_uihelp2)
	print(tukuilocal.core_uihelp3)
	print(tukuilocal.core_uihelp4)
	print(tukuilocal.core_uihelp5)
	print(tukuilocal.core_uihelp6)
	print(tukuilocal.core_uihelp7)
	print(tukuilocal.core_uihelp8)
	print(tukuilocal.core_uihelp9)
	print(tukuilocal.core_uihelp10)
	print(tukuilocal.core_uihelp11)
	--print(tukuilocal.core_uihelp12)  -- temp disabled, don't know yet if i'll readd this feature
	print(tukuilocal.core_uihelp13)
	print(tukuilocal.core_uihelp15)
	print(" ")
	print(tukuilocal.core_uihelp14)
end

SLASH_UIHELP1 = "/UIHelp"
SlashCmdList["UIHELP"] = UIHelp

SLASH_CONFIGURE1 = "/resetui"
SlashCmdList.CONFIGURE = function() StaticPopup_Show("INSTALL_UI") end


