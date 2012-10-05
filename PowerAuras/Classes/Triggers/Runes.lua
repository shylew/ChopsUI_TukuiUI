-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Maximum runes. No Blizzard-provided constant for this (wtf?).
local MAX_RUNES = 6;

--- Trigger class for runes.
local Runes = PowerAuras:RegisterTriggerClass("Runes", {
	Parameters = {
		Type = 1, -- If 1, Shapeless, if 2, Shaped.
		Slots = { -- Reminder: Slots 3/4 are visually slots 5/6 ingame!
			[1] = 0x01,
			[2] = 0x01,
			[3] = 0x02,
			[4] = 0x02,
			[5] = 0x04,
			[6] = 0x04,
		},
	},
	Events = {
		RUNE_POWER_UPDATE = "Runes",
		RUNE_TYPE_UPDATE = "Runes",
	},
	Services = {},
	--- Dictionary of supported trigger > service conversions.
	ServiceMirrors = {
		Stacks  = "TriggerData",
		Text    = "TriggerData",
		Texture = "TriggerData",
		Timer   = "TriggerData",
	},
});

--- Constructs a new instance of the trigger and returns it.
-- @param parameters The parameters to construct the trigger from.
function Runes:New(parameters)
	-- Shaped or shapeless?
	local slots = PowerAuras:CopyTable(parameters["Slots"]);
	if(parameters["Type"] == 1) then
		-- Shapeless: "I want these runes and I don't care where they are."
		-- Compact our slots table.
		for i = #(slots), 1, -1 do
			if(slots[i] == 0) then
				tremove(slots, i);
			end
		end
		-- Count remaining runes.
		local maxSlots = #(slots);
		-- Return trigger.
		return function()
			-- Check individual slots.
			local matches = 0;
			for i = 1, maxSlots do
				-- Iterate over runes.
				local slot, match = slots[i], false;
				local deathExact = bit.band(slot, 0xF0) > 0;
				for j = 1, 6 do
					-- Get the rune data.
					local runeType = 2^(GetRuneType(j) - 1);
					local runeExists = GetRuneCount(j) > 0;
					-- Does it exist, and if so, is it a match?
					if(runeExists and bit.band(slot, runeType) > 0) then
						-- Before celebrating, exact death runes?
						if(runeType == 8 and deathExact) then
							-- Verify this slot is valid then.
							local baseRune = math.ceil(j / 2);
							baseRune = (baseRune == 1 and 1 -- Blood
								or baseRune == 2 and 3      -- Unholy
								or baseRune == 3 and 2);    -- Frost
							-- Were we looking for this base type in the slot?
							if(bit.band(slot, 2^(baseRune + 3)) > 0) then
								match = true;
								break;
							end
						else
							-- It wasn't, so we're fine.
							match = true;
							break;
						end
					end
				end
				-- Did we match?
				if(match) then
					matches = matches + 1;
				else
					-- Failed then.
					return false;
				end
			end
			-- Got enough?
			return matches == maxSlots;
		end;
	else
		-- Shaped: "I want these runes in these exact slots."
		-- This check is super simple, so jump right into it.
		return function()
			-- Iterate over runes.
			for i = 1, MAX_RUNES do
				-- Get the slot and rune information.
				local slot = slots[i];
				local runeType = 2^(GetRuneType(i) - 1);
				local runeExists = GetRuneCount(i) > 0;
				-- Does the rune exist, and if so, are we NOT matching it?
				-- Or does it not exist, but are we matching SOMETHING?
				-- And are we not ignoring this slot?
				if(bit.band(slot, 0xF) < 0xF
					and ((runeExists and bit.band(slot, runeType) == 0)
						or (not runeExists and slot > 0))) then
					-- Failed in that case.
					return false;
				end
			end
			-- We're here? Good.
			return true;
		end;
	end
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function Runes:CreateTriggerEditor(frame, ...)
	-- Add a dropdown for selecting the match type.
	local match = PowerAuras:Create("P_Dropdown", frame);
	match:SetUserTooltip("Runes_Type");
	match:AddCheckItem(1, L["Shapeless"]);
	match:SetItemTooltip(1, L["ShapelessTooltip"]);
	match:AddCheckItem(2, L["Shaped"]);
	match:SetItemTooltip(2, L["ShapedTooltip"]);
	match:LinkParameter("Trigger", "Type", ...);
	match:SetTitle(L["MatchType"]);
	match:SetPadding(4, 0, 4, 0);
	match:SetRelativeWidth(0.5);
	match.OnValueUpdated:Connect(PowerAuras:FormatString([[
		-- Also update the slots when changing type.
		local s = PowerAuras:GetParameter("Trigger", "Slots", ${...}) or {};
		if(select(2, ...) == 1) then
			-- Shapeless, set slots to match a Frost/Unholy rune.
			s[1], s[2], s[3], s[4], s[5], s[6] = 
				0x4, 0x2, 0x0, 0x0, 0x0, 0x0;
		else
			-- Shaped, set slots to match the default runes.
			s[1], s[2], s[3], s[4], s[5], s[6] = 
				0x1, 0x1, 0x2, 0x2, 0x4, 0x4;
		end
		-- Update parameter.
		PowerAuras:SetParameter("Trigger", "Slots", s, ${...});
		-- Refresh the host.
		local displays = PowerAuras.Editor.Displays;
		displays:RefreshHost(displays:GetCurrentNode());
	]], ...));
	frame:AddWidget(match);
	-- Add runes.
	local matchType = PowerAuras:GetParameter("Trigger", "Type", ...);
	for i = 1, MAX_RUNES do
		if(matchType == 1) then
			frame:AddWidget(PowerAuras:Create("P_Rune", frame, i, i, ...));
		else
			-- Correct the slot index.
			local s = i / 2;
			if(math.ceil(s) == 2) then
				s = s + 1;
			elseif(math.ceil(s) == 3) then
				s = s - 1;
			end
			s = s * 2;
			-- Add rune to frame.
			local rune = PowerAuras:Create("P_ShapedRune", frame, s, i, ...);
			frame:AddWidget(rune);
		end
	end
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function Runes:Upgrade(version, params)
	
