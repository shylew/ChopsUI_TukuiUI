local T, C, L, G = unpack(Tukui)

local classSpecializationMap = {
  ["DEATHKNIGHT"] = { "BLOOD", "FROST", "UNHOLY" },
  ["DRUID"] = { "BALANCE", "FERAL", "GUARDIAN", "RESTORATION" },
  ["HUNTER"] = { "BEASTMASTERY", "MARKSMANSHIP", "SURVIVAL" },
  ["MAGE"] = { "ARCANE", "FIRE", "FROST" },
  ["MONK"] = { "BREWMASTER", "MISTWEAVER", "WINDWALKER" },
  ["PALADIN"] = { "HOLY", "PROTECTION", "RETRIBUTION" },
  ["PRIEST"] = { "DISCIPLINE", "HOLY", "SHADOW" },
  ["ROGUE"] = { "ASSASSINATION", "COMBAT", "SUBTLETY" },
  ["SHAMAN"] = { "ELEMENTAL", "ENHANCEMENT", "RESTORATION" },
  ["WARLOCK"] = { "AFFLICTION", "DEMONOLOGY", "DESTRUCTION" },
  ["WARRIOR"] = { "ARMS", "FURY", "PROTECTION" }
}

-- Check the players spec.
local SpecializationCheckFrame = CreateFrame("Frame")
local function CheckSpecialization(self, event, unit)

  local spec = GetSpecialization()

  specName = "UNKNOWN"
  specId = 1

  if spec then
    specName = classSpecializationMap[T.myclass][spec]
    specId = spec
  end

  T.Spec = specName
  T.SpecId = specId

end

SpecializationCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
SpecializationCheckFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
SpecializationCheckFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
SpecializationCheckFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
SpecializationCheckFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
SpecializationCheckFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
SpecializationCheckFrame:SetScript("OnEvent", CheckSpecialization)
CheckSpecialization()
