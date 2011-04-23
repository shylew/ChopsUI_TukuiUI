local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
assert(Postal, "ChopsUI Postal extension failed to load, make sure Postal is enabled")

function ChopsuiPostalReset()

  local postalProfile = UnitName("player") .. " - " .. GetRealmName()
  Postal.db:SetProfile(postalProfile)
  Postal.db:ResetProfile()

  -- Set some Postal settings
  Postal.db.profile["OpenSpeed"] = 0.1
  Postal.db.profile["OpenAll"] = { ["KeepFreeSpace"] = 0 }
  
end

