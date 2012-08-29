-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Styles the passed frame based on the passed parameters.
-- @param frame  The frame to style.
-- @param params The parameters to style from.
local function Styler(frame, params)
	-- Configure frame according to parameters.
	frame:SetAlpha(params["Alpha"]);
	frame:SetFrameStrata(params["Strata"]);

	-- We create our textures on-demand.
	frame.Textures = (frame.Textures or setmetatable({}, {
		__index = function(t, k)
			-- Unpack the parameters.
			local w, h = (params["LegacySizing"] and 20 or 10), 20;
			w, h = w * params["Scale"], h * params["Scale"];
			local texPath, mode = params["Texture"], params["Mode"];
			local r, g, b = unpack(params["Tint"]);

			-- Create the texture.
			local texture = rawget(t, k) or frame:CreateTexture(nil, "OVERLAY");
			texture:SetTexture(texPath);
			texture:SetBlendMode(mode);
			texture:SetVertexColor(r, g, b, 1);
			texture:SetSize(w, h);
			texture:SetPoint(
				"RIGHT",
				frame,
				"RIGHT",
				-((k - 1) * w),
				0
			);
			-- Add texture to list.
			rawset(t, k, texture);
			-- Default value is 0.
			texture:SetTexCoord(
				0.09765625,
				0.09765625 * 1.5,
				0.09765625 * 0,
				0.09765625 * 1
			);
			return texture;
		end,
	}));
end

