local T, C, L, G = unpack(Tukui)

local filtered_errors = {
  [ERR_ITEM_COOLDOWN] = true,
  [ERR_SPELL_COOLDOWN] = true,
  [ERR_OUT_OF_ENERGY] = true,
  [ERR_OUT_OF_FOCUS] = true,
  [ERR_OUT_OF_MANA] = true,
  [ERR_OUT_OF_RAGE] = true,
  [ERR_OUT_OF_RANGE] = true,
  [ERR_NO_ATTACK_TARGET] = true,
  [ERR_ABILITY_COOLDOWN] = true,
  [ERR_CLIENT_LOCKED_OUT] = true,
  [ERR_BADATTACKPOS] = true,
  [SPELL_FAILED_SPELL_IN_PROGRESS] = true,
  ["Not enough Chi"] = true -- FIXME: Find the translation key for this one
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("UI_ERROR_MESSAGE")
UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
frame:SetScript("OnEvent", function(self, event, error)
  if filtered_errors[error] == nil then
    UIErrorsFrame:AddMessage(error, 1, 0 ,0)
  end
end)
