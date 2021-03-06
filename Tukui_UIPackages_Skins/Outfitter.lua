if not (IsAddOnLoaded("ElvUI") or IsAddOnLoaded("Tukui")) or not IsAddOnLoaded("Outfitter") then return end
local SkinOutfitter = CreateFrame("Frame")
	SkinOutfitter:RegisterEvent("PLAYER_ENTERING_WORLD")
	SkinOutfitter:SetScript("OnEvent", function(self)
	if (UISkinOptions.OutfitterSkin == "Disabled") then return end
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	local s = UIPackageSkinFuncs.s
	local c = UIPackageSkinFuncs.c

CharacterFrame:HookScript("OnShow", function(self) PaperDollSidebarTabs:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight, "TOPRIGHT", -14, 0) end)
OutfitterFrame:HookScript("OnShow", function(self) 
	cSkinFrame(OutfitterFrame)
	OutfitterFrameTab1:Size(60,25)
	OutfitterFrameTab2:Size(60,25)
	OutfitterFrameTab3:Size(60,25)
	OutfitterMainFrame:StripTextures(True)
	for i = 0,13 do
		if _G["OutfitterItem"..i.."OutfitMenu"] then 
			cSkinNextPrevButton(_G["OutfitterItem"..i.."OutfitMenu"])
			_G["OutfitterItem"..i.."OutfitMenu"]:Size(16)
		end
		if _G["OutfitterItem"..i.."OutfitSelected"] then 
			cSkinButton(_G["OutfitterItem"..i.."OutfitSelected"])
			_G["OutfitterItem"..i.."OutfitSelected"]:ClearAllPoints()
			_G["OutfitterItem"..i.."OutfitSelected"]:Size(16)
			_G["OutfitterItem"..i.."OutfitSelected"]:Point("LEFT", _G["OutfitterItem"..i.."Outfit"], "LEFT", 8, 0)
		end
	end
--		Outfitter.NameOutfitDialog.DoneButton:StripTextures(True)
--		Outfitter.NameOutfitDialog.CancelButton:StripTextures(True)
--		cSkinFrame(Outfitter.NameOutfitDialog)
--		cSkinFrame(Outfitter.NameOutfitDialog.InfoSection)
--		cSkinFrame(Outfitter.NameOutfitDialog.BuildSection)
--		cSkinFrame(Outfitter.NameOutfitDialog.StatsSection)
--		cSkinButton(Outfitter.NameOutfitDialog.EmptyOutfitCheckButton)
--		cSkinButton(Outfitter.NameOutfitDialog.ExistingOutfitCheckButton)
--		cSkinButton(Outfitter.NameOutfitDialog.GenerateOutfitCheckButton)
--		cSkinButton(Outfitter.NameOutfitDialog.DoneButton)
--		cSkinButton(Outfitter.NameOutfitDialog.CancelButton)
--		cSkinFrame(Outfitter.RebuildOutfitDialog)
--		cSkinFrame(Outfitter.RebuildOutfitDialog.StatsSection)
--		Outfitter.RebuildOutfitDialog.DoneButton:StripTextures(True)
--		Outfitter.RebuildOutfitDialog.CancelButton:StripTextures(True)
--		cSkinButton(Outfitter.RebuildOutfitDialog.DoneButton)
--		cSkinButton(Outfitter.RebuildOutfitDialog.CancelButton)
	end)


	OutfitterMainFrameScrollbarTrench:StripTextures(True)
	OutfitterFrameTab1:StripTextures(True)
	OutfitterFrameTab2:StripTextures(True)
	OutfitterFrameTab3:StripTextures(True)
	OutfitterFrameTab1:ClearAllPoints()
	OutfitterFrameTab2:ClearAllPoints()
	OutfitterFrameTab3:ClearAllPoints()
	OutfitterFrameTab1:Point("TOPLEFT", OutfitterFrame, "BOTTOMRIGHT", -65, -2)
	OutfitterFrameTab2:Point("LEFT", OutfitterFrameTab1, "LEFT", -65, 0)
	OutfitterFrameTab3:Point("LEFT", OutfitterFrameTab2, "LEFT", -65, 0)
	cSkinButton(OutfitterFrameTab1)
	cSkinButton(OutfitterFrameTab2)
	cSkinButton(OutfitterFrameTab3)

	cSkinScrollBar(OutfitterMainFrameScrollFrameScrollBar)
	cSkinCloseButton(OutfitterCloseButton)
	cSkinButton(OutfitterNewButton)
	cSkinButton(OutfitterEnableNone)
	cSkinButton(OutfitterEnableAll)

	cDesaturate(OutfitterButton)
	OutfitterButton:ClearAllPoints()
	OutfitterButton:SetPoint("RIGHT", PaperDollSidebarTabs, "RIGHT", 26, -2)
	OutfitterButton:SetHighlightTexture(nil)

	OutfitterSlotEnables:SetFrameStrata("HIGH")
	cSkinCheckBox(OutfitterEnableHeadSlot)
	cSkinCheckBox(OutfitterEnableNeckSlot)
	cSkinCheckBox(OutfitterEnableShoulderSlot)
	cSkinCheckBox(OutfitterEnableBackSlot)
	cSkinCheckBox(OutfitterEnableChestSlot)
	cSkinCheckBox(OutfitterEnableShirtSlot)
	cSkinCheckBox(OutfitterEnableTabardSlot)
	cSkinCheckBox(OutfitterEnableWristSlot)
	cSkinCheckBox(OutfitterEnableMainHandSlot)
	cSkinCheckBox(OutfitterEnableSecondaryHandSlot)
	cSkinCheckBox(OutfitterEnableHandsSlot)
	cSkinCheckBox(OutfitterEnableWaistSlot)
	cSkinCheckBox(OutfitterEnableLegsSlot)
	cSkinCheckBox(OutfitterEnableFeetSlot)
	cSkinCheckBox(OutfitterEnableFinger0Slot)
	cSkinCheckBox(OutfitterEnableFinger1Slot)
	cSkinCheckBox(OutfitterEnableTrinket0Slot)
	cSkinCheckBox(OutfitterEnableTrinket1Slot)

	cSkinButton(OutfitterItemComparisons)
	cSkinButton(OutfitterTooltipInfo)
	cSkinButton(OutfitterShowHotkeyMessages)
	cSkinButton(OutfitterShowMinimapButton)
	cSkinButton(OutfitterShowOutfitBar)
	cSkinButton(OutfitterAutoSwitch)
	OutfitterItemComparisons:Size(20)
	OutfitterTooltipInfo:Size(20)
	OutfitterShowHotkeyMessages:Size(20)
	OutfitterShowMinimapButton:Size(20)
	OutfitterShowOutfitBar:Size(20)
	OutfitterAutoSwitch:Size(20)

	OutfitterShowOutfitBar:Point("TOPLEFT", OutfitterAutoSwitch, "BOTTOMLEFT", 0, -5)

	cSkinButton(OutfitterEditScriptDialogDoneButton)
	cSkinButton(OutfitterEditScriptDialogCancelButton)
	cSkinScrollBar(OutfitterEditScriptDialogSourceScriptScrollBar)
	OutfitterEditScriptDialogSourceScript:CreateBackdrop()
	cSkinFrame(OutfitterEditScriptDialog)
	cSkinCloseButton(OutfitterEditScriptDialog.CloseButton)
	cSkinTab(OutfitterEditScriptDialogTab1)
	cSkinTab(OutfitterEditScriptDialogTab2)
	cSkinDropDownBox(OutfitterEditScriptDialogPresetScript)

end)
