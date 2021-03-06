LoadAddOn("stAddonmanager")
if not (IsAddOnLoaded("ElvUI") or IsAddOnLoaded("Tukui")) or not IsAddOnLoaded("stAddonmanager") then return end
local SkinstAddonmanager = CreateFrame("Frame")
	SkinstAddonmanager:RegisterEvent("PLAYER_ENTERING_WORLD")
	SkinstAddonmanager:SetScript("OnEvent", function(self)
	if (UISkinOptions.stAddonManagerSkin ~= "Enabled") then return end
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	stAddonManager:LoadWindow()
	stAddonManager:CreateBackdrop()
	stAddonManager_ScrollBackground:CreateBackdrop()
	stAddonManager_ScrollBackground.backdrop:SetBackdropColor(0,0,0,0)
	cSkinEditBox(stAddonManager_SearchBar)
	stAddonManager.reloadButton:CreateBackdrop()
	stAddonManager.profileButton:CreateBackdrop()
	stAddonManager_ScrollFrameScrollBar.thumbbg:CreateBackdrop()
	stAddonManager:Hide()
end)