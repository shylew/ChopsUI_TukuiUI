local L = LibStub('AceLocale-3.0'):GetLocale('Ellipsis')
local Media = LibStub('LibSharedMedia-3.0')

do
	local function OnDragStart(drag)
		drag:StartMoving()
	end

	local function OnDragStop(drag)
		drag:StopMovingOrSizing()
	end

	function Ellipsis:InitializeGUI()
		local f

		-- create target anchor
		f = CreateFrame('Frame', 'EllipsisTargets', UIParent)
		self.targetAnchor = f
		f:SetScript('OnDragStart', OnDragStart)
		f:SetScript('OnDragStop', OnDragStop)
		f:SetHeight(10)
		f:SetWidth(150)
		f:SetClampedToScreen(true)
		f:SetMovable(true)
		f:SetPoint('CENTER', UIParent, 'CENTER')
		f.dragTex = f:CreateTexture(nil, 'BORDER')
		f.dragTex:SetAllPoints()
		f.dragTex:SetTexture(0.5, 0.5, 1, 0.5)
		f.dragStr = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
		f.dragStr:SetPoint('TOPLEFT', 0, 1)
		f.dragStr:SetPoint('BOTTOMRIGHT', 0, 1)
		f.dragStr:SetText(L.Targets)

		-- create prominent target anchor
		f = CreateFrame('Frame', 'EllipsisProminentTargets', UIParent)
		self.prominenceAnchor = f
		f:SetScript('OnDragStart', OnDragStart)
		f:SetScript('OnDragStop', OnDragStop)
		f:SetHeight(10)
		f:SetWidth(150)
		f:SetClampedToScreen(true)
		f:SetMovable(true)
		f:SetPoint('CENTER', UIParent, 'CENTER', 0, -20)
		f.dragTex = f:CreateTexture(nil, 'BORDER')
		f.dragTex:SetAllPoints()
		f.dragTex:SetTexture(0.5, 0.5, 1, 0.5)
		f.dragStr = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
		f.dragStr:SetPoint('TOPLEFT', 0, 1)
		f.dragStr:SetPoint('BOTTOMRIGHT', 0, 1)
		f.dragStr:SetText(L.Prominence)

		-- create cooldown anchor
		f = CreateFrame('Frame', 'EllipsisCooldowns', UIParent)
		self.cooldownAnchor = f
		f:SetScript('OnDragStart', OnDragStart)
		f:SetScript('OnDragStop', OnDragStop)
		f:SetHeight(10)
		f:SetWidth(150)
		f:SetClampedToScreen(true)
		f:SetMovable(true)
		f:SetPoint('CENTER', UIParent, 'CENTER', 0, -60)
		f:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true, tileSize = 16,
			edgeSize = 6,
			insets = {left = 1, right = 1, top = 1, bottom = 1}
		})
		f.bar = f:CreateTexture(nil, 'BORDER')
		f.bar:SetPoint('TOPLEFT', 2, -2)
		f.bar:SetPoint('BOTTOMRIGHT', -2, 2)
		f.timeScale = CreateFrame('Frame', nil, f)
		f.timeScale:SetFrameLevel(f.timeScale:GetFrameLevel() + 1)
		f.timeScale:SetAllPoints(f)
	end
end

local function ConfigureDragFrame(frame, canDrag, dragTex)
	if (canDrag) then
		if (dragTex) then
			frame.dragTex:Show()
			frame.dragStr:Show()
		end
		frame:EnableMouse(true)
		frame:RegisterForDrag('LeftButton')

	else
		if (dragTex) then
			frame.dragTex:Hide()
			frame.dragStr:Hide()
		end
		frame:EnableMouse(false)
		frame:RegisterForDrag(nil)
	end
end

