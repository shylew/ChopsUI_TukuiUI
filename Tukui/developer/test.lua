local T, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

--------------------------------------------------------------------------
-- This code is for testing purpose
-- it reskin the all "Battleground" Timer bars.
--------------------------------------------------------------------------

-- for running a test dummy type in your chat the command below:
-- /run TimerTracker_OnLoad(TimerTracker); TimerTracker_OnEvent(TimerTracker, "START_TIMER", 1, 30, 30)

local function SkinIt(self)	
	local name = self:GetName()
	local bar = _G[name.."StatusBar"]

	bar:ClearAllPoints()
	bar:Point("TOPLEFT", self, "TOPLEFT", 2, -2)
	bar:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
		
	for i=1, bar:GetNumRegions() do
		local region = select(i, bar:GetRegions())
		if region:GetObjectType() == "Texture" then
			if not region:GetTexture() ~= C["media"].normTex then
				region:SetTexture(nil)
			end
		elseif region:GetObjectType() == "FontString" then
			region:SetFont(C["media"].font, 12, "THINOUTLINE")
		end
	end
	
	bar:SetStatusBarTexture(C["media"].normTex)
	bar:SetStatusBarColor(170/255, 10/255, 10/255)
	
	bar.backdrop = CreateFrame("Frame", nil, bar)
	bar.backdrop:SetFrameLevel(0)
	bar.backdrop:SetTemplate("Default")
	bar.backdrop:SetAllPoints(self)
end

local function SkinBlizzTimer(self, event, ...)
	if event == "START_TIMER" then
		local bar
		local isTimerRuning = false
		local timerType, timeSeconds, totalTime = ...

		for a,b in pairs(self.timerList) do
			if b.type == timerType and not b.isFree then
				bar = b
				isTimerRuning = true
				break
			end
		end
		
		if isTimerRuning then 
			for a,b in pairs(bar) do
				if not bar.isSkinned then
					SkinIt(bar)
					bar.IsSkinned = true
				end
			end
		end
	end
end

hooksecurefunc("TimerTracker_OnEvent", SkinBlizzTimer)