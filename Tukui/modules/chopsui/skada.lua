local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
assert(Skada, "ChopsUI Skada extension failed to load, make sure Skada is enabled")

-- Handle showing/hiding of Skada, and toggling of the underlying loot frame
local skadaLeftFrame = _G["SkadaBarWindowSkadaLeft"]
local skadaRightFrame = _G["SkadaBarWindowSkadaRight"]
if skadaLeftFrame then
  skadaLeftFrame:HookScript("OnShow", function() ChopsuiDisplaySkada() end)
  skadaLeftFrame:HookScript("OnHide", function() ChopsuiHideSkada() end)
end
if skadaRightFrame then
  skadaRightFrame:HookScript("OnShow", function() ChopsuiDisplaySkada() end)
  skadaRightFrame:HookScript("OnHide", function() ChopsuiHideSkada() end)
end
ChatFrame4Tab:HookScript("OnClick", function() ChopsuiHideSkada() end)
SkadaActivationButton:HookScript("OnClick", function() ChopsuiDisplaySkada() end)

local barSpacing = 1
local borderWidth = 2

-- Used to strip unecessary options from the in-game config
local function StripOptions(options)
	options.baroptions.args.bartexture = options.windowoptions.args.height
	options.baroptions.args.bartexture.order = 12
	options.baroptions.args.bartexture.max = 1
	options.baroptions.args.barspacing = nil
	options.titleoptions.args.texture = nil
	options.titleoptions.args.bordertexture = nil
	options.titleoptions.args.thickness = nil
	options.titleoptions.args.margin = nil
	options.titleoptions.args.color = nil
	options.windowoptions = nil
	options.baroptions.args.barfont = nil
	options.titleoptions.args.font = nil
end

local barmod = Skada.displays["bar"]
barmod.AddDisplayOptions_ = barmod.AddDisplayOptions
barmod.AddDisplayOptions = function(self, win, options)
	self:AddDisplayOptions_(win, options)
	StripOptions(options)
end

for k, options in pairs(Skada.options.args.windows.args) do
	if options.type == "group" then
		StripOptions(options.args)
	end
end

barmod.ApplySettings_ = barmod.ApplySettings
barmod.ApplySettings = function(self, win)
	win.db.enablebackground = true
	win.db.background.borderthickness = borderWidth
	barmod:ApplySettings_(win)

	if win.db.enabletitle then
		win.bargroup.button:SetBackdrop(titleBG)
	end

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
  win.bargroup.bgframe:SetFrameStrata("HIGH")
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
			numbars = win.db.barmax
		end
		if win.db.enabletitle then numbars = numbars + 1 end
		if numbars < 1 then numbars = 1 end
		local height = numbars * (win.db.barheight + barSpacing) + barSpacing + borderWidth
		if win.bargroup.bgframe:GetHeight() ~= height then
			win.bargroup.bgframe:SetHeight(height)
		end
	end
end

-- Override settings from in-game GUI
local titleBG = {
	bgFile = C["media"].normTex,
	tile = false,
	tileSize = 0
}

local Skada_Skin = CreateFrame("Frame")
Skada_Skin:RegisterEvent("PLAYER_ENTERING_WORLD")
Skada_Skin:SetScript("OnEvent", function(self)
  self:UnregisterAllEvents()
  self = nil
  ChopsuiSkadaPositionWindows()
end)	

-- Event callback for OnShow event in Skada windows
function ChopsuiDisplaySkada()
  Skada:SetActive(true)
  --ChatFrame4:SetAlpha(0)
end

-- Event callback for OnHide event in Skada windows
function ChopsuiHideSkada()
  Skada:SetActive(false)
  --ChatFrame4:SetAlpha(1)
end

-- Position the Skada windows
function ChopsuiSkadaPositionWindows()

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
function ChopsuiSkadaReset()

  local chatBackground = _G["TukuiChatBackgroundLeft"]

-- Switch the Skada profile to a character specific profile
  local skadaProfile = UnitName("player") .. " - " .. GetRealmName()
  Skada.db:SetProfile(skadaProfile)
  
  -- Reset Skada windows
  Skada.db.profile.windows = {}

  -- Figure out the proper size of the Skada windows
  local panelWidth = chatBackground:GetWidth() - 22
  local panelHeight = chatBackground:GetHeight() - 73
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
    Skada.db.profile.windows[i].enabletitle = true
    Skada.db.profile.windows[i].spark = false
  end

  skadaLeftWindow.mode = "Threat"
  skadaRightWindow.mode = "Damage"

end
