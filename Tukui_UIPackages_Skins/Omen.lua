if not (IsAddOnLoaded("ElvUI") or IsAddOnLoaded("Tukui")) or not IsAddOnLoaded("Omen") then return end

function EmbedOmen()
	if not IsAddOnLoaded("Omen") then UISkinOptions.EmbedOmen = "Disabled" return end
	if (UISkinOptions.EmbedOoC == "Enabled") then
		if (UISkinOptions.EmbedOmen == "Enabled") then
			OmenBarList:Hide()
		end
	end
		Omen.db.profile.Locked = true
		Omen:UpdateGrips()
		Omen.UpdateGrips = function(...)
			local db = Omen.db.profile
				Omen.VGrip1:ClearAllPoints()
				Omen.VGrip1:SetPoint("TOPLEFT", Omen.BarList, "TOPLEFT", db.VGrip1, 0)
				Omen.VGrip1:SetPoint("BOTTOMLEFT", Omen.BarList, "BOTTOMLEFT", db.VGrip1, 0)
				Omen.VGrip2:ClearAllPoints()
				Omen.VGrip2:SetPoint("TOPLEFT", Omen.BarList, "TOPLEFT", db.VGrip2, 0)
				Omen.VGrip2:SetPoint("BOTTOMLEFT", Omen.BarList, "BOTTOMLEFT", db.VGrip2, 0)
				Omen.Grip:Hide()
				if db.Locked then
					Omen.VGrip1:Hide()
					Omen.VGrip2:Hide()
				else
					Omen.VGrip1:Show()
					if db.Bar.ShowTPS then
						Omen.VGrip2:Show()
					else
						Omen.VGrip2:Hide()
					end
				end
		end
		OmenTitle:Kill()
		OmenBarList:StripTextures()
		OmenBarList:SetTemplate("Default")
		OmenAnchor:ClearAllPoints()
		OmenAnchor:SetPoint("TOPLEFT", EmbeddingWindow, "TOPLEFT", 0, 16)

		OmenAnchor:SetWidth(EmbeddingWindow:GetWidth())
		OmenAnchor:SetHeight(EmbeddingWindow:GetHeight() + 12)

		OmenAnchor:SetFrameStrata("MEDIUM")
end

local SkinOmen = CreateFrame("Frame")
	SkinOmen:RegisterEvent("PLAYER_ENTERING_WORLD")
	SkinOmen:SetScript("OnEvent", function(self)
	if (UISkinOptions.OmenSkin == "Disabled") then return end
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	local s = UIPackageSkinFuncs.s
	local c = UIPackageSkinFuncs.c

	if(TukuiThreatBar) then TukuiThreatBar:Kill() end

local borderWidth = 2

Omen.UpdateBarTextureSettings_ = Omen.UpdateBarTextureSettings
Omen.UpdateBarTextureSettings = function(self)
	for i, v in ipairs(self.Bars) do
		v.texture:SetTexture(c["media"].normTex)
	end
end

Omen.UpdateBarLabelSettings_ = Omen.UpdateBarLabelSettings
Omen.UpdateBarLabelSettings = function(self)
	self:UpdateBarLabelSettings_()
	for i, v in ipairs(self.Bars) do
	if IsAddOnLoaded("Tukui") then
		v.Text1:SetFont(c["media"].font, c["datatext"].fontsize)
		v.Text2:SetFont(c["media"].font, c["datatext"].fontsize)
		v.Text3:SetFont(c["media"].font, c["datatext"].fontsize)
	end
	if IsAddOnLoaded("ElvUI") then
		v.Text1:FontTemplate(nil, self.db.profile.Bar.FontSize)
		v.Text2:FontTemplate(nil, self.db.profile.Bar.FontSize)
		v.Text3:FontTemplate(nil, self.db.profile.Bar.FontSize)
	end
	end
end

Omen.UpdateTitleBar_ = Omen.UpdateTitleBar
Omen.UpdateTitleBar = function(self)
	Omen.db.profile.Scale = 1
	Omen.db.profile.Background.EdgeSize = 1
	Omen.db.profile.Background.BarInset = borderWidth
	Omen.db.profile.TitleBar.UseSameBG = true
	self:UpdateTitleBar_()
	if IsAddOnLoaded("Tukui") then
		self.Title:SetHeight(23)
		self.TitleText:SetFont(c["media"].font, c["datatext"].fontsize)
		self.TitleText:ClearAllPoints()
		self.TitleText:SetPoint("CENTER")
	end
	if IsAddOnLoaded("ElvUI") then
		self.TitleText:FontTemplate(nil, self.db.profile.TitleBar.FontSize)
	end
	self.BarList:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, 1)
end

Omen.UpdateBackdrop_ = Omen.UpdateBackdrop
Omen.UpdateBackdrop = function(self)
	Omen.db.profile.Scale = 1
	Omen.db.profile.Background.EdgeSize = 1
	Omen.db.profile.Background.BarInset = borderWidth
	self:UpdateBackdrop_()
	self.BarList:SetTemplate("Default")
	self.Title:SetTemplate("Default", True)
	self.BarList:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, 1)
end

local omen_mt = getmetatable(Omen.Bars)
local oldidx = omen_mt.__index
omen_mt.__index = function(self, barID)
	local bar = oldidx(self, barID)
	Omen:UpdateBarTextureSettings()
	Omen:UpdateBarLabelSettings()
	return bar
end

Omen.db.profile.Bar.Spacing = 1
if IsAddOnLoaded("ElvUI") then
	Omen.db.profile.Background.Texture = "ElvUI Blank"
end

Omen:UpdateBarTextureSettings()
Omen:UpdateBarLabelSettings()
Omen:UpdateTitleBar()
Omen:UpdateBackdrop()
Omen:ReAnchorBars()
Omen:ResizeBars()

end)