function Ellipsis:ConfigureAnchors()
	local canDrag = not self.db.profile.lock
	ConfigureDragFrame(self.targetAnchor, canDrag, true)
	ConfigureDragFrame(self.prominenceAnchor, canDrag, true)
	ConfigureDragFrame(self.cooldownAnchor, canDrag, false)
	-- timer
	self.targetAnchor:SetAlpha(self.db.profile.auraAlpha)
	self.targetAnchor:SetScale(self.db.profile.auraScale)
	self.targetAnchor:SetWidth(self.db.profile.width)
	-- prominence
	self.prominenceAnchor:SetAlpha(self.db.profile.auraAlpha)
	self.prominenceAnchor:SetScale(self.db.profile.auraScale)
	self.prominenceAnchor:SetWidth(self.db.profile.width)
	-- cooldown
	self.cooldownAnchor:SetAlpha(self.db.profile.cdAlpha)
	self.cooldownAnchor:SetScale(self.db.profile.cdScale)
	self:ConfigureCooldownBase()
end

-- TARGET GUI FUNCTIONS -----------------------------------

local unusedTargets = {}

function Ellipsis:GetTargetFrame()
	local t = next(unusedTargets)

	if (t) then
		unusedTargets[t] = nil
		return t
	else
		t = CreateFrame('Frame', nil, self.targetAnchor)

		t.guid = 0
		t.name = ''
		t.level = 0
		t.class = 'WARRIOR'
		t.created = 0
		t.hidden = false
		t.prominent = false
		t.raidicon = 0 -- no icon
		t.timers = {}
		t.sortedTimers = {}

		t.title = t:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
		t.title:SetPoint('TOPLEFT', t, 'TOPLEFT')
		t.title:SetPoint('TOPRIGHT', t, 'TOPRIGHT')
		t.title:SetJustifyH('CENTER')
		t.title:SetJustifyV('TOP')

		self:ApplyTargetSettings(t)

		return t
	end
end

function Ellipsis:ReleaseTargetFrame(t)
	t:Hide()
	unusedTargets[t] = true
end

local levelIconName = '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t[%s] %s'
local iconName = '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t%s'
local levelName = '[%s] %s'
local name = '%s'

function Ellipsis:SetTargetText(t)
	if (self.db.profile.showLevel and t.level ~= 0) then
		if (self.db.profile.showRaidIcons and t.raidicon ~= 0) then
			t.title:SetFormattedText(levelIconName, t.raidicon, t.level, t.name)
		else
			t.title:SetFormattedText(levelName, t.level, t.name)
		end
	else
		if (self.db.profile.showRaidIcons and t.raidicon ~= 0) then
			t.title:SetFormattedText(iconName, t.raidicon, t.name)
		else
			t.title:SetFormattedText(name, t.name)
		end
	end
end

function Ellipsis:SetTargetTextColour(t)
	if (self.db.profile.showClassColours) then
		t.title:SetTextColor(RAID_CLASS_COLORS[t.class].r, RAID_CLASS_COLORS[t.class].g, RAID_CLASS_COLORS[t.class].b)
	else
		t.title:SetTextColor(unpack(self.db.profile.colours.targettext))
	end
end

function Ellipsis:ApplyTargetSettings(t)
	t.title:SetHeight(self.db.profile.targetFontHeight + 4)
	t.title:SetFont(Media:Fetch('font', self.db.profile.targetFont), self.db.profile.targetFontHeight)

	self:SetTargetTextColour(t)
end

