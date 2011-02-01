-- hide filtered error messages

local db, f, o = TukuiCF["error"], CreateFrame("Frame"), tukuilocal.error_noerror
if not db.enable then return end

f:SetScript("OnEvent", function(self, event, error)
  if db.filter[error] then
    o = error
  else
    UIErrorsFrame:AddMessage(error, 1, 0 ,0)
  end
end)

SLASH_TUKUIERROR1 = "/error"
function SlashCmdList.TUKUIERROR() print(o) end

UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
f:RegisterEvent("UI_ERROR_MESSAGE")
