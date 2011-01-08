--------------------------------------------------------------------------------
-- Module Declaration
--

local plugin = BigWigs:NewPlugin("Bars")
if not plugin then return end

--------------------------------------------------------------------------------
-- Locals
--

local colorize = nil
do
	local r, g, b
	colorize = setmetatable({}, { __index =
		function(self, key)
			if not r then r, g, b = GameFontNormal:GetTextColor() end
			self[key] = "|cff" .. string.format("%02x%02x%02x", r * 255, g * 255, b * 255) .. key .. "|r"
			return self[key]
		end
	})
end

local L = LibStub("AceLocale-3.0"):GetLocale("Big Wigs: Plugins")

local colors = nil
local superemp = nil
local candy = LibStub("LibCandyBar-3.0")
local media = LibStub("LibSharedMedia-3.0")
local db = nil
local normalAnchor, emphasizeAnchor = nil, nil
local empUpdate = nil -- emphasize updater frame

--- custom bar locals
local times = nil
local messages = nil
local timers = nil

local clickHandlers = {}

--------------------------------------------------------------------------------
-- Options
--

plugin.defaultDB = {
	scale = 1.0,
	texture = "BantoBar",
	font = nil,
	growup = true,
	time = true,
	align = "LEFT",
	icon = true,
	emphasize = true,
	emphasizeFlash = true,
	emphasizeMove = true,
	emphasizeScale = 1.5,
	emphasizeGrowup = nil,
	BigWigsAnchor_width = 200,
	BigWigsEmphasizeAnchor_width = 300,
	interceptMouse = nil,
	onlyInterceptOnKeypress = nil,
	interceptKey = "CTRL",
	LeftButton = {
		report = true,
	},
	MiddleButton = {
		remove = true,
	},
	RightButton = {
		emphasize = true,
	},
}

local clickOptions = {
	emphasize = {
		type = "toggle",
		name = colorize[L["Super Emphasize"]],
		desc = L["Temporarily Super Emphasizes the bar and any messages associated with it for the duration."],
		descStyle = "inline",
		order = 1,
	},
	report = {
		type = "toggle",
		name = colorize[L["Report"]],
		desc = L["Reports the current bars status to the active group chat; either battleground, raid, party or guild, as appropriate."],
		descStyle = "inline",
		order = 2,
	},
	remove = {
		type = "toggle",
		name = colorize[L["Remove"]],
		desc = L["Temporarily removes the bar and all associated messages."],
		descStyle = "inline",
		order = 3,
	},
	removeOther = {
		type = "toggle",
		name = colorize[L["Remove other"]],
		desc = L["Temporarily removes all other bars (except this one) and associated messages."],
		descStyle = "inline",
		order = 4,
	},
	disable = {
		type = "toggle",
		name = colorize[L["Disable"]],
		desc = L["Permanently disables the boss encounter ability option that spawned this bar."],
		descStyle = "inline",
		order = 5,
	},
}

local function shouldDisable() return not plugin.db.profile.interceptMouse end

