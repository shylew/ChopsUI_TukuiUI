-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Styles the passed frame with data from the passed parameters.
-- @param frame  The frame to style.
-- @param params The parameters to use for styling.
local function Styler(frame, params)
	-- Create texture if necessary.
	if(not frame.Text) then
		frame.Text = frame:CreateFontString();
		frame.Text:SetAllPoints(frame);
	end
	-- Configure frame according to parameters.
	frame:SetAlpha(params["Alpha"]);
	frame:SetFrameStrata(params["Strata"]);
	frame:SetSize(256, 32);
	-- Create label.
	if(not frame.Text) then
		frame.Text = frame:CreateFontString();
	end
	frame.Text:SetAllPoints(frame);
	frame.Text:SetTextColor(unpack(params["Tint"]));
	frame.Text:SetFont(
		params["Font"],
		params["Size"],
		(params["Outline"] ~= ""
			and (", "):join(
				params["Outline"], params["Monochrome"] and "MONOCHROME" or "")
			or "")
	);
	-- Set the text.
	frame.Text:SetText(params["Text"]);
	-- Update the frame size.
	frame:SetSize(frame.Text:GetStringWidth(), frame.Text:GetStringHeight());
end

--- Display class definition.
local Text = PowerAuras:RegisterDisplayClass("Text", {
	--- Dictionary of default parameters this display uses.
	Parameters = {
		Alpha = 1.0,
		Strata = "LOW",
		Tint = { 1.0, 1.0, 1.0 },
		Text = ("Hello %s!"):format(UnitName("player")),
		Font = [[Fonts\FRIZQT__.ttf]],
		Size = 32,
		Outline = "OUTLINE",
		Monochrome = false,
	},
	--- Dictionary of action classes this display supports.
	Actions = {
		DisplayActivate = true,
		DisplayAlpha    = true,
		DisplayColor    = true,
		DisplaySound    = true,
	},
	--- Dictionary of provider services required by this display type.
	Services = {
		Text = true,
	},
	--- Dictionary of optional provider services that can be used by this
	--  display type.
	OptServices = {
		Timer = true,
		Stacks = true,
	},
});

