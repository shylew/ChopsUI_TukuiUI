if not (IsAddOnLoaded("ElvUI") or IsAddOnLoaded("Tukui")) then return end
UISkinOptions = {}
local s = UIPackageSkinFuncs.s
local c = UIPackageSkinFuncs.c

local DefaultSetSkin = CreateFrame("Frame")
	DefaultSetSkin:RegisterEvent( "PLAYER_ENTERING_WORLD" )
	DefaultSetSkin:SetScript( "OnEvent", function(self)
	if(UISkinOptions.RecountBackdrop == nil) then UISkinOptions.RecountBackdrop = "Enabled" end
	if(UISkinOptions.SkadaBackdrop == nil) then UISkinOptions.SkadaBackdrop = "Enabled" end
	if(UISkinOptions.ACPSkin == nil) then UISkinOptions.ACPSkin = "Enabled" end
	if(UISkinOptions.AdiBagsSkin == nil) then UISkinOptions.AdiBagsSkin = "Enabled" end
	if(UISkinOptions.AltoholicSkin == nil) then UISkinOptions.AltoholicSkin = "Enabled" end
	if(UISkinOptions.ArchySkin == nil) then UISkinOptions.ArchySkin = "Enabled" end
	if(UISkinOptions.ArkInventorySkin == nil) then UISkinOptions.ArkInventorySkin = "Enabled" end
	if(UISkinOptions.AtlasLootSkin == nil) then UISkinOptions.AtlasLootSkin = "Enabled" end
	if(UISkinOptions.ATSWSkin == nil) then UISkinOptions.ATSWSkin = "Enabled" end
	if(UISkinOptions.AuctionatorSkin == nil) then UISkinOptions.AuctionatorSkin = "Enabled" end
	if(UISkinOptions.AuctioneerSkin == nil) then UISkinOptions.AuctioneerSkin = "Enabled" end
	if(UISkinOptions.BPTSkin == nil) then UISkinOptions.BPTSkin = "Enabled" end
	if(UISkinOptions.BigWigsSkin == nil) then UISkinOptions.BigWigsSkin = "Enabled" end
	if(UISkinOptions.BGDefenderSkin == nil) then UISkinOptions.BGDefenderSkin = "Enabled" end
	if(UISkinOptions.BuyEmAllSkin == nil) then UISkinOptions.BuyEmAllSkin = "Enabled" end
	if(UISkinOptions.ChocolateBarSkin == nil) then UISkinOptions.ChocolateBarSkin = "Enabled" end
	if(UISkinOptions.CliqueSkin == nil) then UISkinOptions.CliqueSkin = "Enabled" end
	if(UISkinOptions.CLCInfoSkin == nil) then UISkinOptions.CLCInfoSkin = "Enabled" end
	if(UISkinOptions.CLCProtSkin == nil) then UISkinOptions.CLCProtSkin = "Enabled" end
	if(UISkinOptions.CLCRetSkin == nil) then UISkinOptions.CLCRetSkin = "Enabled" end
	if(UISkinOptions.DBMSkin == nil) then UISkinOptions.DBMSkin = "Enabled" end
	if(UISkinOptions.DXESkin == nil) then UISkinOptions.DXESkin = "Disabled" end
	if(UISkinOptions.EasyMailSkin == nil) then UISkinOptions.EasyMailSkin = "Enabled" end
	if(UISkinOptions.EnergyWatchSkin == nil) then UISkinOptions.EnergyWatchSkin = "Enabled" end
	if(UISkinOptions.ExtVendorSkin == nil) then UISkinOptions.ExtVendorSkin = "Enabled" end
	if(UISkinOptions.FactionizerSkin == nil) then UISkinOptions.FactionizerSkin = "Enabled" end
	if(UISkinOptions.KarniCrapSkin == nil) then UISkinOptions.KarniCrapSkin = "Enabled" end
	if(UISkinOptions.LightheadedSkin == nil) then UISkinOptions.LightheadedSkin = "Enabled" end
	if(UISkinOptions.LootCouncilLiteSkin == nil) then UISkinOptions.LootCouncilLiteSkin = "Enabled" end
	if(UISkinOptions.MageNuggetsSkin == nil) then UISkinOptions.MageNuggetsSkin = "Enabled" end
	if(UISkinOptions.MasterLootManagerRemixSkin == nil) then UISkinOptions.MasterLootManagerRemixSkin = "Enabled" end
	if(UISkinOptions.MinimalArchaeologySkin == nil) then UISkinOptions.MinimalArchaeologySkin = "Enabled" end
	if(UISkinOptions.MoveAnythingSkin == nil) then UISkinOptions.MoveAnythingSkin = "Enabled" end
	if(UISkinOptions.MRTSkin == nil) then UISkinOptions.MRTSkin = "Enabled" end
	if(UISkinOptions.MyRolePlaySkin == nil) then UISkinOptions.MyRolePlaySkin = "Enabled" end
	if(UISkinOptions.OdysseySkin == nil) then UISkinOptions.OdysseySkin = "Enabled" end
	if(UISkinOptions.OgriLazySkin == nil) then UISkinOptions.OgriLazySkin = "Enabled" end
	if(UISkinOptions.OmenSkin == nil) then UISkinOptions.OmenSkin = "Enabled" end	
	if(UISkinOptions.OutfitterSkin == nil) then UISkinOptions.OutfitterSkin = "Enabled" end
	if(UISkinOptions.PlayerScoreSkin == nil) then UISkinOptions.PlayerScoreSkin = "Enabled" end
	if(UISkinOptions.PoisonerSkin == nil) then UISkinOptions.PoisonerSkin = "Enabled" end
	if(UISkinOptions.PoMTackerSkin == nil) then UISkinOptions.PoMTrackerSkin = "Enabled" end
	if(UISkinOptions.PostalSkin == nil) then UISkinOptions.PostalSkin = "Enabled" end
	if(UISkinOptions.PowerAurasSkin == nil) then UISkinOptions.PowerAurasSkin = "Enabled" end
	if(UISkinOptions.PowerAurasIconsSkin == nil) then UISkinOptions.PowerAurasIconsSkin = "Enabled" end
	if(UISkinOptions.ProfessionTabsSkin == nil) then UISkinOptions.ProfessionTabsSkin = "Enabled" end
	if(UISkinOptions.QuartzSkin == nil) then UISkinOptions.QuartzSkin = "Enabled" end
	if(UISkinOptions.RaidInviteOrganizerSkin == nil) then UISkinOptions.RaidInviteOrganizerSkin = "Enabled" end
	if(UISkinOptions.RaidBuffStatusSkin == nil) then UISkinOptions.RaidBuffStatusSkin = "Enabled" end
	if(UISkinOptions.RecountSkin == nil) then UISkinOptions.RecountSkin = "Enabled" end
	if(UISkinOptions.EmbedRecount == nil) then UISkinOptions.EmbedRecount = "Disabled" end
	if(UISkinOptions.SearingPlasmaTrackerSkin == nil) then UISkinOptions.SearingPlasmaTrackerSkin = "Enabled" end
	if(UISkinOptions.SkadaSkin == nil) then UISkinOptions.SkadaSkin = "Enabled" end
	if(UISkinOptions.EmbedSkada == nil) then UISkinOptions.EmbedSkada = "Disabled" end
	if(UISkinOptions.SkilletSkin == nil) then UISkinOptions.SkilletSkin = "Enabled" end
	if(UISkinOptions.SpineCounterSkin == nil) then UISkinOptions.SpineCounterSkin = "Enabled" end
	if(UISkinOptions.SpySkin == nil) then UISkinOptions.SpySkin = "Enabled" end
	if(UISkinOptions.stAddonManagerSkin == nil) then UISkinOptions.stAddonManagerSkin = "Enabled" end
	if(UISkinOptions.SwatterSkin == nil) then UISkinOptions.SwatterSkin = "Enabled" end
	if(UISkinOptions.TellMeWhenSkin == nil) then UISkinOptions.TellMeWhenSkin = "Enabled" end
	if(UISkinOptions.TinyDPSSkin == nil) then UISkinOptions.TinyDPSSkin = "Enabled" end
	if(UISkinOptions.TitanPanelSkin == nil) then UISkinOptions.TitanPanelSkin = "Enabled" end
	if(UISkinOptions.WeakAuraSkin == nil) then UISkinOptions.WeakAuraSkin = "Enabled" end
	if(UISkinOptions.WowLuaSkin == nil) then UISkinOptions.WowLuaSkin = "Enabled" end
	if(UISkinOptions.ZygorSkin == nil) then UISkinOptions.ZygorSkin = "Enabled" end
	if(UISkinOptions.UISkinMinimap == nil) then UISkinOptions.UISkinMinimap = "Enabled" end
	if(UISkinOptions.LootConfirmer == nil) then UISkinOptions.LootConfirmer = "Enabled" end
	if(UISkinOptions.EmbedOoC == nil) then UISkinOptions.EmbedOoC = "Disabled" end
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

local SkinOptions = CreateFrame("Frame", "SkinOptions", UIParent)
	SkinOptions:RegisterEvent("PLAYER_ENTERING_WORLD")
	SkinOptions:SetScript("OnEvent", function(self)
	if IsAddOnLoaded("Tukui") then UIFont = [[Interface\AddOns\Tukui\medias\fonts\normal_font.ttf]] UIFontSize = 12 end
	if IsAddOnLoaded("ElvUI") then UIFont = [[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]] UIFontSize = 12 end
	SkinOptions:Hide()
	SkinOptions:SetTemplate("Transparent")
	SkinOptions:Point("CENTER", UIParent, "CENTER", 0, 0)
	SkinOptions:SetFrameStrata("MEDIUM")
	SkinOptions:Width(648)
	SkinOptions:Height(490)
	SkinOptions:SetClampedToScreen(true)
	SkinOptions:SetMovable(true)
	SkinOptions.text = SkinOptions:CreateFontString(nil, "OVERLAY")
	SkinOptions.text:SetFont(UIFont, 14, "OUTLINE")
	SkinOptions.text:SetPoint("TOP", SkinOptions, 0, -6)
	SkinOptions.text:SetText("|cffC495DDTukui|r & |cff1784d1ElvUI|r Skin Options")
	SkinOptions:EnableMouse(true)
	SkinOptions:RegisterForDrag("LeftButton");
	SkinOptions:SetScript("OnDragStart", function(self) self:StartMoving() end)
	SkinOptions:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

	SkinOptions2 = CreateFrame("Frame", "SkinOptions2", SkinOptions)
	SkinOptions2:SetTemplate("Transparent")
	SkinOptions2:Point("TOPLEFT", SkinOptions, "TOPLEFT", -202, -125)
	SkinOptions2:SetFrameStrata("MEDIUM")
	SkinOptions2:Width(200)
	SkinOptions2:Height(240)

	ApplySkinSettingsButton = CreateFrame("Button", "ApplySkinSettingsButton", SkinOptions, "UIPanelButtonTemplate")
	ApplySkinSettingsButton:SetPoint("BOTTOMLEFT", 0, -26)
	ApplySkinSettingsButton:Size(217,24)
	cSkinButton(ApplySkinSettingsButton)
	ApplySkinSettingsButton.text = ApplySkinSettingsButton:CreateFontString(nil, "OVERLAY")
	ApplySkinSettingsButton.text:SetFont(UIFont, UIFontSize, "OUTLINE")
	ApplySkinSettingsButton.text:SetPoint("CENTER", ApplySkinSettingsButton, 0, 0)
	ApplySkinSettingsButton.text:SetText("Apply Settings")
	ApplySkinSettingsButton:HookScript("OnClick", function() ReloadUI() end)

	EmbedWindowSettingsButton = CreateFrame("Button", "EmbedWindowSettingsButton", SkinOptions, "UIPanelButtonTemplate")
	EmbedWindowSettingsButton:SetPoint("BOTTOM", 0, -26)
	EmbedWindowSettingsButton:Size(212,24)
	cSkinButton(EmbedWindowSettingsButton)
	EmbedWindowSettingsButton.text = ApplySkinSettingsButton:CreateFontString(nil, "OVERLAY")
	EmbedWindowSettingsButton.text:SetFont(UIFont, UIFontSize, "OUTLINE")
	EmbedWindowSettingsButton.text:SetPoint("CENTER", EmbedWindowSettingsButton, 0, 0)
	EmbedWindowSettingsButton.text:SetText("Embedding Window Settings")
	EmbedWindowSettingsButton:HookScript("OnClick", function()
		if EmbeddingWindow:IsVisible() then
			EmbeddingWindow:Hide()
			print("Embedding Window is now |cffff2020Hidden|r.");
		else
			EmbeddingWindow:Show()
			print("Embedding Window is now |cff00ff00Shown|r.");
		end
	end)

	SkinOptionsCloseButton = CreateFrame("Button", "SkinOptionsCloseButton", SkinOptions, "UIPanelButtonTemplate")
	SkinOptionsCloseButton:SetPoint("BOTTOMRIGHT", 0, -26)
	SkinOptionsCloseButton:Size(217,24)
	cSkinButton(SkinOptionsCloseButton)
	SkinOptionsCloseButton.text = SkinOptionsCloseButton:CreateFontString(nil, "OVERLAY")
	SkinOptionsCloseButton.text:SetFont(UIFont, UIFontSize, "OUTLINE")
	SkinOptionsCloseButton.text:SetPoint("CENTER", SkinOptionsCloseButton, 0, 0)
	SkinOptionsCloseButton.text:SetText("Close Options")
	SkinOptionsCloseButton:HookScript("OnClick", function() SkinOptions:Hide() end)

--Buttons
	SkinOptionsButton = CreateFrame("Button", "SkinOptionsButton", GameMenuFrame, "GameMenuButtonTemplate")
	SkinOptionsButton:Point("TOP", GameMenuButtonMacros, "BOTTOM", 0 , -1)
	SkinOptionsButton:Size(144,21)
	cSkinButton(SkinOptionsButton)
	SkinOptionsButton.text = SkinOptionsButton:CreateFontString(nil, "OVERLAY")
	SkinOptionsButton.text:SetFont(UIFont, 12)
	if IsAddOnLoaded("ElvUI") then SkinOptionsButton.text:SetFont(c["media"].normFont, 12) end
	SkinOptionsButton.text:SetPoint("CENTER", SkinOptionsButton, 0, 0)
	SkinOptionsButton.text:SetText("Skins")
	SkinOptionsButton:HookScript("OnClick", function() SkinOptions:Show() HideUIPanel(GameMenuFrame) end)

	GameMenuButtonLogout:Point("TOP", GameMenuButtonMacros, "BOTTOM", 0 , -38)
	GameMenuFrame:Height(GameMenuFrame:GetHeight() + 26)
	if IsAddOnLoaded("stAddonmanager") then  
		SkinOptionsButton:Point("TOP", GameMenuButtonMacros, "BOTTOM", 0 , -23)
		GameMenuButtonLogout:Point("TOP", GameMenuButtonMacros, "BOTTOM", 0 , -60)
	end
	local function CreateButton(name,buttonText,addon,option,x,y,skinOptions2)
		local button = CreateFrame("Button", name, skinOptions2 and SkinOptions2 or SkinOptions, "UIPanelButtonTemplate")
		local yOffset = -30 - (25*(y-1))
		local xTable = {
			[1] = { point = "TOPLEFT", offset = 12 },
			[2] = { point = "TOP", offset = 0 },
			[3] = { point = "TOPRIGHT", offset = -12 }
		}
		button:SetPoint(xTable[x].point, xTable[x].offset, yOffset)
		button:Size(skinOptions2 and 175 or 200,20)
		cSkinButton(button)
		button.text = button:CreateFontString(nil, "OVERLAY")
		button.text:SetFont(UIFont, UIFontSize, "OUTLINE")
		button.text:SetPoint("CENTER", button, 0, 0)
		if (UISkinOptions[option] == "Enabled") then button.text:SetText(string.format("|cff00ff00%s|r",buttonText)) end
		if (UISkinOptions[option] == "Disabled") then button.text:SetText(string.format("|cffff2020%s|r",buttonText)) end
		if addon then
			if not IsAddOnLoaded(addon) then button:Disable() button.text:SetText(string.format("|cFF808080%s|r",buttonText)) end
		end
		button:HookScript("OnClick", function()
			if (UISkinOptions[option] == "Enabled") then
				UISkinOptions[option] = "Disabled"
				button.text:SetText(string.format("|cffff2020%s|r",buttonText))
			else
				UISkinOptions[option] = "Enabled"
				button.text:SetText(string.format("|cff00ff00%s|r",buttonText))
			end
		end)
	end
	local Skins = {
		["ACPSkin"] = {
			["buttonText"] = "Addon Control Panel",
			["addon"] = "AdiBags",
		},
		["AdiBagsSkin"] = {
			["addon"] = "AdiBags",
		},
		["AltoholicSkin"] = {
			["addon"] = "Altoholic",
		},
		["ArchySkin"] = {
			["addon"] = "Archy"
		},
		["ArkInventorySkin"] = {
			["addon"] = "ArkInventory"
		},
		["AtlasLootSkin"] = {
			["buttonText"] = "AtlasLoot",
			["addon"] = "AtlasLoot_Loader"
		},
		["ATSWSkin"] = {
			["addon"] = "AdvancedTradeSkillWindow"
		},
		["AuctionatorSkin"] = {
			["addon"] = "Auctionator"
		},
		["AuctioneerSkin"] = {
			["buttonText"] = "Auctioneer",
			["addon"] = "Auc-Advanced"
		},
		["BPTSkin"] = {
			["buttonText"] = "Balance Power Tracker",
			["addon"] = "BalancePowerTracker"
		},
		["BGDefenderSkin"] = {
			["addon"] = "BGDefender"
		},
		["BigWigsSkin"] = {
			["addon"] = "BigWigs"
		},
		["BuyEmAllSkin"] = {
			["addon"] = "BuyEmAll"
		},
		["ChocolateBarSkin"] = {
			["addon"] = "ChocolateBar"
		},
		["CliqueSkin"] = {
			["addon"] = "Clique"
		},
		["DBMSkin"] = {
			["buttonText"] = "DBM",
			["addon"] = "DBM-Core"
		},
		["EasyMailSkin"] = {
			["addon"] = "EasyMail"
		},
		["EnergyWatchSkin"] = {
			["addon"] = "EnergyWatch"
		},
		["ExtVendorSkin"] = {
			["buttonText"] = "Extended Vendor",
			["addon"] = "ExtVendor"
		},
		["FactionizerSkin"] = {
			["addon"] = "Factionizer"
		},
		["KarniCrapSkin"] = {
			["buttonText"] = "Karni's Crap Filter",
			["addon"] = "KarniCrap"
		},
		["LightheadedSkin"] = {
			["addon"] = "Lightheaded"
		},
		["LootCouncilLiteSkin"] = {
			["buttonText"] = "LootCouncilLite",
			["addon"] = "LootCouncil_Lite"
		},
		["MageNuggetsSkin"] = {
			["addon"] = "MageNuggests"
		},
		["MasterLootManagerRemixSkin"] = {
			["addon"] = "MasterLootManagerRemix"
		},
		["MinimalArchaeologySkin"] = {
			["addon"] = "MinimalArchaeology"
		},
		["MoveAnythingSkin"] = {
			["addon"] = "MoveAnything"
		},
		["MRTSkin"] = {
			["buttonText"] = "Mizus Raid Tracker",
			["addon"] = "MizusRaidTracker"
		},
		["MyRolePlaySkin"] = {
			["addon"] = "MyRolePlay"
		},
		["OdysseySkin"] = {
			["addon"] = "Odyssey"
		},
		["OgriLazySkin"] = {
			["addon"] = "Ogri'Lazy"
		},
		["OmenSkin"] = {
			["addon"] = "Omen"
		},
		["OutfitterSkin"] = {
			["addon"] = "Outfitter"
		},
		["PoisonerSkin"] = {
			["addon"] = "Poisoner"
		},
		["PoMTrackerSkin"] = {
			["addon"] = "PoMTracker"
		},
		["PostalSkin"] = {
			["addon"] = "Postal"
		},
		["PowerAurasSkin"] = {
			["addon"] = "PowerAuras"
		},
		["QuartzSkin"] = {
			["addon"] = "Quartz"
		},
		["RaidInviteOrganizerSkin"] = {
			["buttonText"] = "Raid Invite Organizer",
			["addon"] = "RaidInviteOrganizer"
		},
		["RaidBuffStatusSkin"] = {
			["buttonText"] = "Raid Buff Status",
			["addon"] = "RaidBuffStatus"
		},
		["RecountSkin"] = {
			["addon"] = "Recount"
		},
		["SearingPlasmaTrackerSkin"] = {
			["buttonText"] = "Searing Plasma Tracker",
			["addon"] = "SearingPlasmaTracker"
		},
		["SkadaSkin"] = {
			["addon"] = "Skada"
		},
		["SkilletSkin"] = {
			["addon"] = "Skillet"
		},
		["SpineCounterSkin"] = {
			["buttonText"] = "Spine Blood Counter",
			["addon"] = "SpineCounter"
		},
		["SpySkin"] = {
			["addon"] = "Spy"
		},
		["stAddonManagerSkin"] = {
			["buttonText"] = "stAddonManager",
			["addon"] = "stAddonmanager"
		},
		["SwatterSkin"] = {
			["buttonText"] = "Swatter",
			["addon"] = "!Swatter"
		},
		["TellMeWhenSkin"] = {
			["addon"] = "TellMeWhen"
		},
		["TinyDPSSkin"] = {
			["addon"] = "TinyDPS"
		},
		["TitanPanelSkin"] = {
			["buttonText"] = "TitanPanel",
			["addon"] = "Titan"
		},
		["WowLuaSkin"] = {
			["addon"] = "WowLua"
		},
		["ZygorSkin"] = {
			["buttonText"] = "Zygor",
			["addon"] = "ZygorGuidesViewer"
		},
	}
	--local function CreateButton(name,buttonText,addon,option,x,y)
	function pairsByKeys (t, f)
      local a = {}
      for n in pairs(t) do table.insert(a, n) end
      table.sort(a, f)
      local i = 0      -- iterator variable
      local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
      end
      return iter
    end
    local curX,curY,maxY=1,1,18
	for skin,options in pairsByKeys(Skins) do
		local addon = options.addon
		local buttonText = options.buttonText or addon
		CreateButton(string.format('%sButton',skin),buttonText,addon,skin,curX,curY)
		curY = curY + 1
		if curY > maxY then
			curX = curX + 1
			curY = 1
		end
	end

	SkinOptions2.text = SkinOptions2:CreateFontString(nil, "OVERLAY")
	SkinOptions2.text:SetFont(UIFont, 14, "OUTLINE")
	SkinOptions2.text:SetPoint("TOP", SkinOptions2, 0, -8)
	SkinOptions2.text:SetText("|cffC495DDTukui|r & |cff1784d1ElvUI|r Module Options")

	local Skins2 = {
		["LootConfirmer"] = {
			["buttonText"] = "Loot Confirm"
		},
		["UISkinMinimap"] = {
			["buttonText"] = "Square Minimap Buttons"
		}
	}

	curY = 1
	for skin,options in pairsByKeys(Skins2) do
		local addon = nil
		local buttonText = options.buttonText
		CreateButton(string.format('%sButton',skin),buttonText,addon,skin,2,curY,true)
		curY = curY + 1
	end

if IsAddOnLoaded("ElvUI") then
	-- ElvUI Only
	SkinOptions2.text2 = SkinOptions2:CreateFontString(nil, "OVERLAY")
	SkinOptions2.text2:SetFont(UIFont, 14, "OUTLINE")
	SkinOptions2.text2:SetPoint("TOP", SkinOptions2, 0, -82)
	SkinOptions2.text2:SetText("|cff1784d1ElvUI|r Only Options")

	local ElvSkins2 = {
		["CLCInfoSkin"] = {
			["addon"] = "CLCInfo"
		},
		["CLCProtSkin"] = {
			["addon"] = "CLCProt"
		},
		["CLCRetSkin"] = {
			["addon"] = "CLCRet"
		},
		["PowerAurasIconsSkin"] = {
			["buttonText"] = "PowerAuras Icon's",
			["addon"] = "PowerAuras"
		},
		["WeakAurasIconsSkin"] = {
			["buttonText"] = "WeakAuras Icon's",
			["addon"] = "WeakAuras"
		},
	}

	curY = 4
	for skin,options in pairsByKeys(ElvSkins2) do
		local addon = options.addon
		local buttonText = options.buttonText or addon
		CreateButton(string.format('%sButton',skin),buttonText,addon,skin,2,curY,true)
		curY = curY + 1
	end
end

--Killing for specfic UI's

if IsAddOnLoaded("AsphyxiaUI") or IsAddOnLoaded("SinarisUI") then
	EmbedWindowSettingsButton:Disable() EmbedWindowSettingsButton.text:SetText("Embedding Window Settings")
	SkadaSkinButton:Disable() UISkinOptions.SkadaSkin = "Disabled" SkadaSkinButton.text:SetText("Skada : Disabled by UI")
	RecountSkinButton:Disable() UISkinOptions.RecountSkin = "Disabled" RecountSkinButton.text:SetText("Recount : Disabled by UI")
	DBMSkinButton:Disable() UISkinOptions.DBMSkin = "Disabled" DBMSkinButton.text:SetText("DBM : Disabled by UI")
	TinyDPSSkinButton:Disable() UISkinOptions.TinyDPSSkin = "Disabled" TinyDPSSkinButton.text:SetText("TinyDPS : Disabled by UI")
	BigWigsSkinButton:Disable() UISkinOptions.BigWigsSkin = "Disabled" BigWigsSkinButton.text:SetText("BigWigs : Disabled by UI")
	OmenSkinButton:Disable() UISkinOptions.OmenSkin = "Disabled" OmenSkinButton.text:SetText("Omen : Disabled by UI")
end
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

SLASH_SKINOPTIONSWINDOW1 = '/skinoptions';
function SlashCmdList.SKINOPTIONSWINDOW(msg, editbox)
	if SkinOptions:IsVisible() then
		SkinOptions:Hide()
		print("Skin Control Panel is now |cffff2020Hidden|r.");
	else
		SkinOptions:Show()
		print("Skin Control Panel is now |cff00ff00Shown|r.");
	end
end

end)