--- Display class definition.
local Stacks = PowerAuras:RegisterDisplayClass("Stacks", {
	--- Dictionary of default parameters this display uses.
	Parameters = {
		Alpha = 1.0,
		LegacySizing = false,
		Mode = "BLEND",
		Scale = 1.2,
		Strata = "LOW",
		Texture = [[Interface\AddOns\PowerAuras\Counters\Digital\Timers.tga]],
		Tint = { 1.0, 1.0, 1.0 },
		Transparent = true,
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
		Stacks = true,
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
function Stacks:New(frame, id, params)
	-- Pass the frame and data to the styler function.
	Styler(frame, params);

	-- Refresh existing textures.
	for i = 1, #(frame.Textures) do
		getmetatable(frame.Textures).__index(frame.Textures, i);
	end

	-- As our textures are created dynamically, we need to store action
	-- data in tables for when they're made.
	frame.ActionData = {
		Color = { unpack(params["Tint"]) },
		Scale = {
			[1] = params["Scale"] * (params["LegacySizing"] and 20 or 10),
			[2] = params["Scale"] * 20,
		},
		Alpha = 1.0,
	};

	-- Support for providers.
	function frame:OnProviderUpdate()
		-- Get the stack count.
		local stacks = self.Provider.Stacks();
		-- math.log10(0) crashes the client, negatives give an error.
		local unitCount = math.floor(math.log10(math.max(1, stacks)) + 1);
		local texCount = #(self.Textures);
		-- Texture digit sizes.
		local w, h = unpack(self.ActionData.Scale);
		for i = 1, (texCount > unitCount and texCount or unitCount) do
			-- Hide unnecessary textures.
			if(i > unitCount) then
				self.Textures[i]:Hide();
			else
				-- Need the texture?
				local texture = self.Textures[i];
				-- Apply the action data.
				local r, g, b = unpack(self.ActionData.Color);
				texture:SetVertexColor(r, g, b, self.ActionData.Alpha);
				texture:SetSize(w, h);
				-- Update coords to show a valid number.
				texture:SetTexCoord(
					0.09765625,
					0.09765625 * 1.5,
					0.09765625 * (stacks % 10),
					0.09765625 * ((stacks % 10) + 1)
				);
				-- Texture needs showing, dummy :)
				stacks = math.floor(stacks / 10);
				texture:Show();
			end
		end
		-- Update frame size.
		self:SetSize(unitCount * w, h);
	end;

	-- Done.
	frame:Hide();
	return frame;
end

--- Applies an action to an instance of the display class.
-- @param display The display instance itself.
-- @param action  The action class name, such as "DisplayColor".
-- @param ...     Sequence parameters of the action.
function Stacks:ApplyAction(action, display, ...)
	-- Iterate over the textures.
	for i = 1, #(display.Textures) do
		local tex = display.Textures[i];
		-- Handle the action.
		if(action == "DisplayColor") then
			local r, g, b = ...;
			tex:SetVertexColor(r, g, b, tex:GetAlpha());
		elseif(action == "DisplayAlpha") then
			tex:SetAlpha(...);
		elseif(action == "DisplayScale") then
			tex:SetSize(...);
		end
	end

	-- Also store the new data for future textures.
	if(action == "DisplayColor") then
		local color = display.ActionData.Color;
		color[1], color[2], color[3] = ...;
	elseif(action == "DisplayAlpha") then
		display.ActionData.Alpha = ...;
	elseif(action == "DisplayScale") then
		local scale = display.ActionData.Scale;
		scale[1], scale[2] = ...;
	end
end

--- Creates a static preview of a display for use with the editor.
-- @param frame The frame to attach the preview to.
-- @param id    The ID of the display to preview.
function Stacks:CreatePreview(frame, id)
	-- Initial styling.
	local display = PowerAuras:GetAuraDisplay(id);
	Styler(frame, display["Parameters"]);

	-- Ensure at least 1 texture is shown. Use this method to force it to
	-- update.
	for i = 1, math.max(1, #(frame.Textures)) do
		getmetatable(frame.Textures).__index(frame.Textures, i);
	end

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
			self.Progress = self.Progress + (elapsed * 10);
			if(self.Progress > 200) then
				self.Progress = 0;
			end

			-- math.log10(0) crashes the client, negatives give an error.
			local stacks = math.floor(self.Progress);
			local unitCount = math.floor(math.log10(math.max(1, stacks)) + 1);
			local texCount = #(self.Textures);
			local w, h = 0, 0;

			-- Style digits.
			for i = 1, (texCount > unitCount and texCount or unitCount) do
				-- Hide unnecessary textures.
				if(i > unitCount) then
					self.Textures[i]:Hide();
				else
					-- Need the texture?
					local texture = self.Textures[i];
					w, h = texture:GetSize();
					-- Update coords to show a valid number.
					texture:SetTexCoord(
						0.09765625,
						0.09765625 * 1.5,
						0.09765625 * (stacks % 10),
						0.09765625 * ((stacks % 10) + 1)
					);
					-- Texture needs showing, dummy :)
					stacks = math.floor(stacks / 10);
					texture:Show();
				end
			end
			-- Update frame size.
			self:SetSize(unitCount * w, h);

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
function Stacks:CreateStyleEditor(frame, ...)
	-- Counter texture picker.
	local texture = PowerAuras:Create("CounterBox", frame, PowerAuras.Editor);
	texture:SetUserTooltip("DStacks_Texture");
	texture:SetRelativeWidth(0.525);
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
	picker:SetRelativeWidth(0.175);
	picker:SetMargins(0, 20, 0, 0);
	picker:SetPadding(2, 0, 2, 0);

	-- Wide digits/legacy sizing.
	local wide = PowerAuras:Create("P_Checkbox");
	wide:SetUserTooltip("DStacks_WideDigits");
	wide:LinkParameter("Display", "LegacySizing", ...);
	wide:SetRelativeWidth(0.3);
	wide:SetMargins(0, 20, 0, 0);
	wide:SetPadding(2, 0, 4, 0);
	wide:SetText(L["WideDigits"]);

	-- Blend mode.
	local blend = PowerAuras:Create("P_BlendDropdown", frame);
	blend:SetUserTooltip("Blend");
	blend:LinkParameter("Display", "Mode", ...);
	blend:SetPadding(4, 0, 2, 0);
	blend:SetRelativeWidth(0.5);

	-- Frame strata.
	local strata = PowerAuras:Create("P_StrataDropdown", frame);
	strata:LinkParameter("Display", "Strata", ...);
	strata:SetUserTooltip("Layer");
	strata:SetPadding(2, 0, 2, 0);
	strata:SetRelativeWidth(0.5);

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

	-- Add widgets to layout.
	frame:AddWidget(texture);
	frame:AddWidget(picker);
	frame:AddWidget(wide);
	frame:AddRow(4);
	frame:AddWidget(blend);
	frame:AddWidget(strata);
	frame:AddRow(4);
	frame:AddWidget(alpha);
	frame:AddWidget(scale);
end

--- Returns a table of default sequence parameters to pass to ApplyAction
--  in the event that no sequence is activated. May return nil.
-- @param action  The action class name, such as "DisplayColor".
-- @param display The display instance itself.
function Stacks:GetActionDefaults(action, display)
	if(action == "DisplayColor") then
		return PowerAuras:CopyTable(display.ActionData.Color);
	elseif(action == "DisplayAlpha") then
		return { display.ActionData.Alpha };
	elseif(action == "DisplayScale") then
		return PowerAuras:CopyTable(display.ActionData.Scale);
	else
		-- No targets.
		return nil;
	end
end

--- Returns a boolean based on whether or not this display supports
--  animations.
function Stacks:SupportsAnimation()
	return true;
end

--- Upgrades an display from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The display parameters to upgrade.
function Stacks:Upgrade(version, params)
end