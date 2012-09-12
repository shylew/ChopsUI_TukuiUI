-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Splits a time value in seconds to two smaller values for display on
--  a numeric timer.
-- @param value     The time value to split.
-- @param seconds99 Set to true if a minute should be considered 99 seconds
--                  long, for whatever reason.
local function SplitTime(value, seconds99)
	-- Cap time at 99 hours.
	if(value > 356460) then
		value = 356460;
	end
	-- If the time is over 1 hour, split into hours/minutes.
	if(value > 3600) then
		return floor(value / 3600), floor(mod(mod(value, 3600), 60));
	end
	-- Otherwise, split into minutes/seconds.
	if(value > (seconds99 and 99 or 60)) then
		return floor(value / 60), floor(mod(value, 60));
	end
	-- Or into seconds/ms.
	return floor(value), floor(mod(value, 1) * 100);
end

--- Updates texture coordinates to display a number.
-- @param texture The texture to modify.
-- @param number  The number to display.
-- @param leading Set to true to hide leading zeroes.
local function SetNumber(texture, number, leading)
	local units, tens = mod(number, 10), floor(number / 10);		
	if (tens == 0 and leading) then
		texture:SetTexCoord(0.09765625, 0.09765625 * 1.5, 0.09765625 * units,
			0.09765625 * (units + 1));
	else
		texture:SetTexCoord(0.09765625 * units, 0.09765625 * (units + 1),
			0.09765625 * tens, 0.09765625 * (tens + 1));
	end
end

--- Styles the passed frame based on the passed parameters.
-- @param frame  The frame to style.
-- @param params The parameters to style from.
local function Styler(frame, params)
	-- Configure frame according to parameters.
	frame:SetAlpha(params["Alpha"]);
	frame:SetFrameStrata(params["Strata"]);
	-- Add textures to frame.
	if(not frame.Large) then
		frame.Large = frame:CreateTexture();
	end
	if(not frame.Small) then
		frame.Small = frame:CreateTexture();
	end
	-- Style textures.
	frame.Large:SetTexture(params["Texture"]);
	frame.Small:SetTexture(params["Texture"]);
	frame.Large:SetVertexColor(unpack(params["Tint"]));
	frame.Small:SetVertexColor(unpack(params["Tint"]));
	frame.Large:SetBlendMode(params["Mode"]);
	frame.Small:SetBlendMode(params["Mode"]);
	-- Size and position textures independently.
	frame:SetSize((34 * params["Scale"]), (20 * params["Scale"]));
	frame.Large:SetSize((20 * params["Scale"]), (20 * params["Scale"]));
	frame.Small:SetSize((14 * params["Scale"]), (14 * params["Scale"]));
	frame.Large:SetPoint("RIGHT", frame, "CENTER", 3, 0);
	frame.Small:SetPoint("LEFT", frame, "CENTER", 3, 0);
	-- Set initial numbers.
	SetNumber(frame.Large, 0, false);
	SetNumber(frame.Small, 0, false);
end

--- Display class definition.
local Timer = PowerAuras:RegisterDisplayClass("Timer", {
	--- Dictionary of default parameters this display uses.
	Parameters = {
		Alpha = 1.0,
		Scale = 1.2,
		Mode = "BLEND",
		Strata = "LOW",
		Texture = [[Interface\AddOns\PowerAuras\Counters\Digital\Timers.tga]],
		Tint = { 1.0, 1.0, 1.0 },
		TimeSinceActivation = false,
		HideLeadingZeros = false,
		Seconds99 = false,
		ShowTenths = true,
		ShowTenthsBelow = 0,
		ShowHundredths = true,
		ShowHundredthsBelow = 0,
	},
	--- Dictionary of action classes this display supports.
	Actions = {
		DisplayActivate = true,
		DisplayAlpha    = true,
		DisplayColor    = true,
		DisplayScale    = true,
		DisplaySound    = true,
	},
	--- Dictionary of provider services required by this display type.
	Services = {
		Timer = true,
	},
	--- Dictionary of optional provider services that can be used by this
	--  display type.
	OptServices = {},
});