do
	local anchor, anchorRel, vertical, vertUp, horzLeft, padding
	local showTargetOnly, showFocusOnly, playerGUID, trackPlayer, trackPet, showNumTargets

	local alwaysShow = {}
	local numTargets, mustShow, numToShow = 0, 0, 0

	local function CalculateNumShownTargets(targets, targetGUID, focusGUID)
		numTargets, mustShow = #targets, 0

		for k, v in pairs(alwaysShow) do alwaysShow[k] = nil end -- clear out table

		alwaysShow['notarget'] = true

		if (trackPlayer) then alwaysShow[playerGUID] = true end
		if (trackPet and UnitExists('pet')) then alwaysShow[UnitGUID('pet')] = true end

		for x = 1, min(3, numTargets) do
			if (alwaysShow[targets[x].guid]) then
				alwaysShow[targets[x].guid] = nil
				mustShow = mustShow + 1
			end
		end

		if ((not showTargetOnly and not showFocusOnly) or numTargets <= mustShow) then
			-- either not 'only' showing target or focus, or the only entries are mustshows anyhow, return
			return min(mustShow + showNumTargets, numTargets)
		end

		-- showing only focus and/or target and there are more entries than the mustShows above
		if (showTargetOnly) then alwaysShow[targetGUID] = true end
		if (showFocusOnly) then alwaysShow[focusGUID] = true end

		for x = mustShow + 1, min(mustShow + 3, numTargets) do
			if (alwaysShow[targets[x].guid]) then
				alwaysShow[targets[x].guid] = nil
				mustShow = mustShow + 1
			end
		end

		return mustShow -- we only show the mustShows if we got this far
	end

	local function ShowTimers(target)
		if (target.hidden) then
			target.hidden = false
			for _, v in pairs(target.sortedTimers) do v:Show() end
		end
	end

	local function HideTimers(target)
		if (not target.hidden) then
			target.hidden = true
			for _, v in pairs(target.sortedTimers) do v:Hide() end
		end
	end

	function Ellipsis:AnchorTargets(targets, mainAnchor, targetGUID, focusGUID)
		if (#targets < 1) then return end

		numToShow = CalculateNumShownTargets(targets, targetGUID, focusGUID)

		if (numToShow > 0) then -- could be zero if showing only focus/target and no special entries
			targets[1]:ClearAllPoints()
			targets[1]:Show()
			ShowTimers(targets[1])

			if (vertical) then
				targets[1]:SetPoint(anchor, mainAnchor, anchor)

				if (numToShow > 1) then
					for x = 2, numToShow do
						targets[x]:ClearAllPoints()
						targets[x]:SetPoint(anchor, targets[x - 1], anchorRel, 0, vertUp and padding or -(padding))
						targets[x]:Show()
						ShowTimers(targets[x])
					end
				end
			else
				targets[1]:SetPoint('TOP', mainAnchor, 'TOP')

				if (numToShow > 1) then
					for x = 2, numToShow do
						targets[x]:ClearAllPoints()
						targets[x]:SetPoint(anchor, targets[x - 1], anchorRel, horzLeft and -(padding) or padding, 0)
						targets[x]:Show()
						ShowTimers(targets[x])
					end
				end
			end
		end

		if (#targets > numToShow) then
			for x = numToShow + 1, #targets do
				targets[x]:Hide()
				HideTimers(targets[x])
			end
		end
	end

	function Ellipsis:ConfigureTargetAnchors()
		local growTargets = self.db.profile.growTargets

		if (growTargets == 'UP' or growTargets == 'DOWN') then
			anchor = (growTargets == 'UP') and 'BOTTOM' or 'TOP'
			anchorRel = (growTargets == 'UP') and 'TOP' or 'BOTTOM'
			vertical = true
			vertUp = (growTargets == 'UP') and true or false
		else
			anchor = (growTargets == 'LEFT') and 'TOPRIGHT' or 'TOPLEFT'
			anchorRel = (growTargets == 'LEFT') and 'TOPLEFT' or 'TOPRIGHT'
			vertical = false
			horzLeft = (growTargets == 'LEFT') and true or false
		end

		padding = self.db.profile.targetPadding
		showTargetOnly = self.db.profile.showTargetOnly
		showFocusOnly = self.db.profile.showFocusOnly
		trackPlayer = self.db.profile.trackPlayer
		trackPet = self.db.profile.trackPet
		showNumTargets = self.db.profile.showNumTargets
		if (not playerGUID) then playerGUID = self.playerGUID end
	end
end

-- TIMER GUI FUNCTIONS ------------------------------------

local unusedTimers = {}
local auraClickColor

local function TimerOnEnter(frame)
	if (Ellipsis.db.profile.tooltips) then
		GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
		GameTooltip:SetText(frame.spell, 1, 0.82, 0, 1)

		auraClickColor = Ellipsis.db.profile.clickable and 1 or 0.5

		GameTooltip:AddLine(L.LeftClickToAnnounce, auraClickColor, auraClickColor, auraClickColor, 1)
		GameTooltip:AddLine(L.RightClickToCancel, auraClickColor, auraClickColor, auraClickColor, 1)
		GameTooltip:AddLine(L.ShiftRightClickToBlock, auraClickColor, auraClickColor, auraClickColor, 1)
		if (frame.totemType) then GameTooltip:AddLine(L.CtrlRightClickToDestroyTotem, auraClickColor, auraClickColor, auraClickColor, 1) end

		GameTooltip:Show()
	end
end

local function TimerOnLeave()
	GameTooltip:Hide()
end

function Ellipsis:GetTimerFrame()
	local t = next(unusedTimers)

	if (t) then
		unusedTimers[t] = nil
		return t
	else
		t = CreateFrame('Button', nil, self.targetAnchor)
		t:SetScript('OnEnter', TimerOnEnter)
		t:SetScript('OnLeave', TimerOnLeave)
		t:SetScript('OnClick', self.TimerOnClick)

		t.start = 0
		t.finish = 0
		t.spell = ''
		t.count = 0 -- for stackable (de)buffs
		t.guid = 0 -- parent reference
		t.valid = 0 -- last validation time
		t.totemType = false
		t.ghost = false

		t.icon = t:CreateTexture(nil, 'BORDER')
		t.icon:SetPoint('TOPLEFT', t, 'TOPLEFT')
		t.icon:SetPoint('BOTTOMLEFT', t, 'BOTTOMLEFT')

		t.stack = t:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
		t.stack:SetPoint('BOTTOMRIGHT', t.icon, 'BOTTOMRIGHT', -1.5, 1.5)
		t.stack:SetTextHeight(10)

		t.border = t:CreateTexture(nil, 'ARTWORK')
		t.border:SetPoint('TOPLEFT', t.icon, 'TOPLEFT')
		t.border:SetPoint('BOTTOMRIGHT', t.icon, 'BOTTOMRIGHT')
		t.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
		t.border:SetTexture('Interface\\Buttons\\UI-Debuff-Overlays')

		t.bar = CreateFrame('StatusBar', nil, t)
		t.bar:SetPoint('TOPRIGHT', t, 'TOPRIGHT')
		t.bar:SetPoint('BOTTOMRIGHT', t, 'BOTTOMRIGHT')
		t.bar:SetFrameLevel(t.bar:GetFrameLevel() - 1) -- ensure its 'behind' the frame with its text
		t.bar:SetMinMaxValues(0, 1)

		t.bg = t.bar:CreateTexture(nil, 'BACKGROUND')
		t.bg:SetAllPoints()

		t.spark = t.bar:CreateTexture(nil, 'OVERLAY')
		t.spark:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark')
		t.spark:SetVertexColor(1, 1, 1, 0.5)
		t.spark:SetBlendMode('ADD')
		t.spark:SetWidth(16)

		t.name = t:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
		t.name:SetPoint('LEFT', t.bar, 'LEFT', 3, 0)
		t.name:SetJustifyH('LEFT')
		t.name:SetJustifyV('MIDDLE')

		t.time = t:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
		t.time:SetJustifyV('MIDDLE')

		self:ApplyTimerSettings(t)

		return t
	end
end

function Ellipsis:ReleaseTimerFrame(t)
	t:Hide()
	unusedTimers[t] = true
end

function Ellipsis:ApplyTimerSettings(t)
	t:SetWidth(self.db.profile.width)

	t.name:SetFont(Media:Fetch('font', self.db.profile.timerFont), self.db.profile.timerFontHeight)
	t.time:SetFont(Media:Fetch('font', self.db.profile.timerFont), self.db.profile.timerFontHeight)

	if (self.db.profile.clickable) then
		t:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	else
		t:RegisterForClicks(nil)
	end

	if (self.db.profile.mode == 'bars') then
		local barHeight = self.db.profile.barHeight

		t:SetHeight(barHeight)
		t.icon:SetWidth(barHeight)

		t.name:SetHeight(barHeight)
		t.name:SetTextColor(unpack(self.db.profile.colours.timertext))
		t.name:Show()

		t.time:SetPoint('RIGHT', t.bar, 'RIGHT', -3, 0)
		t.time:SetHeight(barHeight)
		t.time:SetTextColor(unpack(self.db.profile.colours.timertext))
		t.time:SetJustifyH('RIGHT')

		t.spark:SetHeight(barHeight * 1.8)
		t.bg:SetTexture(Media:Fetch('statusbar', self.db.profile.texture))
		t.bg:SetVertexColor(unpack(self.db.profile.colours.background))

		t.bar:SetWidth(self.barWidth)
		t.bar:SetStatusBarTexture(Media:Fetch('statusbar', self.db.profile.texture))
		t.bar:Show()
	elseif (self.db.profile.mode == 'icons') then
		local iconHeight = self.db.profile.iconHeight

		t:SetHeight(iconHeight)
		t.icon:SetWidth(iconHeight)

		t.bar:Hide() -- hides associated spark, bg
		t.name:Hide()

		t.time:SetPoint('LEFT', t.icon, 'RIGHT', 5, 0)
		t.time:SetHeight(iconHeight)
		t.time:SetJustifyH('LEFT')
	end
end

do
	local anchor, anchorRel, vertical, horzLeft, padding, height, width, infoHeight

	function Ellipsis:AnchorTimersAndSizeTarget(target, timers)
		if (#timers < 1) then return end

		timers[1]:ClearAllPoints()
		timers[1]:SetPoint('TOP', target.title, 'BOTTOM', 0, -(padding))

		if (vertical) then
			for x = 2, #timers do
				timers[x]:ClearAllPoints()
				timers[x]:SetPoint(anchor, timers[x - 1], anchorRel, 0, -(padding))
			end

			target:SetHeight(infoHeight + (#timers * (height + padding)))
			target:SetWidth(width)
		else
			for x = 2, #timers do
				timers[x]:ClearAllPoints()
				timers[x]:SetPoint(anchor, timers[x - 1], anchorRel, horzLeft and -(padding) or padding, 0)
			end

			target:SetHeight(infoHeight + height + padding)
			target:SetWidth(#timers * (width + padding))
		end
	end

	function Ellipsis:ConfigureTimerAnchorsAndSize()
		local growTimers = self.db.profile.growTimers

		if (growTimers == 'DOWN') then
			anchor = (growTimers == 'UP') and 'BOTTOM' or 'TOP'
			anchorRel = (growTimers == 'UP') and 'TOP' or 'BOTTOM'
			vertical = true
		else
			anchor = (growTimers == 'LEFT') and 'TOPRIGHT' or 'TOPLEFT'
			anchorRel = (growTimers == 'LEFT') and 'TOPLEFT' or 'TOPRIGHT'
			vertical = false
			horzLeft = (growTimers == 'LEFT') and true or false
		end

		padding = self.db.profile.timerPadding
		height = (self.db.profile.mode == 'bars' and self.db.profile.barHeight) or self.db.profile.iconHeight
		width = self.db.profile.width
		infoHeight = self.db.profile.targetFontHeight + 4
	end
end

-- COOLDOWN TIMER GUI FUNCTIONS ---------------------------

local unusedCDTimers = {}
local cdClickColor

local function CDTimerOnEnter(frame)
	if (Ellipsis.db.profile.tooltips) then
		local remains = floor(frame.finish - GetTime())
		local min, sec = floor(remains / 60), mod(remains, 60)

		GameTooltip:SetOwner(frame, 'ANCHOR_RIGHT')
		GameTooltip:SetText(frame.spell, 1, 0.82, 0, 1)
		if (remains > 0) then GameTooltip:AddLine(format(L.TimeRemaining, min, sec), 1, 1, 1, 1) end
		GameTooltip:AddLine(' ', 1, 1, 1, 1)

		cdClickColor = Ellipsis.db.profile.clickable and 1 or 0.5

		GameTooltip:AddLine(L.LeftClickToAnnounce, cdClickColor, cdClickColor, cdClickColor, 1)
		GameTooltip:AddLine(L.ShiftRightClickToBlock, cdClickColor, cdClickColor, cdClickColor, 1)

		GameTooltip:Show()
	end
end

function Ellipsis:GetCDTimerFrame()
	local t = next(unusedCDTimers)

	if (t) then
		unusedCDTimers[t] = nil
		return t
	else
		t = CreateFrame('Button', nil, self.cooldownAnchor)
		t:SetScript('OnEnter', CDTimerOnEnter)
		t:SetScript('OnLeave', TimerOnLeave)
		t:SetScript('OnClick', self.CooldownTimerOnClick)

		t.start = 0
		t.finish = 0
		t.spell = ''
		t.valid = 0
		t.cdType = -1
		t.offset = 0
		t.inPulse = false

		t.icon = t:CreateTexture(nil, 'OVERLAY')
		t.icon:SetAllPoints()
		t.icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)

		t.tag = t:CreateTexture(nil, 'BORDER')
		t.tag:SetHeight(1)
		t.tag:SetWidth(1)

		self:ApplyCDTimerSettings(t)

		return t
	end
end

function Ellipsis:ReleaseCDTimerFrame(t)
	t:Hide()
	unusedCDTimers[t] = true
end

function Ellipsis:ApplyCDTimerSettings(t)
	if (self.db.profile.clickable) then
		t:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	else
		t:RegisterForClicks(nil)
	end

	if (not t.inPulse) then -- if not pulsing, set height and width
		t:SetHeight(self.db.profile.cdThickness)
		t:SetWidth(self.db.profile.cdThickness)
	end
end

function Ellipsis:ConfigureCDTag(t)
	t.offset = self.db.profile['cdOffset' .. mod(t.cdType, 4)] or 0 -- the mod is a hacky way to make 'sample' timers work

	if (t.offset == 0 or not self.db.profile.cdShowOffsetTags) then
		t.tag:Hide()
		return
	end

	t.tag:ClearAllPoints()
	t.tag:SetTexture(unpack(self.db.profile.colours['cd' .. mod(t.cdType, 4)]))
	t.tag:Show()

	if (self.db.profile.cdHorizontal) then
		t.tag:SetPoint('TOP', t.icon, 'CENTER', 0, (t.offset < 0 and -(t.offset)) or 0)
		t.tag:SetPoint('BOTTOM', t.icon, 'CENTER', 0, (t.offset > 0 and -(t.offset)) or 0)
	else
		t.tag:SetPoint('LEFT', t.icon, 'CENTER', (t.offset > 0 and -(t.offset)) or 0, 0)
		t.tag:SetPoint('RIGHT', t.icon, 'CENTER', (t.offset < 0 and -(t.offset)) or 0, 0)
	end
end

-- COOLDOWN CONFIG ----------------------------------------

local times = {0, 10, 60, 300, 900, 1800, 3600}
local timesDetail = {0, 2, 10, 30, 60, 120, 300, 600, 900, 1200, 1500, 1800, 2700, 3600}
local timeTags = {}

function Ellipsis:ConfigureCooldownBase()
	local cda = self.cooldownAnchor

	local maxTime = self.db.profile.cdMaxTimeDisplay
	local endCap = (self.db.profile.cdThickness / 2)
	local workingLength = self.db.profile.cdLength - (endCap * 2)
	local displayList = self.db.profile.cdTimeDetail and timesDetail or times
	local horz = self.db.profile.cdHorizontal
	local loc

	-- 'Clear' current time tags
	for x = 1, #timeTags do
		timeTags[x]:Hide()
	end

	-- Setup time display
	for k, v in ipairs(displayList) do
		if (v <= maxTime) then
			if (not timeTags[k]) then
				timeTags[k] = cda.timeScale:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
			end

			loc = math.pow(v / maxTime, 0.4) * workingLength

			timeTags[k]:ClearAllPoints()
			timeTags[k]:SetFont(Media:Fetch('font', 'Blizzard'), self.db.profile.cdFontHeight)
			timeTags[k]:SetTextColor(unpack(self.db.profile.colours.cdtext))
			timeTags[k]:Show()

			if (loc == workingLength) then
				timeTags[k]:SetPoint(horz and 'RIGHT' or 'TOP', cda.bar, horz and 'RIGHT' or 'TOP', horz and -1 or 0, horz and 0 or -1)
				timeTags[k]:SetText(format('%d+', v > 60 and v / 60 or v))
			else
				timeTags[k]:SetPoint('CENTER', cda.bar, horz and 'LEFT' or 'BOTTOM', horz and (endCap + loc) or 0, horz and 0 or (endCap + loc))
				timeTags[k]:SetText(v > 60 and v / 60 or v)
			end
		end
	end

	cda:SetBackdropColor(unpack(self.db.profile.colours.cdbackdrop))
	cda:SetBackdropBorderColor(unpack(self.db.profile.colours.cdborder))

	cda.bar:SetTexture(Media:Fetch('statusbar', self.db.profile.cdTexture))
	cda.bar:SetVertexColor(unpack(self.db.profile.colours.cdbar))

	if (horz) then
		cda:SetHeight(self.db.profile.cdThickness + 4)
		cda:SetWidth(self.db.profile.cdLength + 4)
		cda.bar:SetTexCoord(0, 1, 0, 1)
	else
		cda:SetHeight(self.db.profile.cdLength + 4)
		cda:SetWidth(self.db.profile.cdThickness + 4)
		cda.bar:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1)
	end
end

-- GUI UTILITY FUNCTIONS ----------------------------------

function Ellipsis:GetUnusedTargets() return unusedTargets end
function Ellipsis:GetUnusedTimers() return unusedTimers end
function Ellipsis:GetUnusedCDTimers() return unusedCDTimers end

function Ellipsis:MediaRegistration()
	-- Copied from Omen giving the same selection whether its installed or not
	Media:Register('sound', 'Rubber Ducky', [[Sound\Doodad\Goblin_Lottery_Open01.wav]])
	Media:Register('sound', 'Cartoon FX', [[Sound\Doodad\Goblin_Lottery_Open03.wav]])
	Media:Register('sound', 'Explosion', [[Sound\Doodad\Hellfire_Raid_FX_Explosion05.wav]])
	Media:Register('sound', 'Shing!', [[Sound\Doodad\PortcullisActive_Closed.wav]])
	Media:Register('sound', 'Wham!', [[Sound\Doodad\PVP_Lordaeron_Door_Open.wav]])
	Media:Register('sound', 'Simon Chime', [[Sound\Doodad\SimonGame_LargeBlueTree.wav]])
	Media:Register('sound', 'War Drums', [[Sound\Event Sounds\Event_wardrum_ogre.wav]])
	Media:Register('sound', 'Cheer', [[Sound\Event Sounds\OgreEventCheerUnique.wav]])
	Media:Register('sound', 'Humm', [[Sound\Spells\SimonGame_Visual_GameStart.wav]])
	Media:Register('sound', 'Short Circuit', [[Sound\Spells\SimonGame_Visual_BadPress.wav]])
	Media:Register('sound', 'Fel Portal', [[Sound\Spells\Sunwell_Fel_PortalStand.wav]])
	Media:Register('sound', 'Fel Nova', [[Sound\Spells\SeepingGaseous_Fel_Nova.wav]])

	-- Additional Choices (all in-game sounds)
	Media:Register('sound', 'PVP Enter Queue', [[Sound\Spells\PVPEnterQueue.wav]])
	Media:Register('sound', 'PVP Through Queue', [[Sound\Spells\PVPThroughQueue.wav]])
	Media:Register('sound', 'Level Up', [[Sound\interface\LevelUp.wav]])
	Media:Register('sound', 'Raid Warning', [[Sound\interface\RaidWarning.wav]])
end