plugin.subPanelOptions = {
	key = "Big Wigs: Clickable Bars",
	name = L["Clickable Bars"],
	options = {
		name = L["Clickable Bars"],
		type = "group",
		childGroups = "tab",
		get = function(i) return plugin.db.profile[i[#i]] end,
		set = function(i, value)
			local key = i[#i]
			plugin.db.profile[key] = value
			if key == "interceptMouse" then
				plugin:RefixClickIntercepts()
			end
		end,
		args = {
			heading = {
				type = "description",
				name = L.clickableBarsDesc,
				order = 1,
				width = "full",
				fontSize = "medium",
			},
			interceptMouse = {
				type = "toggle",
				name = L["Enable"],
				desc = L["Enables bars to receive mouse clicks."],
				order = 2,
				width = "full",
			},
			onlyInterceptOnKeypress = {
				type = "toggle",
				name = L["Only with modifier key"],
				desc = L["Allows bars to be click-through unless the specified modifier key is held down, at which point the mouse actions described below will be available."],
				order = 3,
				disabled = shouldDisable,
			},
			interceptKey = {
				type = "select",
				name = L["Modifier"],
				desc = L["Hold down the selected modifier key to enable click actions on the timer bars."],
				values = {
					CTRL = CTRL_KEY_TEXT or "Ctrl",
					ALT = ALT_KEY or "Alt",
					SHIFT = SHIFT_KEY_TEXT or "Shift",
				},
				order = 4,
				disabled = function()
					return not plugin.db.profile.interceptMouse or not plugin.db.profile.onlyInterceptOnKeypress
				end,
			},
			left = {
				type = "group",
				name = KEY_BUTTON1 or "Left",
				order = 10,
				args = clickOptions,
				disabled = shouldDisable,
				get = function(info) return plugin.db.profile.LeftButton[info[#info]] end,
				set = function(info, value) plugin.db.profile.LeftButton[info[#info]] = value end,
			},
			middle = {
				type = "group",
				name = KEY_BUTTON3 or "Middle",
				order = 11,
				args = clickOptions,
				disabled = shouldDisable,
				get = function(info) return plugin.db.profile.MiddleButton[info[#info]] end,
				set = function(info, value) plugin.db.profile.MiddleButton[info[#info]] = value end,
			},
			right = {
				type = "group",
				name = KEY_BUTTON2 or "Right",
				order = 12,
				args = clickOptions,
				disabled = shouldDisable,
				get = function(info) return plugin.db.profile.RightButton[info[#info]] end,
				set = function(info, value) plugin.db.profile.RightButton[info[#info]] = value end,
			},
		},
	},
}

do
	local pluginOptions = nil
	function plugin:GetPluginConfig()
		if not pluginOptions then
			pluginOptions = {
				type = "group",
				get = function(info)
					local key = info[#info]
					if key == "texture" then
						for i, v in next, media:List("statusbar") do
							if v == db.texture then return i end
						end
					elseif key == "font" then
						for i, v in next, media:List("font") do
							if v == db.font then return i end
						end
					end
					return db[key]
				end,
				set = function(info, value)
					local key = info[#info]
					if key == "texture" then
						local list = media:List("statusbar")
						db.texture = list[value]
					elseif key == "font" then
						local list = media:List("font")
						db.font = list[value]
					else
						db[key] = value
					end
				end,
				args = {
					texture = {
						type = "select",
						name = L["Texture"],
						order = 1,
						values = media:List("statusbar"),
						width = "full",
						itemControl = "DDI-Statusbar",
					},
					font = {
						type = "select",
						name = L["Font"],
						order = 2,
						values = media:List("font"),
						width = "full",
						itemControl = "DDI-Font",
					},
					align = {
						type = "select",
						name = L["Align"],
						values = {
							LEFT = L["Left"],
							CENTER = L["Center"],
							RIGHT = L["Right"],
						},
						style = "radio",
						width = "half",
						order = 3,
					},
					icon = {
						type = "toggle",
						name = L["Icon"],
						desc = L["Shows or hides the bar icons."],
						order = 4,
					},
					time = {
						type = "toggle",
						name = L["Time"],
						desc = L["Whether to show or hide the time left on the bars."],
						order = 5,
					},
					normal = {
						type = "group",
						name = L["Regular bars"],
						inline = true,
						width = "full",
						args = {
							growup = {
								type = "toggle",
								name = L["Grow upwards"],
								desc = L["Toggle bars grow upwards/downwards from anchor."],
								order = 1,
								width = "full",
							},
							scale = {
								type = "range",
								name = L["Scale"],
								min = 0.2,
								max = 2.0,
								step = 0.1,
								order = 2,
								width = "full",
							},
						},
						order = 6,
					},
					emphasize = {
						type = "group",
						name = L["Emphasized bars"],
						inline = true,
						width = "full",
						args = {
							emphasize = {
								type = "toggle",
								name = L["Enable"],
								order = 1,
							},
							emphasizeFlash = {
								type = "toggle",
								name = L["Flash"],
								desc = L["Flashes the background of emphasized bars, which could make it easier for you to spot them."],
								order = 2,
							},
							emphasizeMove = {
								type = "toggle",
								name = L["Move"],
								desc = L["Moves emphasized bars to the Emphasize anchor. If this option is off, emphasized bars will simply change scale and color, and maybe start flashing."],
								order = 3,
							},
							emphasizeGrowup = {
								type = "toggle",
								name = L["Grow upwards"],
								desc = L["Toggle bars grow upwards/downwards from anchor."],
								order = 4,
							},
							emphasizeScale = {
								type = "range",
								name = L["Scale"],
								order = 5,
								min = 0.2,
								max = 2.0,
								step = 0.1,
								width = "full",
							}
						},
						order = 7,
					},
				},
			}
		end
		return pluginOptions
	end
end

--------------------------------------------------------------------------------
-- Bar arrangement
--

local function barSorter(a, b)
	return a.remaining < b.remaining and true or false
end
local tmp = {}
local function rearrangeBars(anchor)
	wipe(tmp)
	for bar in pairs(anchor.bars) do
		tmp[#tmp + 1] = bar
	end
	table.sort(tmp, barSorter)
	local lastDownBar, lastUpBar = nil, nil
	local up = nil
	if anchor == normalAnchor then up = db.growup else up = db.emphasizeGrowup end
	for i, bar in next, tmp do
		bar:ClearAllPoints()
		if up or (db.emphasizeGrowup and bar:Get("bigwigs:emphasized")) then
      bar:SetPoint("BOTTOMLEFT", lastUpBar or anchor, "TOPLEFT", 0, 4)
      bar:SetPoint("BOTTOMRIGHT", lastUpBar or anchor, "TOPRIGHT", 0, 4)
			lastUpBar = bar
		else
			bar:SetPoint("TOPLEFT", lastDownBar or anchor, "BOTTOMLEFT", 0, -4)
			bar:SetPoint("TOPRIGHT", lastDownBar or anchor, "BOTTOMRIGHT", 0, -4)
			lastDownBar = bar
		end
	end
	if anchor == normalAnchor then -- only show the empupdater when there are bars on the normal anchor running
		if #tmp > 0 and db.emphasize then
			empUpdate:Show()
		else
			empUpdate:Hide()
		end
	end
end

local function barStopped(event, bar)
	local a = bar:Get("bigwigs:anchor")
	if a and a.bars and a.bars[bar] then
		a.bars[bar] = nil
		rearrangeBars(a)
	end
end

local function findBar(module, key)
	for k in pairs(normalAnchor.bars) do
		if k:Get("bigwigs:module") == module and k:Get("bigwigs:option") == key then
			return k
		end
	end
	for k in pairs(emphasizeAnchor.bars) do
		if k:Get("bigwigs:module") == module and k:Get("bigwigs:option") == key then
			return k
		end
	end
end

--------------------------------------------------------------------------------
-- Anchors
--

local defaultPositions = {
	BigWigsAnchor = {"CENTER", "UIParent", "CENTER", 0, -120},
	BigWigsEmphasizeAnchor = {"TOP", RaidWarningFrame, "BOTTOM", 0, -35}, --Below the default BigWigs message frame
}

local function onDragHandleMouseDown(self) self:GetParent():StartSizing("BOTTOMRIGHT") end
local function onDragHandleMouseUp(self, button) self:GetParent():StopMovingOrSizing() end
local function onResize(self, width)
	db[self.w] = width
	rearrangeBars(self)
end
local function onDragStart(self) self:StartMoving() end
local function onDragStop(self)
	self:StopMovingOrSizing()
	local s = self:GetEffectiveScale()
	db[self.x] = self:GetLeft() * s
	db[self.y] = self:GetTop() * s
end

local function createAnchor(frameName, title)
	local display = CreateFrame("Frame", frameName, UIParent)
	display.w, display.x, display.y = frameName .. "_width", frameName .. "_x", frameName .. "_y"
	display:EnableMouse(true)
	display:SetClampedToScreen(true)
	display:SetMovable(true)
	display:SetResizable(true)
	display:RegisterForDrag("LeftButton")
	display:SetHeight(20)
	display:SetMinResize(80, 20)
	display:SetMaxResize(1920, 20)
	local bg = display:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(display)
	bg:SetBlendMode("BLEND")
	bg:SetTexture(0, 0, 0, 0.3)
	display.background = bg
	local header = display:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	header:SetText(title)
	header:SetAllPoints(display)
	header:SetJustifyH("CENTER")
	header:SetJustifyV("MIDDLE")
	local drag = CreateFrame("Frame", nil, display)
	drag:SetFrameLevel(display:GetFrameLevel() + 10)
	drag:SetWidth(16)
	drag:SetHeight(16)
	drag:SetPoint("BOTTOMRIGHT", display, -1, 1)
	drag:EnableMouse(true)
	drag:SetScript("OnMouseDown", onDragHandleMouseDown)
	drag:SetScript("OnMouseUp", onDragHandleMouseUp)
	drag:SetAlpha(0.5)
	local tex = drag:CreateTexture(nil, "OVERLAY")
	tex:SetTexture("Interface\\AddOns\\BigWigs\\Textures\\draghandle")
	tex:SetWidth(16)
	tex:SetHeight(16)
	tex:SetBlendMode("ADD")
	tex:SetPoint("CENTER", drag)
	display:SetScript("OnSizeChanged", onResize)
	display:SetScript("OnDragStart", onDragStart)
	display:SetScript("OnDragStop", onDragStop)
	display:SetScript("OnMouseUp", function(self, button)
		if button ~= "LeftButton" then return end
		plugin:SendMessage("BigWigs_SetConfigureTarget", plugin)
	end)
	display.bars = {}
	display.Reset = function(self)
		db[self.x] = nil
		db[self.y] = nil
		db[self.w] = nil
		self:RefixPosition()
	end
	display.RefixPosition = function(self)
		self:ClearAllPoints()
		if db[self.x] and db[self.y] then
			local s = self:GetEffectiveScale()
			self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", db[self.x] / s, db[self.y] / s)
		else
			self:SetPoint(unpack(defaultPositions[self:GetName()]))
		end
		self:SetWidth(db[self.w] or plugin.defaultDB[self.w])
	end
	display:RefixPosition()
	display:Hide()
	return display
end

local function createAnchors()
	normalAnchor = createAnchor("BigWigsAnchor", L["Bars"])
	emphasizeAnchor = createAnchor("BigWigsEmphasizeAnchor", L["Emphasized bars"])

	createAnchors = nil
	createAnchor = nil
end

local function showAnchors()
	if createAnchors then createAnchors() end
	normalAnchor:Show()
	emphasizeAnchor:Show()
end

local function hideAnchors()
	normalAnchor:Hide()
	emphasizeAnchor:Hide()
end

local function resetAnchors()
	normalAnchor:Reset()
	emphasizeAnchor:Reset()
end

local function updateProfile()
	db = plugin.db.profile
	if normalAnchor then
		normalAnchor:RefixPosition()
		emphasizeAnchor:RefixPosition()
	end
end

--------------------------------------------------------------------------------
-- Initialization
--

function plugin:OnRegister()
	media:Register("statusbar", "Otravi", "Interface\\AddOns\\BigWigs\\Textures\\otravi")
	media:Register("statusbar", "Smooth", "Interface\\AddOns\\BigWigs\\Textures\\smooth")
	media:Register("statusbar", "Glaze", "Interface\\AddOns\\BigWigs\\Textures\\glaze")
	media:Register("statusbar", "Charcoal", "Interface\\AddOns\\BigWigs\\Textures\\Charcoal")
	media:Register("statusbar", "BantoBar", "Interface\\AddOns\\BigWigs\\Textures\\default")
	candy.RegisterCallback(self, "LibCandyBar_Stop", barStopped)

	db = self.db.profile
	if not db.font then db.font = media:GetDefault("font") end

	self:RegisterMessage("BigWigs_ProfileUpdate", updateProfile)
end

function plugin:OnPluginEnable()
	times = times or {}
	messages = messages or {}
	timers = timers or {}

	colors = BigWigs:GetPlugin("Colors")
	superemp = BigWigs:GetPlugin("Super Emphasize", true)

	if not media:Fetch("statusbar", db.texture, true) then db.texture = "BantoBar" end
	self:RegisterMessage("BigWigs_StartBar")
	self:RegisterMessage("BigWigs_StopBar")
	self:RegisterMessage("BigWigs_StopBars", "BigWigs_OnBossDisable")
	self:RegisterMessage("BigWigs_OnBossDisable")
	self:RegisterMessage("BigWigs_OnPluginDisable", "BigWigs_OnBossDisable")
	self:RegisterMessage("BigWigs_StartConfigureMode", showAnchors)
	self:RegisterMessage("BigWigs_SetConfigureTarget")
	self:RegisterMessage("BigWigs_StopConfigureMode", hideAnchors)
	self:RegisterMessage("BigWigs_ResetPositions", resetAnchors)
	self:RegisterMessage("BigWigs_ProfileUpdate", updateProfile)
	self:RegisterMessage("BigWigs_SuperEmphasizeStart")

	--  custom bars
	BigWigs:AddSyncListener(self, "BWCustomBar")

	self:RefixClickIntercepts()
	self:RegisterEvent("MODIFIER_STATE_CHANGED", "RefixClickIntercepts")
end

function plugin:BigWigs_SetConfigureTarget(event, module)
	if module == self then
		normalAnchor.background:SetTexture(0.2, 1, 0.2, 0.3)
		emphasizeAnchor.background:SetTexture(0.2, 1, 0.2, 0.3)
	else
		normalAnchor.background:SetTexture(0, 0, 0, 0.3)
		emphasizeAnchor.background:SetTexture(0, 0, 0, 0.3)
	end
end

--------------------------------------------------------------------------------
-- Stopping bars
--

local function stopBars(bars, module, text)
	local dirty = nil
	for k in pairs(bars) do
		if k:Get("bigwigs:module") == module and (not text or k.candyBarLabel:GetText() == text) then
			k:Stop()
			dirty = true
		end
	end
	return dirty
end

local function stop(module, text)
	if not normalAnchor then return end
	local d = stopBars(normalAnchor.bars, module, text)
	if d then rearrangeBars(normalAnchor) end
	d = stopBars(emphasizeAnchor.bars, module, text)
	if d then rearrangeBars(emphasizeAnchor) end
end

function plugin:BigWigs_OnBossDisable(message, module) stop(module) end
function plugin:BigWigs_StopBar(message, module, text) stop(module, text) end

--------------------------------------------------------------------------------
-- Clickable bars
--

local function barClicked(bar, button)
	for action, enabled in pairs(plugin.db.profile[button]) do
		if enabled then clickHandlers[action](bar) end
	end
end

local function barOnEnter(bar)
	bar.candyBarLabel:SetJustifyH(db.align == "CENTER" and "LEFT" or "CENTER")
	bar.candyBarBackground:SetVertexColor(1, 1, 1, 0.8)
end
local function barOnLeave(bar)
	bar.candyBarLabel:SetJustifyH(db.align)
	local module = bar:Get("bigwigs:module")
	local key = bar:Get("bigwigs:option")
	bar.candyBarBackground:SetVertexColor(colors:GetColor("barBackground", module, key))
end

local function refixClickOnBar(intercept, bar)
	if intercept then
		bar:EnableMouse(true)
		bar:SetScript("OnMouseDown", barClicked)
		bar:SetScript("OnEnter", barOnEnter)
		bar:SetScript("OnLeave", barOnLeave)
	else
		bar:EnableMouse(false)
		bar:SetScript("OnMouseDown", nil)
		bar:SetScript("OnEnter", nil)
		bar:SetScript("OnLeave", nil)
	end
end
local function refixClickOnAnchor(intercept, anchor)
	for bar in pairs(anchor.bars) do
		refixClickOnBar(intercept, bar)
	end
end

do
	local keymap = {
		LALT = "ALT", RALT = "ALT",
		LSHIFT = "SHIFT", RSHIFT = "SHIFT",
		LCTRL = "CTRL", RCTRL = "CTRL",
	}
	function plugin:RefixClickIntercepts(event, key, state)
		if not db.interceptMouse or not normalAnchor then return end
		if not db.onlyInterceptOnKeypress or (db.onlyInterceptOnKeypress and type(key) == "string" and db.interceptKey == keymap[key] and state == 1) then
			refixClickOnAnchor(true, normalAnchor)
			refixClickOnAnchor(true, emphasizeAnchor)
		else
			refixClickOnAnchor(false, normalAnchor)
			refixClickOnAnchor(false, emphasizeAnchor)
		end
	end
end

-- Super Emphasize the clicked bar
clickHandlers.emphasize = function(bar)
	if superemp then
		-- Add 0.2sec here to catch messages for this option triggered when the bar ends.
		superemp:Emphasize(bar:Get("bigwigs:module"), bar:Get("bigwigs:option"), bar.remaining + 0.2)
	end
end

-- Report the bar status to the active group type (raid, party, solo)
do
	local tformat1 = "%d:%02d"
	local tformat2 = "%1.1f"
	local tformat3 = "%.0f"
	local function timeDetails(t)
		if t >= 3600 then -- > 1 hour
			local h = floor(t/3600)
			local m = t - (h*3600)
			return tformat1:format(h, m)
		elseif t >= 60 then -- 1 minute to 1 hour
			local m = floor(t/60)
			local s = t - (m*60)
			return tformat1:format(m, s)
		elseif t < 10 then -- 0 to 10 seconds
			return tformat2:format(t)
		else -- 10 seconds to one minute
			return tformat3:format(floor(t + .5))
		end
	end
	clickHandlers.report = function(bar)
		local channel = "SAY"
		if UnitInBattleground("player") then
			channel = "BATTLEGROUND"
		elseif UnitInRaid("player") then
			channel = "RAID"
		elseif GetNumPartyMembers() > 1 then
			channel = "PARTY"
		end
		local text = ("%s: %s"):format(bar.candyBarLabel:GetText(), timeDetails(bar.remaining))
		SendChatMessage(text, channel)
	end
end

-- Removes the clicked bar
clickHandlers.remove = function(bar)
	local anchor = bar:Get("bigwigs:anchor")
	plugin:SendMessage("BigWigs_SilenceOption", bar:Get("bigwigs:option"), bar.remaining + 0.3)
	bar:Stop()
	rearrangeBars(anchor)
end

-- Removes all bars EXCEPT the clicked one
clickHandlers.removeOther = function(bar)
	if normalAnchor then
		for k in pairs(normalAnchor.bars) do
			if k ~= bar then
				plugin:SendMessage("BigWigs_SilenceOption", k:Get("bigwigs:option"), k.remaining + 0.3)
				k:Stop()
			end
		end
		rearrangeBars(normalAnchor)
	end
	if emphasizeAnchor then
		for k in pairs(emphasizeAnchor.bars) do
			if k ~= bar then
				plugin:SendMessage("BigWigs_SilenceOption", k:Get("bigwigs:option"), k.remaining + 0.3)
				k:Stop()
			end
		end
		rearrangeBars(emphasizeAnchor)
	end
end

-- Disables the option that launched this bar
clickHandlers.disable = function(bar)
	local m = bar:Get("bigwigs:module")
	if m and m.db and m.db.profile and bar:Get("bigwigs:option") then
		m.db.profile[bar:Get("bigwigs:option")] = 0
	end
end

-----------------------------------------------------------------------
-- Super Emphasize
--

do
	empUpdate = CreateFrame("Frame")
	empUpdate:Hide()
	local total = 0
	local dirty = nil
	empUpdate:SetScript("OnUpdate", function(self, elapsed)
		if dirty then return end
		for k in pairs(normalAnchor.bars) do
			if not k:Get("bigwigs:emphasized") and k.remaining <= 10 then
				plugin:EmphasizeBar(k)
				dirty = true
			end
		end
		if dirty then
			rearrangeBars(normalAnchor)
			rearrangeBars(emphasizeAnchor)
			dirty = nil
		end
	end)
end

local function countdown(bar)
	if bar.remaining <= bar:Get("bigwigs:count") then
		local count = bar:Get("bigwigs:count")
		bar:Set("bigwigs:count", count - 1)
		PlaySoundFile("Interface\\AddOns\\BigWigs\\Sounds\\"..floor(count)..".mp3")
		if count > 0.9 then
			plugin:SendMessage("BigWigs_EmphasizedMessage", floor(count), 1, 0, 0)
		end
	end
end

local function flash(bar)
	if bar.remaining <= bar:Get("bigwigs:flashcount") then
		local count = bar:Get("bigwigs:flashcount")
		bar:Set("bigwigs:flashcount", count - 1)
		plugin:SendMessage("BigWigs_FlashShake")
	end
end

local function actuallyEmphasize(bar, time)
	if time > 5 and superemp.db.profile.countdown then
		bar:Set("bigwigs:count", math.min(5, floor(time)) + .3) -- sounds last approx .3 seconds this makes them right on the ball
		bar:AddUpdateFunction(countdown)
	end
	if time > 3 and superemp.db.profile.flash then
		bar:Set("bigwigs:flashcount", math.min(3, floor(time)) + .3)
		bar:AddUpdateFunction(flash)
	end
end

function plugin:BigWigs_SuperEmphasizeStart(event, module, key, time)
	local bar = findBar(module, key)
	if not bar then return end
	actuallyEmphasize(bar, time)
end

-----------------------------------------------------------------------
-- Start bars
--

function plugin:BigWigs_StartBar(message, module, key, text, time, icon)
	if createAnchors then createAnchors() end
	stop(module, text)
	local bar = candy:New(media:Fetch("statusbar", db.texture), 200, 14)
	normalAnchor.bars[bar] = true
	bar.candyBarBackground:SetVertexColor(colors:GetColor("barBackground", module, key))
	bar:Set("bigwigs:module", module)
	bar:Set("bigwigs:anchor", normalAnchor)
	bar:Set("bigwigs:option", key)
  bar:SetWidth(bar:GetWidth() * 1.4)
  bar:SetHeight(bar:GetHeight() * 1.4)
	bar:SetColor(colors:GetColor("barColor", module, key))
	bar.candyBarLabel:SetTextColor(colors:GetColor("barText", module, key))
	bar.candyBarLabel:SetJustifyH(db.align)
	local f = media:Fetch("font", db.font)
	bar.candyBarLabel:SetFont(f, 10)
	bar.candyBarDuration:SetFont(f, 10)
	bar:SetLabel(text)
	bar:SetClampedToScreen(true)
	bar:SetDuration(time)
	bar:SetTimeVisibility(db.time)
	bar:SetIcon(db.icon and icon or nil)
	bar:SetScale(db.scale)

  local bwbg = CreateFrame("Frame", "bwbg", bar)
  TukuiDB.CreatePanel(bwbg, 0, 0, "TOP", bar, "TOP", 0, 0)
  bwbg:SetFrameLevel(2)
  bwbg:SetPoint("TOPLEFT", bar,  "TOPLEFT",-1,1)
  bwbg:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT",1,-1)

	if db.emphasize and time < 15 then
		self:EmphasizeBar(bar)
	end
	if db.interceptMouse and not db.onlyInterceptOnKeypress then
		refixClickOnBar(true, bar)
	end
	if superemp and superemp:IsSuperEmphasized(module, key) then
		actuallyEmphasize(bar, time)
	end
	bar:Start()
	rearrangeBars(bar:Get("bigwigs:anchor"))
end

--------------------------------------------------------------------------------
-- Normal Emphasize
--

local function flash(self)
	local r, g, b, a = self.candyBarBackground:GetVertexColor()
	if self:Get("bigwigs:down") then
		r = r - 0.05
		if r <= 0 then self:Set("bigwigs:down", nil) end
	else
		r = r + 0.05
		if r >= 1 then self:Set("bigwigs:down", true) end
	end
	self.candyBarBackground:SetVertexColor(r, g, b, a)
end

function plugin:EmphasizeBar(bar)
	if db.emphasizeMove then
		normalAnchor.bars[bar] = nil
		emphasizeAnchor.bars[bar] = true
		bar:Set("bigwigs:anchor", emphasizeAnchor)
		bar:Start() -- restart the bar -> remaining time is a full length bar again after moving it to the emphasize anchor
	end
	if db.emphasizeFlash then
		bar:AddUpdateFunction(flash)
	end
	local module = bar:Get("bigwigs:module")
	local key = bar:Get("bigwigs:option")
	bar:SetColor(colors:GetColor("barEmphasized", module, key))
	bar:SetScale(db.emphasizeScale)
	bar:Set("bigwigs:emphasized", true)
end

--------------------------------------------------------------------------------
-- Custom Bars
--

local function parseTime(input)
	if type(input) == "nil" then return end
	if tonumber(input) then return tonumber(input) end
	if type(input) == "string" then
		input = input:trim()
		if input:find(":") then
			local m, s = select(3, input:find("^(%d+):(%d+)$"))
			if not tonumber(m) or not tonumber(s) then return end
			return (tonumber(m) * 60) + tonumber(s)
		elseif input:find("^%d+mi?n?$") then
			return tonumber(select(3, input:find("^(%d+)mi?n?$"))) * 60
		end
	end
end

local function sendCustomMessage(msg)
	if not messages[msg] then return end
	plugin:SendMessage("BigWigs_Message", nil, nil, unpack(messages[msg]))
	wipe(messages[msg])
	messages[msg] = nil
end

local function startCustomBar(bar, nick, localOnly)
	local time, barText = select(3, bar:find("(%S+) (.*)"))
	local seconds = parseTime(time)
	if type(seconds) ~= "number" or type(barText) ~= "string" then
		BigWigs:Print(L["Invalid time (|cffff0000%q|r) or missing bar text in a custom bar started by |cffd9d919%s|r. <time> can be either a number in seconds, a M:S pair, or Mm. For example 5, 1:20 or 2m."]:format(tostring(time), nick or UnitName("player")))
		return
	end

	if not nick then nick = L["Local"] end
	local id = "bwcb" .. nick .. barText
	if seconds == 0 then
		if timers[id] then
			plugin:CancelTimer(timers[id], true)
			wipe(messages[id])
			timers[id] = nil
		end
		plugin:SendMessage("BigWigs_StopBar", plugin, nick..": "..barText)
	else
		messages[id] = { L["%s: Timer [%s] finished."]:format(nick, barText), "Attention", localOnly }
		timers[id] = plugin:ScheduleTimer(sendCustomMessage, seconds, id)
		plugin:SendMessage("BigWigs_StartBar", plugin, nil, nick..": "..barText, seconds, "Interface\\Icons\\INV_Misc_PocketWatch_01")
	end
end

function plugin:OnSync(sync, rest, nick)
	if sync ~= "BWCustomBar" or not rest or not nick then return end
	if not UnitIsRaidOfficer(nick) then return end
	startCustomBar(rest, nick, false)
end

-------------------------------------------------------------------------------
-- Slashcommand
--

_G["SlashCmdList"]["BWCB_SHORTHAND"] = function(input)
	if not plugin:IsEnabled() then BigWigs:Enable() end
	local t = GetTime()
	if not times[input] or (times[input] and (times[input] + 2) < t) then
		times[input] = t
		BigWigs:Transmit("BWCustomBar", input)
	end
end
_G["SLASH_BWCB_SHORTHAND1"] = "/bwcb"
_G["SlashCmdList"]["BWLCB_SHORTHAND"] = function(input)
	if not plugin:IsEnabled() then BigWigs:Enable() end
	startCustomBar(input, nil, true)
end
_G["SLASH_BWLCB_SHORTHAND1"] = "/bwlcb"