--- Constructs a new instance of the display and returns it.
-- @param frame    A frame to use for the display. The frame may have been
--                 used by a previous display of this type.
-- @param id       The ID number of the display.
-- @param params   The parameters to construct the display from.
function Timer:New(frame, id, params)
	-- Pass the frame and data to the styler function.
	Styler(frame, params);

	-- Support for providers.
	local timeStart, timeEnd = 0, 2^31 - 1;
	function frame:OnProviderUpdate()
		timeStart, timeEnd = self.Provider.Timer();
	end;

	-- OnUpdate handler for the display.
	function frame:OnUpdate()
		-- Calculate a time to display.
		local time = 0;
		if(not params["TimeSinceActivation"]) then
			-- Time from now until end.
			time = (timeEnd - GetTime());
		else
			-- Time from start until now.
			time = (GetTime() - timeStart);
		end
		-- Update displayed time.
		local large, small = SplitTime(time, params["Seconds99"]);
		SetNumber(self.Large, large, params["HideLeadingZeros"]);
		-- Show the small number?
		local showHundredths = (params["ShowHundredths"]
			and (params["ShowHundredthsBelow"] == 0 
				or time < params["ShowHundredthsBelow"]));
		local showTenths = (params["ShowTenths"]
		and (params["ShowTenthsBelow"] == 0 
				or time < params["ShowTenthsBelow"]));
		if(showHundredths or showTenths) then
			self.Small:Show();
			if(showHundredths) then
				SetNumber(self.Small, small, false);
			else
				SetNumber(self.Small, floor(small / 10), true);
			end
		else
			self.Small:Hide();
		end
	end;

	-- Done.
	frame:Hide();
	return frame;
end

--- Applies an action to an instance of the display class.
-- @param display The display instance itself.
-- @param action  The action class name, such as "DisplayColor".
-- @param ...     Sequence parameters of the action.
function Timer:ApplyAction(action, display, ...)
	if(action == "DisplayColor") then
		local r, g, b = ...;
		display.Large:SetVertexColor(r, g, b, display.Large:GetAlpha());
		display.Small:SetVertexColor(r, g, b, display.Small:GetAlpha());
	elseif(action == "DisplayAlpha") then
		display.Large:SetAlpha(...);
		display.Small:SetAlpha(...);
	elseif(action == "DisplayScale") then
		local new = ...;
		display:SetSize(34 * new, 20 * new);
		display.Large:SetSize(20 * new, 20 * new);
		display.Small:SetSize(14 * new, 14 * new);
	end
end

--- Creates a static preview of a display for use with the editor.
-- @param frame The frame to attach the preview to.
-- @param id    The ID of the display to preview.
function Timer:CreatePreview(frame, id)
	-- Initial styling.
	local display = PowerAuras:GetAuraDisplay(id);
	Styler(frame, display["Parameters"]);
	-- OnUpdate throttle data.
	frame:SetID(id);
	frame.Update = true;
	frame.Progress = frame.Progress or 0;
	frame.LastUpdate = frame.LastUpdate or GetTime();
	-- Add OnUpdate script for previewing the timer.
	if(not frame:GetScript("OnUpdate")) then
		frame:SetScript("OnUpdate", function(self)
			-- Throttle.
			if(self.LastUpdate > GetTime() - 0.025 and not self.Update
				or not PowerAuras:HasAuraDisplay(self:GetID())) then
				return;
			end
			-- Update progress.
			local elapsed = GetTime() - self.LastUpdate;
			self.Progress = self.Progress + (elapsed * 9);
			if(self.Progress > 180) then
				self.Progress = 0;
			end
			-- Get display data.
			local display = PowerAuras:GetAuraDisplay(self:GetID());
			local params = display["Parameters"];

			-- Update displayed time.
			local large, small = SplitTime(self.Progress, params["Seconds99"]);
			SetNumber(self.Large, large, params["HideLeadingZeros"]);
			-- Show the small number?
			local showHundredths = (params["ShowHundredths"]
				and (params["ShowHundredthsBelow"] == 0 
					or self.Progress < params["ShowHundredthsBelow"]));
			local showTenths = (params["ShowTenths"]
			and (params["ShowTenthsBelow"] == 0 
					or self.Progress < params["ShowTenthsBelow"]));
			if(showHundredths or showTenths) then
				self.Small:Show();
				if(showHundredths) then
					SetNumber(self.Small, small, false);
				else
					SetNumber(self.Small, floor(small / 10), true);
				end
			else
				self.Small:Hide();
			end

			-- Set next update time.
			self.LastUpdate = GetTime();
			self.Update = false;
		end);
	end
