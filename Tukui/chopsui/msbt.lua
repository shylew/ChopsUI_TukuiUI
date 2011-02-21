------------------------------------------------------------------------------
-- CONFIGURE MSBT
------------------------------------------------------------------------------
function ChopsuiMSBTConfigure()
end

------------------------------------------------------------------------------
-- RESET MSBT
------------------------------------------------------------------------------
function ChopsuiMSBTReset()

  local mikProfile = MikSBT["Profiles"]

  -- Switch the MSBT profile to a character specific profile
  local msbtProfile = UnitName("player") .. " - " .. GetRealmName()

  -- Switch to a character specific MSBT profile
  mikProfile.DeleteProfile(msbtProfile)
  mikProfile.CopyProfile("Default", msbtProfile)
  mikProfile.SelectProfile(msbtProfile)

  -- Reset the current MSBT profile
  mikProfile.ResetProfile(msbtProfile)

  -- Set the new master fonts settings
  mikProfile.SetOption(nil, "critFontAlpha", 75)
  mikProfile.SetOption(nil, "critFontName", "TelUI Font")
  mikProfile.SetOption(nil, "critFontSize", 19)
  mikProfile.SetOption(nil, "critOutlineIndex", 3)
  mikProfile.SetOption(nil, "normalFontAlpha", 75)
  mikProfile.SetOption(nil, "normalFontName", "TelUI Font")
  mikProfile.SetOption(nil, "normalFontSize", 15)
  mikProfile.SetOption(nil, "normalOutlineIndex", 2)

  -- Set some general settings
  mikProfile.SetOption(nil, "hideFullHoTOverheals", false)

  -- Disable outgoing heals (we show those using the built in combat text)
  mikProfile.SetOption("events.OUTGOING_HOT", "disabled", true)
  mikProfile.SetOption("events.OUTGOING_HOT_CRIT", "disabled", true)
  mikProfile.SetOption("events.OUTGOING_HEAL", "disabled", true)
  mikProfile.SetOption("events.OUTGOING_HEAL_CRIT", "disabled", true)

  -- Set up the scroll areas
  mikProfile.SetOption("scrollAreas.Static", "disabled", true)
  mikProfile.SetOption("scrollAreas.Notification", "disabled", true)
  mikProfile.SetOption("scrollAreas.Outgoing", "disabled", true)
  mikProfile.SetOption("scrollAreas.Incoming", "behavior", "MSBT_NORMAL")
  mikProfile.SetOption("scrollAreas.Incoming", "animationStyle", "Straight")
  mikProfile.SetOption("scrollAreas.Incoming", "offsetX", (TukuiDB.Scale(340) * -1))
  mikProfile.SetOption("scrollAreas.Outgoing", "behavior", "MSBT_NORMAL")
  mikProfile.SetOption("scrollAreas.Outgoing", "animationStyle", "Straight")
  mikProfile.SetOption("scrollAreas.Outgoing", "offsetX", TukuiDB.Scale(300))
  
end
