local T, C, L = unpack(Tukui)
ChopsUI.RegisterModule("postal", Postal)

function ChopsUI.modules.postal.Reset()

  local postalProfile = UnitName("player") .. " - " .. GetRealmName()
  Postal.db:SetProfile(postalProfile)
  Postal.db:ResetProfile()

  -- Set some Postal settings
  Postal.db.profile["OpenSpeed"] = 0.1
  Postal.db.profile["OpenAll"] = { ["KeepFreeSpace"] = 0 }
  
end