end

--- Populates the style editor frame with widgets for controlling the
--  parameters of the display.
-- @param frame The frame to populate with controls.
-- @param ...   ID's to match against for the editor.
function Timer:CreateStyleEditor(frame, ...)
	-- Counter texture picker.
	local texture = PowerAuras:Create("CounterBox", frame, PowerAuras.Editor);
	texture:SetUserTooltip("DTimer_Texture");
	texture:SetRelativeWidth(0.8);
	texture:SetPadding(4, 0, 2, 0);
	texture:SetTitle(L["Texture"]);
	texture:SetText(tostring(PowerAuras:GetCounterName(
		PowerAuras:GetParameter("Display", "Texture", ...)
	)));
	texture:ConnectParameter("Display", "Texture", PowerAuras:Loadstring([[
		local self, value = ...;
		self:SetText(tostring(PowerAuras:GetCounterName(value)));
	]]), ...);
	texture.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		value = PowerAuras:GetCounterPath(value);
		PowerAuras:SetParameter("Display", "Texture", tostring(value), ${...});
	]], ...));

	-- Color picker.
	local picker = PowerAuras:Create("P_ColorPicker", frame);
	picker:SetUserTooltip("Color");
	picker:LinkParameter("Display", "Tint", ...);
	picker:SetRelativeWidth(0.2);
	picker:SetMargins(0, 20, 0, 0);
	picker:SetPadding(2, 0, 4, 0);

	-- Alpha slider.
	local alpha = PowerAuras:Create("P_AlphaSlider", frame);
	alpha:SetUserTooltip("Opacity");
	alpha:LinkParameter("Display", "Alpha", ...);
	alpha:SetPadding(4, 0, 2, 0);
	alpha:SetRelativeWidth(0.5);

	-- Scale slider.
	local scale = PowerAuras:Create("P_ScaleSlider", frame);
	scale:SetUserTooltip("Scale");
	scale:LinkParameter("Display", "Scale", ...);
	scale:SetPadding(2, 0, 2, 0);
	scale:SetRelativeWidth(0.5);

	-- Blend mode.
	local blend = PowerAuras:Create("P_BlendDropdown", frame);
	blend:SetUserTooltip("Blend");
	blend:LinkParameter("Display", "Mode", ...);
	blend:SetPadding(4, 0, 2, 0);
	blend:SetRelativeWidth(0.5);

	-- Frame strata.
	local strata = PowerAuras:Create("P_StrataDropdown", frame);
	strata:SetUserTooltip("Layer");
	strata:LinkParameter("Display", "Strata", ...);
	strata:SetPadding(2, 0, 2, 0);
	strata:SetRelativeWidth(0.5);

	-- Many checkboxes, handle it!
	local secs99 = PowerAuras:Create("P_Checkbox", frame);
	secs99:SetUserTooltip("DTimer_Secs99");
	secs99:LinkParameter("Display", "Seconds99", ...);
	secs99:SetPadding(2, 0, 4, 0);
	secs99:SetRelativeWidth(0.5);
	secs99:SetText(L["Seconds99"]);

	local tenths = PowerAuras:Create("P_Checkbox", frame);
	tenths:SetUserTooltip("DTimer_ShowTenths");
	tenths:LinkParameter("Display", "ShowTenths", ...);
	tenths:SetPadding(4, 0, 2, 0);
	tenths:SetRelativeWidth(0.5);
	tenths:SetText(L["ShowTenths"]);
	tenths.OnValueUpdated:Connect([[
		-- Refresh the host.
		local displays = PowerAuras.Editor.Displays;
		displays:RefreshHost(displays:GetCurrentNode());
	]]);

	local hundr = PowerAuras:Create("P_Checkbox", frame);
	hundr:SetUserTooltip("DTimer_ShowHundredths");
	hundr:LinkParameter("Display", "ShowHundredths", ...);
	hundr:SetPadding(2, 0, 2, 0);
	hundr:SetRelativeWidth(0.5);
	hundr:SetText(L["ShowHundredths"]);
	hundr.OnValueUpdated:Connect([[
		-- Refresh the host.
		local displays = PowerAuras.Editor.Displays;
		displays:RefreshHost(displays:GetCurrentNode());
	]]);

	local active = PowerAuras:Create("P_Checkbox", frame);
	active:SetUserTooltip("DTimer_ShowTimeActive");
	active:LinkParameter("Display", "TimeSinceActivation", ...);
	active:SetPadding(4, 0, 2, 0);
	active:SetRelativeWidth(0.5);
	active:SetText(L["TimeSinceActivation"]);

	local leading = PowerAuras:Create("P_Checkbox", frame);
	leading:SetUserTooltip("DTimer_HideLeading");
	leading:LinkParameter("Display", "HideLeadingZeros", ...);
	leading:SetPadding(2, 0, 2, 0);
	leading:SetRelativeWidth(0.5);
	leading:SetText(L["HideLeadingZeros"]);

	-- Hundredths/tenths show sliders.
	local tenthsBelow = PowerAuras:Create("P_Slider", frame);
	tenthsBelow:SetUserTooltip("DTimer_TenthsBelow");
	tenthsBelow:SetMinMaxValues(0, 99);
	tenthsBelow:SetValueStep(1);
	tenthsBelow:LinkParameter("Display", "ShowTenthsBelow", ...);
	tenthsBelow:SetPadding(4, 0, 2, 0);
	tenthsBelow:SetRelativeWidth(0.5);
	tenthsBelow:SetTitle(L["ShowTenthsBelow"]);
	tenthsBelow:SetShown(
		PowerAuras:GetParameter("Display", "ShowTenths", ...) == true
	);

	local hundrBelow = PowerAuras:Create("P_Slider", frame);
	hundrBelow:SetUserTooltip("DTimer_HundredthsBelow");
	hundrBelow:SetMinMaxValues(0, 99);
	hundrBelow:SetValueStep(1);
	hundrBelow:LinkParameter("Display", "ShowHundredthsBelow", ...);
	hundrBelow:SetPadding(4, 0, 2, 0);
	hundrBelow:SetRelativeWidth(0.5);
	hundrBelow:SetTitle(L["ShowHundredthsBelow"]);
	hundrBelow:SetShown(
		PowerAuras:GetParameter("Display", "ShowHundredths", ...) == true
	);

	-- Add widgets to layout.
	frame:AddWidget(texture);
	frame:AddWidget(picker);
	frame:AddRow(4);
	frame:AddWidget(blend);
	frame:AddWidget(strata);
	frame:AddRow(4);
	frame:AddWidget(alpha);
	frame:AddWidget(scale);
	frame:AddRow(4);
	frame:AddWidget(secs99);
	frame:AddWidget(tenths);
	frame:AddWidget(hundr);
	frame:AddWidget(active);
	frame:AddWidget(leading);
	if(tenthsBelow:IsShown() or hundrBelow:IsShown()) then
		frame:AddRow(4);
		if(tenthsBelow:IsShown()) then
			frame:AddWidget(tenthsBelow);
		end
		if(hundrBelow:IsShown()) then
			frame:AddWidget(hundrBelow);
		end
	end
end

--- Returns a table of default sequence parameters to pass to ApplyAction
--  in the event that no sequence is activated. May return nil.
-- @param action  The action class name, such as "DisplayColor".
-- @param display The display instance itself.
function Timer:GetActionDefaults(action, display)
	if(action == "DisplayColor") then
		return { display.Large:GetVertexColor() };
	elseif(action == "DisplayScale") then
		local w, h = display.Large:GetSize();
		return { w / 20, h / 20 };
	elseif(action == "DisplayAlpha") then
		return { display.Large:GetAlpha() };
	else
		-- No targets.
		return nil;
	end
end

--- Returns a boolean based on whether or not this display supports
--  animations.
function Timer:SupportsAnimation()
	return true;
end

--- Upgrades an display from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The display parameters to upgrade.
function Timer:Upgrade(version, params)
end