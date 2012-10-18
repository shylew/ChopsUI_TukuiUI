local T, C, L = unpack(Tukui)

local timerFrame = CreateFrame("Frame")

local function SendCountdownNotification(message)
  SendChatMessage(message, "RAID_WARNING")
end

local function StartCountdown(seconds, message)

  seconds = tonumber(seconds)

  if _G["BigWigs"] then
    SlashCmdList["BWCB_SHORTHAND"](seconds .. " " .. message)
  end

  SendCountdownNotification("Pulling in " .. seconds .. " seconds")

  local elapsedTime = 0
  local ticks = 0
  timerFrame:SetScript("OnUpdate", function(self, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime > 1 then

      ticks = ticks + 1
      if ticks >= seconds then
        SendCountdownNotification(message)
        timerFrame:SetScript("OnUpdate", nil)
      else
        SendCountdownNotification((seconds - ticks) .. " seconds...")
      end

      elapsedTime = 0

    end
  end)

end

SLASH_PULLTIMER1 = "/pulltimer"
SlashCmdList["PULLTIMER"] = function(data)
  local seconds, message = data:match("^(%S*)%s*(.-)$");
  StartCountdown(seconds, message)
end
