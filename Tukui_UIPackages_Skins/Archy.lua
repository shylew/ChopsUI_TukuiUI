if not(IsAddOnLoaded("Tukui") or IsAddOnLoaded("ElvUI")) or not IsAddOnLoaded("Archy") then return end
local SkinArchy = CreateFrame("Frame")
SkinArchy:RegisterEvent("PLAYER_ENTERING_WORLD")
SkinArchy:SetScript("OnEvent", function(self, event, addon)
	if (UISkinOptions.ArchySkin ~= "Enabled") then return end

	local s = UIPackageSkinFuncs.s
	local c = UIPackageSkinFuncs.c

	local function SkinArchyArtifactFrame()
		cSkinFrame(ArchyArtifactFrame)
		ArchyArtifactFrame:SetParent(UIParent)
		ArchyArtifactFrame:SetScale(1)
		--ArchyArtifactFrame:CreateBackdrop()
		--ArchyArtifactFrame.backdrop:SetParent(UIParent)
		--ArchyArtifactFrame.backdrop:Point("TOPLEFT", ArchyArtifactFrame, 0, 0)
		--ArchyArtifactFrame.backdrop:Point("BOTTOMRIGHT", ArchyArtifactFrame, 0, 0)
	end

	hooksecurefunc(Archy, "UpdateRacesFrame", SkinArchyArtifactFrame)

	local function SkinArchyDigSiteFrame()
		cSkinFrame(ArchyDigSiteFrame)
		ArchyDigSiteFrame:SetParent(UIParent)
		ArchyDigSiteFrame:SetScale(1)
		--ArchyDigSiteFrame:CreateBackdrop()
		--ArchyDigSiteFrame.backdrop:SetParent(UIParent)
		--ArchyDigSiteFrame.backdrop:Point("TOPLEFT", ArchyArtifactFrame, 0, 0)
		--ArchyDigSiteFrame.backdrop:Point("BOTTOMRIGHT", ArchyArtifactFrame, 0, 0)
	end

	hooksecurefunc(Archy, "UpdateDigSiteFrame", SkinArchyDigSiteFrame)

	if ArchyArtifactFrameSkillBar then
		cSkinStatusBar(ArchyArtifactFrameSkillBar)
	end
	cSkinButton(ArchyDistanceIndicatorFrameSurveyButton)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end)
