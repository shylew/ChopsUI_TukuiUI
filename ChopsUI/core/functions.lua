local T, C, L = unpack(Tukui)

local classTalentMap = {
  ["DEATHKNIGHT"] = { "BLOOD", "FROST", "UNHOLY" },
  ["DRUID"] = { "BALANCE", "FERALCOMBAT", "RESTORATION" },
  ["HUNTER"] = { "BEASTMASTERY", "MARKSMANSHIP", "SURVIVAL" },
  ["MAGE"] = { "ARCANE", "FIRE", "FROST" },
  ["PALADIN"] = { "HOLY", "PROTECTION", "RETRIBUTION" },
  ["PRIEST"] = { "DISCIPLINE", "HOLY", "SHADOW" },
  ["ROGUE"] = { "ASSASSINATION", "COMBAT", "SUBTLETY" },
  ["SHAMAN"] = { "ELEMENTAL", "ENHANCEMENT", "RESTORATION" },
  ["WARLOCK"] = { "AFFLICTION", "DEMONOLOGY", "DESTRUCTION" },
  ["WARRIOR"] = { "ARMS", "FURY", "PROTECTION" }
}

-- Check the players spec.
local SpecCheckFrame = CreateFrame("Frame")
local function CheckSpec(self, event, unit)

  local tree = GetPrimaryTalentTree()

  spec = "UNKNOWN"
  talentTree = 1

  if tree then
    spec = classTalentMap[T.myclass][tree]
    talentTree = tree
  end

  T.Spec = spec
  T.TalentTree = talentTree

end

SpecCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
SpecCheckFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
SpecCheckFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
SpecCheckFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
SpecCheckFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
SpecCheckFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
SpecCheckFrame:SetScript("OnEvent", CheckSpec)
CheckSpec()
