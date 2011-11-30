local T, C, L = unpack(Tukui)
ChopsUI.RegisterModule("skada", Skada)

-- Handle showing/hiding of Skada, and toggling of the underlying loot frame
local skadaLeftFrame = _G["SkadaBarWindowSkadaLeft"]
local skadaRightFrame = _G["SkadaBarWindowSkadaRight"]
if skadaLeftFrame then
  skadaLeftFrame:HookScript("OnShow", function() ChopsUI.modules.skada.Show() end)
  skadaLeftFrame:HookScript("OnHide", function() ChopsUI.modules.skada.Hide() end)
end
if skadaRightFrame then
  skadaRightFrame:HookScript("OnShow", function() ChopsUI.modules.skada.Show() end)
  skadaRightFrame:HookScript("OnHide", function() ChopsUI.modules.skada.Hide() end)
end
ChatFrame4Tab:HookScript("OnClick", function() ChopsUI.modules.skada.Hide() end)
SkadaActivationButton:HookScript("OnClick", function() ChopsUI.modules.skada.Show() end)

local barSpacing = 1
local borderWidth = 2
local barmod = Skada.displays["bar"]

barmod.ApplySettings_ = barmod.ApplySettings
barmod.ApplySettings = function(self, win)
	win.db.enablebackground = true
	win.db.background.borderthickness = borderWidth
	barmod:ApplySettings_(win)

	win.bargroup:SetTexture(C["media"].normTex)
	win.bargroup:SetSpacing(barSpacing)
	win.bargroup:SetFont(C["media"].font, C["general"].fontscale)
	win.bargroup:SetFrameLevel(5)

	local titlefont = CreateFont("TitleFont"..win.db.name)
	titlefont:SetFont(C["media"].font, 12)
	win.bargroup.button:SetNormalFontObject(titlefont)

	local color = win.db.title.color
	win.bargroup.button:SetBackdropColor(unpack(C["media"].bordercolor))
	if win.bargroup.bgframe then
		win.bargroup.bgframe:SetTemplate("Transparent")
		if win.db.reversegrowth then
			win.bargroup.bgframe:SetPoint("BOTTOM", win.bargroup.button, "BOTTOM", 0, -1 * (win.db.enabletitle and 2 or 1))
		else
			win.bargroup.bgframe:SetPoint("TOP", win.bargroup.button, "TOP", 0,1 * (win.db.enabletitle and 2 or 1))
		end
	end

  win.bargroup.button:SetFrameStrata("HIGH")
  win.bargroup.button:SetFrameLevel(5)	
  win.bargroup:SetFrameStrata("HIGH")

	self:AdjustBackgroundHeight(win)
	win.bargroup:SetMaxBars(win.db.barmax)
	win.bargroup:SortBars()
end

-- Size height correctly
barmod.AdjustBackgroundHeight = function(self,win)
	local numbars = 0
	if win.bargroup:GetBars() ~= nil then
		if win.db.background.height == 0 then
			for name, bar in pairs(win.bargroup:GetBars()) do if bar:IsShown() then numbars = numbars + 1 end end
		else
      if win.db.barmax ~= nil then
        numbars = win.db.barmax
      end
		end
		if win.db.enabletitle then numbars = numbars + 1 end
		if numbars < 1 then numbars = 1 end
		local height = numbars * (win.db.barheight + barSpacing) + barSpacing + borderWidth
		if win.bargroup:GetHeight() ~= height then
			win.bargroup:SetHeight(height)
		end
	end
end

local Skada_Skin = CreateFrame("Frame")
Skada_Skin:RegisterEvent("PLAYER_ENTERING_WORLD")
Skada_Skin:SetScript("OnEvent", function(self)
  self:UnregisterAllEvents()
  self = nil
  ChopsUI.modules.skada.PositionWindows()
end)	

-- Event callback for OnShow event in Skada windows
function ChopsUI.modules.skada.Show()
  Skada:SetActive(true)
end

-- Event callback for OnHide event in Skada windows
function ChopsUI.modules.skada.Hide()
  Skada:SetActive(false)
end

-- Position the Skada windows
function ChopsUI.modules.skada.PositionWindows()

  local leftWindow = Skada:GetWindows()[1]
  local rightWindow = Skada:GetWindows()[2]

  if leftWindow then
    leftWindow.bargroup:ClearAllPoints()
    leftWindow.bargroup:SetPoint("TOPLEFT", TukuiChatBackgroundRight, "TOPLEFT", 8, -33)
  end

  if rightWindow then
    rightWindow.bargroup:ClearAllPoints()
    rightWindow.bargroup:SetPoint("TOPRIGHT", TukuiChatBackgroundRight, "TOPRIGHT", -8, -33)
  end

end

-- Reset Skada
function ChopsUI.modules.skada.Reset()

  local chatBackground = _G["TukuiChatBackgroundLeft"]

-- Switch the Skada profile to a character specific profile
  local skadaProfile = UnitName("player") .. " - " .. GetRealmName()
  Skada.db:SetProfile(skadaProfile)
  
  -- Reset Skada windows
  Skada.db.profile.windows = {}

  -- Figure out the proper size of the Skada windows
  local panelWidth = chatBackground:GetWidth() - 22
  local panelHeight = chatBackground:GetHeight() - 58
  local windowWidth = panelWidth / 2
  local windowHeight = panelHeight
  local barHeight = windowHeight / 8
  local maxBars = math.floor(windowHeight / barHeight) - 1

  -- Set some general Skada options
  Skada.db.profile.icon.hide = true
  Skada.db.profile.hidesolo = false

  -- Create the Skada windows
  Skada:CreateWindow("SkadaLeft")
  Skada:CreateWindow("SkadaRight")
  local skadaLeftWindow = Skada.db.profile.windows[1]
  local skadaRightWindow = Skada.db.profile.windows[2]

  -- Configure the windows
  for i = 1, 2 do
    Skada.db.profile.windows[i].set = "current"
    Skada.db.profile.windows[i].barwidth = windowWidth
    Skada.db.profile.windows[i].barheight = barHeight
    Skada.db.profile.windows[i].barmax = maxBars
    Skada.db.profile.windows[i].barslocked = true
    Skada.db.profile.windows[i].enabletitle = false
    Skada.db.profile.windows[i].spark = false
  end

  skadaLeftWindow.mode = "Threat"
  skadaRightWindow.mode = "Damage"

end