end

-- Hook options addon loading to create our editor widgets.
PowerAuras.OnOptionsLoaded:Connect(function(...)
	--- Rune selection widget. Shapeless edition.
	local Shapeless = PowerAuras:RegisterWidget("P_Rune", "ReusableWidget");

	--- Constructs/recycles an instance of the widget.
	function Shapeless:New()
		-- Recycle if possible.
		local frame = base(self);
		if(not frame) then
			-- Create.
			frame = CreateFrame("Button", nil, UIParent);
			frame:RegisterForClicks("AnyUp");
			frame.Parameter = { "Trigger", "Slots" };
			-- The button can have up to two textures.
			for i = 1, 2 do
				local t = frame:CreateTexture(nil, "OVERLAY");
				frame[i] = t;
				-- Positioning of the first two textures changes, but the
				-- last two are basically static.
				if(i == 1) then
					t:SetPoint("TOPLEFT", 0, 0);
					t:SetSize(32, 32);
				elseif(i == 2) then
					t:SetPoint("TOPRIGHT", 0, 0);
					t:SetSize(16, 32);
				end
			end
		end
		return frame;
	end

	--- Initialises an instance of the widget.
	-- @param parent The parent frame.
	-- @param slot   The rune index. This is the API definition of the slot, 
	--               so this should be adjusted for shaped matches.
	-- @param index  The unaltered rune index.
	-- @param ...    ID's for Get/SetParameter calls.
	function Shapeless:Initialise(parent, slot, index, ...)
		-- Fix the widget size.
		self:SetParent(parent);
		self:SetMargins(0, 16, 0, 0);
		self:SetFixedSize(32, 32);
		self:RegisterEvent("MODIFIER_STATE_CHANGED");
		-- Set our slot index and connect parameters.
		self.RealSlot = index;
		self:SetID(slot);
		self:ConnectParameter("Trigger", "Slots", self.UpdateRune, ...);
		-- Update current display.
		local slots = PowerAuras:GetParameter("Trigger", "Slots", ...);
		self:UpdateRune(slots);
		-- Store varargs.
		for i = 1, select("#", ...) do
			self.Parameter[i + 2] = select(i, ...);
		end
	end

	--- Returns the path to a rune texture.
	-- @param rune The numeric ID of a rune, or a string name of one.
	function Shapeless:GetRuneTexture(rune)
		-- Convert numeric runes to strings.
		if(type(rune) == "number") then
			rune = (rune == 1 and "Blood"
				or rune == 2 and "Unholy"
				or rune == 4 and "Frost"
				or "Death");
		end
		-- Return the path.
		return ([[Interface\PlayerFrame\UI-PlayerFrame-Deathknight-%s]])
			:format(rune)
	end

	--- Gets the localised name for a rune.
	-- @param rune The numeric ID of a rune.
	function Shapeless:GetLocalisedRune(rune)
		return (rune == 1 and COMBAT_TEXT_RUNE_BLOOD
			or rune == 2 and COMBAT_TEXT_RUNE_UNHOLY
			or rune == 4 and COMBAT_TEXT_RUNE_FROST
			or COMBAT_TEXT_RUNE_DEATH);
	end

	--- OnClick script handler for the rune.
	-- @param button The clicked button.
	function Shapeless:OnClick(button)
		-- Get our current rune index.
		local slots = PowerAuras:GetParameter(unpack(self.Parameter));
		local rune = slots[self:GetID()];
		-- Determine our current state.
		if(rune == 0 and not IsAltKeyDown()) then
			-- No rune.
			slots[self:GetID()] = 1;
		else
			if(IsShiftKeyDown() and bit.band(rune, 0x07) > 0) then
				-- Toggle death rune eligibility.
				local hasDeath = bit.band(rune, 0x08) > 0;
				if(hasDeath) then
					-- Revert to normal.
					slots[self:GetID()] = bit.band(rune, 0x07);
				else
					-- Add a death rune.
					slots[self:GetID()] = bit.bor(rune, 0x08);
				end
			elseif(IsAltKeyDown()) then
				-- Delete rune.
				slots[self:GetID()] = 0;
			elseif(IsControlKeyDown() and bit.band(rune, 0x08) > 0) then
				-- Toggle the death lock.
				-- Is the death lock non-existant?
				if(bit.band(rune, 0xF0) == 0) then
					slots[self:GetID()] = bit.bor(bit.band(rune, 0x0F), 0x10);
				else
					slots[self:GetID()] = bit.bor(
						bit.band(rune, 0x0F),
						bit.lshift(bit.band(rune, 0x30), 1)
					);
				end
			elseif(not IsControlKeyDown()) then
				-- Go to next rune type.
				slots[self:GetID()] = bit.bor(
					bit.band(rune, bit.band(rune, 0x7) > 0 and 0x08 or 0x00),
					bit.band(bit.lshift(rune, 1), 0x0F)
				);
			end
		end
		-- Update variables.
		PowerAuras:SetParameter("Trigger", "Slots", slots,
			unpack(self.Parameter, 3));
		-- Update host frame.
		local displays = PowerAuras.Editor.Displays;
		displays:RefreshHost(displays:GetCurrentNode());
	end

	--- OnEvent script handler.
	function Shapeless:OnEvent()
		self:UpdateRune(PowerAuras:GetParameter(unpack(self.Parameter)));
	end

	--- Shows the tooltip for the widget.
	function Shapeless:OnTooltipShow(tooltip)
		-- Set the tooltip owner.
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		-- Get rune data.
		local slots = PowerAuras:GetParameter(unpack(self.Parameter));
		local rune = slots[self:GetID()];
		-- Determine image paths for runes.
		local runes = "|T%s:20:20:0:-2:32:32:0:32:0:32:255:255:255|t";
		local runeID = bit.band(rune, 0x07);
		local runeData = bit.band(rune, 0x0F);
		local replData = bit.rshift(rune, 4);
		-- Still 0?
		if(runeID == 0) then
			-- Handle death runes too.
			if(bit.band(rune, 0x08) > 0) then
				runes = runes:format(self:GetRuneTexture("Death"));
			else
				runes = runes:format(
					[[Interface\PlayerFrame\UI-PlayerFrame-Deathknight-Ring]]
				);
			end
		else
			-- Single rune or multiple?
			if(bit.band(rune, 0x08) > 0) then
				-- Multiple.
				runes = ("%s%s"):format(
					runes:format(self:GetRuneTexture(runeID)),
					runes:format(self:GetRuneTexture("Death"))
				);
			else
				runes = runes:format(self:GetRuneTexture(runeID));
			end
		end
		-- Set title text.
		tooltip:AddDoubleLine(L("RuneID", self.RealSlot), runes);
		tooltip:AddLine(" ");
		-- Tooltip contents are kind of complicated.
		if(IsControlKeyDown() and bit.band(runeData, 0x08) > 0) then
			-- Show replaced rune data.
			if(replData == 0) then
				-- No rune.
				tooltip:AddDoubleLine(
					L("TColon", L["ShapelessRepl"]),
					IGNORED,
					1, 0.8, 0,
					1, 1, 1
				);
			else
				tooltip:AddDoubleLine(
					L("TColon", L["ShapelessRepl"]),
					self:GetLocalisedRune(replData),
					1, 0.8, 0,
					1, 1, 1
				);
			end
			-- Add help text.
			tooltip:AddLine(" ");
			tooltip:AddDoubleLine(
				L("TColon", L["Buttons"]["Left"]),
				L["ShapelessLeft"],
				1, 0.8, 0,
				1, 1, 1,
				true
			);
		else
			-- Show matched rune data.
			if(runeData == 0) then
				-- No rune.
				tooltip:AddDoubleLine(
					L("TColon", L["Matches"]),
					IGNORED,
					1, 0.8, 0,
					1, 1, 1
				);
			elseif(bit.band(runeData, 0x08) == 0 or runeID == 0) then
				-- Single rune.
				tooltip:AddDoubleLine(
					L("TColon", L["Matches"]),
					self:GetLocalisedRune(runeData),
					1, 0.8, 0,
					1, 1, 1
				);
			else
				-- Single/Death rune.
				tooltip:AddDoubleLine(
					L("TColon", L["Matches"]),
					L(
						"RuneTypes",
						self:GetLocalisedRune(bit.band(runeID, 0x7)),
						self:GetLocalisedRune(8)
					),
					1, 0.8, 0,
					1, 1, 1
				);
			end
			-- Add help text.
			tooltip:AddLine(" ");
			tooltip:AddDoubleLine(
				L("TColon", L["Buttons"]["Left"]),
				L["ShapelessLeft"],
				1, 0.8, 0,
				1, 1, 1,
				true
			);
			-- Requires a rune.
			if(runeData > 0) then
				tooltip:AddDoubleLine(
					L("TColon", L("ModButtons1", L["Modifiers"]["Alt"],
							L["Buttons"]["Left"])),
					L["ShapelessAltLeft"],
					1, 0.8, 0,
					1, 1, 1,
					true
				);
			end
			-- Requires a death rune.
			if(bit.band(runeData, 0x08) > 0) then
				tooltip:AddDoubleLine(
					L("TColon", L("ModButtons1", L["Modifiers"]["Ctrl"],
							L["Buttons"]["Left"])),
					L["ShapelessCtrlLeft"],
					1, 0.8, 0,
					1, 1, 1,
					true
				);
			end
			-- Requires a rune.
			if(runeData > 0) then
				tooltip:AddDoubleLine(
					L("TColon", L("ModButtons1", L["Modifiers"]["Shift"],
							L["Buttons"]["Left"])),
					L["ShapelessShiftLeft"],
					1, 0.8, 0,
					1, 1, 1,
					true
				);
			end
		end
	end

	--- Recycles the widget, allowing it to be reused.
	function Shapeless:Recycle()
		self:UnregisterAllEvents();
		base(self);
	end

	--- Callback handling parameter updates.
	-- @param value The new value of a parameter.
	function Shapeless:UpdateRune(value)
		-- Get our rune of interest.
		local rune = value[self:GetID()];
		if(not rune) then
			return;
		end
		-- Frame size.
		local w, h = self:GetFixedSize();
		-- Hide textures by default.
		for i = 1, 2 do
			self[i]:SetDesaturated(false);
			self[i]:SetTexCoord(0, 1, 0, 1);
			self[i]:SetSize(w, h);
			if(i > 1) then
				self[i]:Hide();
			end
		end
		-- Handle runes.
		if(rune == 0) then
			-- No match.
			self[1]:SetTexture(
				[[Interface\PlayerFrame\UI-PlayerFrame-Deathknight-Ring]]
			);
		elseif(IsControlKeyDown() and bit.band(rune, 0x08) > 0) then
			-- Death or Death/Single rune with replacement requirement.
			-- Show the death on the left and the replacement on the right.
			self[1]:SetTexture(self:GetRuneTexture("Death"));
			self[1]:SetTexCoord(0.0, 0.5, 0.0, 1.0);
			self[1]:SetSize(w / 2, h);
			if(bit.band(rune, 0xF0) == 0) then
				self[2]:SetTexture(
					[[Interface\PlayerFrame\UI-PlayerFrame-Deathknight-Ring]]
				);
			else
				self[2]:SetTexture(self:GetRuneTexture(bit.rshift(rune, 4)));
			end
			self[2]:SetTexCoord(0.5, 1.0, 0.0, 1.0);
			self[2]:SetSize(w / 2, h);
			self[2]:Show();
		else
			-- Single or Death/Single rune.
			if(bit.band(rune, 0x08) == 0 or bit.band(rune, 0x07) == 0) then
				-- Single.
				self[1]:SetTexture(self:GetRuneTexture(bit.band(rune, 0x0F)));
			else
				-- Death and single.
				self[1]:SetTexture(self:GetRuneTexture(bit.band(rune, 0x07)));
				self[1]:SetTexCoord(0.0, 0.5, 0.0, 1.0);
				self[1]:SetSize(w / 2, h);
				self[2]:SetTexture(self:GetRuneTexture("Death"));
				self[2]:SetTexCoord(0.5, 1.0, 0.0, 1.0);
				self[2]:SetSize(w / 2, h);
				self[2]:Show();
			end
		end
		-- Refresh tooltip if possible.
		if(self:OwnsTooltip()) then
			self:OnLeave();
			self:OnEnter();
		end
	end

	-- Register widget for selecting the type of a rune. This one is for
	-- Shaped rune patterns, not Shapeless ones!
	local Shaped = PowerAuras:RegisterWidget("P_ShapedRune", "P_Rune");

	--- OnClick script handler for the rune.
	-- @param button The clicked button.
	function Shaped:OnClick(button)
		-- Get our current rune index.
		local slots = PowerAuras:GetParameter(unpack(self.Parameter));
		local rune = slots[self:GetID()];
		-- Determine our current state.
		local real = 2^(math.ceil(self:GetID() / 2) - 1);
		if(bit.band(rune, 0x8) == 0) then
			if(rune == 0) then
				-- No rune. Next: Normal, Prev: All.
				if(button == "LeftButton") then
					rune = real;
				else
					rune = 0xF;
				end
			else
				-- Normal rune. Next: Death/Normal, Prev: None.
				if(button == "LeftButton") then
					rune = bit.bor(real, 0x8);
				else
					rune = 0;
				end
			end
		else
			if(rune == 0xF) then
				-- Any rune. Next: None, Prev: Death/Normal.
				if(button == "LeftButton") then
					rune = 0;
				else
					rune = bit.bor(real, 0x8);
				end
			else
				-- Death/Normal rune. Next: Any, Prev: Normal.
				if(button == "LeftButton") then
					rune = 0xF;
				else
					rune = bit.band(rune, 0x7);
				end
			end
		end
		-- Update variables.
		slots[self:GetID()] = rune;
		PowerAuras:SetParameter("Trigger", "Slots", slots,
			unpack(self.Parameter, 3));
	end

	--- Shows the tooltip for the widget.
	function Shaped:OnTooltipShow(tooltip)
		-- Set the tooltip owner.
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		-- Get rune data.
		local slots = PowerAuras:GetParameter(unpack(self.Parameter));
		local rune = slots[self:GetID()];
		-- Determine image paths for runes.
		local runes = "|T%s:20:20:0:-2:32:32:0:32:0:32:255:255:255|t";
		-- What rune match is this?
		if(rune == 0) then
			-- No rune, no texture!
			runes = [[|TNOTEXTURE:20:20:0:-2:32:32:0:0:0:0:0:0:0|t]];
		elseif(rune == 0xF) then
			-- Any rune.
			runes = runes:format(
				[[Interface\PlayerFrame\UI-PlayerFrame-Deathknight-Ring]]
			);
		elseif(bit.band(rune, 0x8) == 0) then
			-- Single rune.
			runes = runes:format(self:GetRuneTexture(rune));
		else
			-- Single/Death rune.
			runes = ("%s%s"):format(
				runes:format(self:GetRuneTexture(bit.band(rune, 0x7))),
				runes:format(self:GetRuneTexture("Death"))
			);
		end
		-- Set title text.
		tooltip:AddDoubleLine(L("RuneID", self.RealSlot), runes);
		-- Add matches line.
		tooltip:AddLine(" ");
		if(rune == 0) then
			tooltip:AddDoubleLine(
				L("TColon", L["Matches"]),
				NONE,
				1, 0.8, 0,
				1, 1, 1
			);
		elseif(rune == 0xF) then
			tooltip:AddDoubleLine(
				L("TColon", L["Matches"]),
				IGNORED,
				1, 0.8, 0,
				1, 1, 1
			);
		elseif(bit.band(rune, 0x08) == 0) then
			tooltip:AddDoubleLine(
				L("TColon", L["Matches"]),
				self:GetLocalisedRune(rune),
				1, 0.8, 0,
				1, 1, 1
			);
		else
			tooltip:AddDoubleLine(
				L("TColon", L["Matches"]),
				L(
					"RuneTypes",
					self:GetLocalisedRune(bit.band(rune, 0x7)),
					self:GetLocalisedRune(8)
				),
				1, 0.8, 0,
				1, 1, 1
			);
		end
		-- Add help lines.
		tooltip:AddLine(" ");
		tooltip:AddDoubleLine(
			L("TColon", L["Buttons"]["Left"]),
			L["ShapedHelpLeft"],
			1, 0.8, 0,
			1, 1, 1,
			true
		);
		tooltip:AddDoubleLine(
			L("TColon", L["Buttons"]["Right"]),
			L["ShapedHelpRight"],
			1, 0.8, 0,
			1, 1, 1,
			true
		);
	end

	--- Callback handling parameter updates.
	-- @param value The new value of a parameter.
	function Shaped:UpdateRune(value)
		-- Get our rune of interest.
		local rune = value[self:GetID()];
		if(not rune) then
			return;
		end
		-- Frame size.
		local w, h = self:GetFixedSize();
		-- Hide textures by default.
		for i = 1, 2 do
			self[i]:SetDesaturated(false);
			self[i]:SetTexCoord(0, 1, 0, 1);
			self[i]:SetSize(w, h);
			if(i > 1) then
				self[i]:Hide();
			end
		end
		-- Update the rune textures.
		if(bit.band(rune, 0x8) == 0) then
			-- Singular rune, or no rune.
			if(rune == 0) then
				-- No rune.
				local real = math.ceil(self:GetID() / 2);
				self[1]:SetTexture(self:GetRuneTexture(2^(real - 1)));
				self[1]:SetDesaturated(true);
			else
				-- Singular rune.
				self[1]:SetTexture(self:GetRuneTexture(rune));
			end
		else
			-- Death + singular rune, or all runes.
			if(rune == 0xF) then
				-- All runes.
				self[1]:SetTexture(
					[[Interface\PlayerFrame\UI-PlayerFrame-Deathknight-Ring]]
				);
			else
				-- Death + Singular.
				self[1]:SetTexture(self:GetRuneTexture(bit.band(rune, 0x7)));
				self[1]:SetTexCoord(0.0, 0.5, 0.0, 1.0);
				self[1]:SetSize(w / 2, h);
				self[2]:SetTexture(self:GetRuneTexture("Death"));
				self[2]:SetTexCoord(0.5, 1.0, 0.0, 1.0);
				self[2]:SetSize(w / 2, h);
				self[2]:Show();
			end
		end
		-- Refresh tooltip if possible.
		if(self:OwnsTooltip()) then
			self:OnLeave();
			self:OnEnter();
		end
	end
end);