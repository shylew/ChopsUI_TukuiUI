local T, C, L = unpack(Tukui)
ChopsUI.RegisterModule("ellipsis", Ellipsis)

-- Reposition the Ellipsis target frame
EllipsisTargets:SetMovable(false)
EllipsisTargets:SetPoint("BOTTOMLEFT", TukuiTarget, "TOPLEFT", 150, 145)

function ChopsUI.modules.ellipsis.Reset()

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

  -- Set aura tracking options. We only track debuffs, and only if you're a caster.
  Ellipsis.db.profile["trackBuffs"] = false
  if (T.Role == "Caster") then
    Ellipsis.db.profile["trackDebuffs"] = true
  else
    Ellipsis.db.profile["trackDebuffs"] = false
  end
  Ellipsis.db.profile["trackPlayer"] = false
  Ellipsis.db.profile["trackPet"] = false

  -- Set cooldown tracking options
  Ellipsis.db.profile["cdSpell"] = false
  Ellipsis.db.profile["cdPet"] = false
  Ellipsis.db.profile["cdItem"] = false
  Ellipsis.db.profile["cdHideWhenNone"] = true

end
