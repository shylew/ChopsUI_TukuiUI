------------------------------------------------------------------------------
-- CONFIGURE SKADA
------------------------------------------------------------------------------
function ChopsuiSkadaConfigure()
end

------------------------------------------------------------------------------
-- RESET SKADA
------------------------------------------------------------------------------
function ChopsuiSkadaReset()

  local rightChatBackground = _G["ChopsuiChatBackgroundRight"]

  -- Switch the Skada profile to a character specific profile
  local skadaProfile = UnitName("player") .. " - " .. GetRealmName()
  Skada.db:SetProfile(skadaProfile)
  
  -- Reset Skada windows
  Skada.db.profile.windows = {}

  -- Figure out the size of the right chat frame and base our Skada windows on that
  local panelWidth = rightChatBackground:GetWidth() - TukuiDB.Scale(17)
  local panelHeight = rightChatBackground:GetHeight() - TukuiDB.Scale(17)

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
  skadaDpsWindow.set = "current"
  skadaDpsWindow.mode = "Damage"
  skadaDpsWindow.barwidth = windowWidth
  skadaDpsWindow.barheight = barHeight
  skadaDpsWindow.barmax = maxBars
  skadaDpsWindow.barslocked = false
  skadaDpsWindow.enabletitle = false
  skadaDpsWindow.spark = false

  -- Create a new window and position that to the left of the first window
  Skada:CreateWindow("Threat")
  local skadaThreatWindow = Skada.db.profile.windows[2]
  skadaThreatWindow.set = "current"
  skadaThreatWindow.mode = "Threat"
  if TukuiDB.myrole == "healer" then
    skadaThreatWindow.mode = "Healing"
  end
  skadaThreatWindow.barwidth = windowWidth
  skadaThreatWindow.barheight = barHeight
  skadaThreatWindow.barmax = maxBars
  skadaThreatWindow.barslocked = false
  skadaThreatWindow.enabletitle = false
  skadaThreatWindow.spark = false

end
