local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
assert(Ellipsis, "ChopsUI Ellipsis extension failed to load, make sure Ellipsis is enabled")

-- Enable debuff tracking if we're on a dot class
if (T.Role == "Caster" and not (T.Spec == "HOLY" or T.Spec == "RESTORATION" or T.Spec == "DISCIPLINE")) then
  Ellipsis.db.profile["trackDebuffs"] = true
else
  Ellipsis.db.profile["trackDebuffs"] = false
end

-- Reposition the Ellipsis target frame
EllipsisTargets:SetMovable(false)
EllipsisTargets:SetPoint("BOTTOMLEFT", TukuiTarget, "TOPLEFT", 150, 145)

function ChopsuiEllipsisReset()

  -- Reset the profile
  local ellipsisProfile = UnitName("player") .. " - " .. GetRealmName()
  Ellipsis.db:SetProfile(ellipsisProfile)
  Ellipsis.db:ResetProfile()

  -- Set display options
  Ellipsis.db.profile["lock"] = true
  Ellipsis.db.profile["width"] = 250
  Ellipsis.db.profile["targetPadding"] = 7
  Ellipsis.db.profile["targetFont"] = "TukuiNormalFont"
  Ellipsis.db.profile["growTargets"] = "UP"
  Ellipsis.db.profile["texture"] = "TukuiNormalTexture"
  Ellipsis.db.profile["timerFont"] = "TukuiNormalFont"
  Ellipsis.db.profile["timerFontHeight"] = 12
  Ellipsis.db.profile["barHeight"] = 18

  -- Set aura tracking options
  Ellipsis.db.profile["trackBuffs"] = false
  Ellipsis.db.profile["trackDebuffs"] = false
  Ellipsis.db.profile["trackPlayer"] = false
  Ellipsis.db.profile["trackPet"] = false

  -- Set cooldown tracking options
  Ellipsis.db.profile["cdSpell"] = false
  Ellipsis.db.profile["cdPet"] = false
  Ellipsis.db.profile["cdItem"] = false
  Ellipsis.db.profile["cdHideWhenNone"] = true
  
end
