local T, C, L = unpack(Tukui)

-- Disable the profanity filter properly since it keeps resetting itself all the
-- time after 4.3.

local f = CreateFrame('FRAME', 'ShitPissFuckCunt')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
local function eventHandler(self, event, ...)
	
	isOnline = BNConnected()
	if(isOnline) then
		BNSetMatureLanguageFilter(false)
	end
	
	SetCVar('profanityFilter', 0)

end
f:SetScript('OnEvent', eventHandler)