--- Constructs a new instance of the display and returns it.
-- @param frame    A frame to use for the display. The frame may have been
--                 used by a previous display of this type.
-- @param id       The ID number of the display.
-- @param params   The parameters to construct the display from.
function Text:New(frame, id, params)
	-- Style the display.
	Styler(frame, params);
	-- Preprocess the text.
	local text = params["Text"];
	-- Create a substitutions table, which we'll feed to the Text service.
	local subs = {};
	local lookup = {};
	local hasTimer = false;
	-- Auto-escape any existing %'s.
	text = text:gsub("%%", "%%%%");
	-- And parse our text to find matches. Also do replacements in one
	-- iteration.
	local matchStr = "(${([a-zA-Z0-9]+):?([.0-9a-z]*)%s*(.-)%s*})";
	text = text:gsub(matchStr, function(_, key, format, data)
		-- Is this a function to execute?
		if(key == "lua") then
			-- Format: ${lua <code>}
			tinsert(lookup, ([[tostring((%s) or "nil")]]):format(data));
			-- Always assume we have a timer if a lua snippet exists.
			hasTimer = true;
		else
			-- Found a match, add this to our lookup table.
			key = key:lower();
			-- Format string?
			if(format and format ~= "") then
				format = (format:sub(1, 1) ~= "%" and "%" .. format or format);
				tinsert(
					lookup,
					([[(%q):format(tostring(data[%q]))]]):format(format, key)
				);
			else
				tinsert(lookup, ([[tostring(data[%q])]]):format(key));
			end
			-- Does the key match anything we need a timer for?
			hasTimer = (hasTimer or key:sub(1, 4) == "time");
		end
		-- Return a simple %s token for formatting.
		return "%s";
	end);
	-- If we've no substitutions, put in a nil.
	if(#(lookup) == 0) then
		tinsert(lookup, "nil");
	end

	-- Create a custom provider update hander.
	frame.OnProviderUpdate = PowerAuras:Loadstring(([[
		-- Provider variables.
		local data, provider, text = ...;

		-- Timer information.
		local start, finish = 0, 2^31 - 1;

		-- Function.
		return function(self)
			-- Update our substitutions table.
			provider.Text(data);

			-- Timer data.
			if(provider.Timer) then
				-- Update the stored time.
				local newStart, newFinish = provider.Timer();
				if(newStart ~= start and newFinish ~= finish
					or newStart == start and newFinish ~= finish) then
					-- Time has changed.
					start, finish = newStart, newFinish;
				end

				-- Fill in time substitutions.
				local time = GetTime();
				data["timeremaining"] = date("%%M:%%S", finish - time);
				data["timeduration"] = date("%%M:%%S", finish - start);
				data["timeactive"] = date("%%M:%%S", time - start);
			end

			-- Stacks data.
			local stacks = 0;
			if(provider.Stacks) then
				stacks = (provider.Stacks() or 0);
				data["stacks"] = tostring(stacks);
			end

			-- Process data.
			self.Text:SetFormattedText(text, %s);

			-- Resize the frame.
			local width, height = self.Text:GetStringWidth(),
				self.Text:GetStringHeight();
			self:SetSize(width, height);
		end;
	]]):format(table.concat(lookup, ", ")), true)(subs, frame.Provider, text);

	-- Check for a timer provider + timer substitution.
	if(hasTimer and frame.Provider.Timer) then
		--- Called each frame. Simple as.
		frame.OnUpdate = frame.OnProviderUpdate;
	end

	-- Done.
	frame:Hide();
	return frame;
end

--- Applies an action to an instance of the display class.
-- @param display The display instance itself.
-- @param action  The action class name, such as "DisplayColor".
-- @param ...     Sequence parameters of the action.
function Text:ApplyAction(action, display, ...)
	if(action == "DisplayColor") then
		local r, g, b = ...;
		display.Text:SetTextColor(r, g, b, display.Text:GetAlpha());
	elseif(action == "DisplayAlpha") then
		display.Text:SetAlpha(...);
	end
end

--- Creates a static preview of a display for use with the editor.
-- @param frame The frame to attach the preview to.
-- @param id    The ID of the display to preview.
function Text:CreatePreview(frame, id)
	-- Initial styling.
	local display = PowerAuras:GetAuraDisplay(id);
	Styler(frame, display["Parameters"]);
end

--- Populates the style editor frame with widgets for controlling the
--  parameters of the display.
-- @param frame The frame to populate with controls.
-- @param ...   ID's to match against for the editor.
function Text:CreateStyleEditor(frame, ...)
	-- Font picker.
	local font = PowerAuras:Create("FontBox", frame, PowerAuras.Editor);
	font:SetUserTooltip("DText_Font");
	font:SetRelativeWidth(0.8);
	font:SetPadding(4, 0, 2, 0);
	font:SetTitle(L["Font"]);
	font:SetText(tostring(PowerAuras:GetFontName(
		PowerAuras:GetParameter("Display", "Font", ...)
	)));
	font:ConnectParameter("Display", "Font", PowerAuras:Loadstring([[
		local self, value = ...;
		self:SetText(tostring(PowerAuras:GetFontName(value)));
	]]), ...);
	font.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		value = PowerAuras:GetFontPath(value);
		PowerAuras:SetParameter("Display", "Font", tostring(value), ${...});
	]], ...));

	-- Color picker.
	local picker = PowerAuras:Create("P_ColorPicker", frame);
	picker:SetUserTooltip("Color");
	picker:LinkParameter("Display", "Tint", ...);
	picker:SetMargins(0, 20, 0, 0);
	picker:SetPadding(2, 0, 4, 0);
	picker:SetRelativeWidth(0.2);

	-- Epic editbox for the text.
	local text = PowerAuras:Create("P_EditBox", frame);
	text:SetUserTooltip("DText_Text");
	text:LinkParameter("Display", "Text", ...);
	text:SetPadding(4, 0, 2, 0);
	text:SetRelativeWidth(1.0);
	text:SetTitle(L["Text"]);

	-- Frame strata.
	local strata = PowerAuras:Create("P_StrataDropdown", frame);
	strata:SetUserTooltip("Layer");
	strata:LinkParameter("Display", "Strata", ...);
	strata:SetPadding(4, 0, 2, 0);
	strata:SetRelativeWidth(1 / 3);

	-- Font flags.
	local outline = PowerAuras:Create("P_Dropdown", frame);
	outline:SetUserTooltip("DText_Outline");
	outline:AddCheckItem("", NONE);
	outline:AddCheckItem("OUTLINE", L["Normal"]);
	outline:AddCheckItem("THICKOUTLINE", L["Thick"]);
	outline:LinkParameter("Display", "Outline", ...);
	outline:SetTitle(L["Outline"]);
	outline:SetPadding(2, 0, 2, 0);
	outline:SetRelativeWidth(1 / 3);

	local mono = PowerAuras:Create("P_Checkbox", frame);
	mono:SetUserTooltip("DText_Monochrome");
	mono:LinkParameter("Display", "Monochrome", ...);
	mono:SetMargins(0, 20, 0, 0);
	mono:SetPadding(2, 0, 4, 0);
	mono:SetRelativeWidth(1 / 3);
	mono:SetText(L["Monochrome"]);

	-- Alpha slider.
	local alpha = PowerAuras:Create("P_AlphaSlider", frame);
	alpha:SetUserTooltip("Opacity");
	alpha:LinkParameter("Display", "Alpha", ...);
	alpha:SetPadding(4, 0, 2, 0);
	alpha:SetRelativeWidth(0.5);

	-- Size slider.
	local size = PowerAuras:Create("P_Slider", frame);
	size:SetUserTooltip("Scale");
	size:SetMinMaxValues(1, 32);
	size:SetValueStep(1);
	size:LinkParameter("Display", "Size", ...);
	size:SetPadding(2, 0, 2, 0);
	size:SetRelativeWidth(0.5);
	size:SetTitle(L["FontSize"]);

	-- Add widgets to frame.
	frame:AddWidget(font);
	frame:AddWidget(picker);
	frame:AddRow(4);
	frame:AddWidget(text);
	frame:AddRow(4);
	frame:AddWidget(strata);
	frame:AddWidget(outline);
	frame:AddWidget(mono);
	frame:AddRow(4);
	frame:AddWidget(alpha);
	frame:AddWidget(size);
end

--- Returns a table of default sequence parameters to pass to ApplyAction
--  in the event that no sequence is activated. May return nil.
-- @param action  The action class name, such as "DisplayColor".
-- @param display The display instance itself.
function Text:GetActionDefaults(action, display)
	if(action == "DisplayColor") then
		return { display.Text:GetTextColor() };
	elseif(action == "DisplayAlpha") then
		return { display.Text:GetAlpha() };
	else
		-- No targets.
		return nil;
	end
end

--- Upgrades an display from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The display parameters to upgrade.
function Text:Upgrade(version, params)
	
end