if not (IsAddOnLoaded("ElvUI") or IsAddOnLoaded("Tukui")) or not IsAddOnLoaded("MoveAnything") then return end
local SkinMoveAnything = CreateFrame("Frame")
	SkinMoveAnything:RegisterEvent("PLAYER_ENTERING_WORLD")
	SkinMoveAnything:SetScript("OnEvent", function(self)
	if (UISkinOptions.MoveAnythingSkin == "Disabled") then return end
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	local s = UIPackageSkinFuncs.s
	local c = UIPackageSkinFuncs.c

	cSkinFrame(MAOptions)
	MAScrollBorder:StripTextures(True)

	cSkinScrollBar(MAScrollFrameScrollBar)
	cSkinButton(MAOptionsSync)
	cSkinButton(MAOptionsOpenBlizzardOptions)
	cSkinButton(MAOptionsClose)
	cSkinButton(GameMenuButtonMoveAnything)
	GameMenuButtonMoveAnything:CreateBackdrop("Transparent")
	GameMenuButtonMoveAnything:ClearAllPoints()
	GameMenuButtonMoveAnything:Point("TOP", GameMenuFrame, "BOTTOM", 0, -3)

	cSkinCheckBox(MAOptionsToggleModifiedFramesOnly)
	cSkinCheckBox(MAOptionsToggleCategories)
	cSkinCheckBox(MAOptionsToggleFrameStack)
	cSkinCheckBox(MAOptionsToggleMovers)
	cSkinCheckBox(MAOptionsToggleFrameEditors)

	for i = 1, 100 do
		if _G["MAMove"..i.."Reset"] then cSkinButton(_G["MAMove"..i.."Reset"]) end
		if _G["MAMove"..i.."Reset"] then cSkinButton(_G["MAMove"..i.."Reset"]) end
		if _G["MAMove"..i.."Backdrop"] then cSkinFrame(_G["MAMove"..i.."Backdrop"]) end
		if _G["MAMove"..i.."Move"] then cSkinCheckBox(_G["MAMove"..i.."Move"]) end
		if _G["MAMove"..i.."Hide"] then cSkinCheckBox(_G["MAMove"..i.."Hide"]) end
	end

	cSkinFrame(MANudger)
	cSkinButton(MANudger_CenterMe)
	cSkinButton(MANudger_CenterH)
	cSkinButton(MANudger_CenterV)
	cSkinButton(MANudger_NudgeUp)
	cSkinButton(MANudger_NudgeDown)
	cSkinButton(MANudger_NudgeLeft)
	cSkinButton(MANudger_NudgeRight)
	cSkinButton(MANudger_Detach)
	cSkinButton(MANudger_Hide)

end)