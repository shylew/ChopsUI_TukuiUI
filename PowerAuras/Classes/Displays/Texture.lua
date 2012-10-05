-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Used for rotating a pair of coordinates by a given amount of radians about 
--  any origin point with any aspect ratio.
-- @param x   The X coordinate of the pair to rotate.
-- @param y   The Y coordinate of the pair to rotate.
-- @param ox  The origin X coordinate of the texture, as a float. 
--            0.5 represents the center of the image.
-- @param oy  The origin Y coordinate of the texture, as a float. 
--            0.5 represents the center of the image.
-- @param a   The rotation to be applied in radians. Use math.rad to 
--            convert degrees to radians.
-- @param asp The aspect ratio of the image.
-- @return An X and Y coordinate pair to be used as a corner in a SetTexCoord 
--         call.
local function RotateCoordPair(x, y, ox, oy, a, asp)
    y = y / asp;
    oy = oy / asp;
    return ox + (x - ox) * math.cos(a) - (y - oy) * math.sin(a), 
    	(oy + (y - oy) * math.cos(a) + (x - ox) * math.sin(a)) * asp;
end

--- Rotates the given texture around the centre by a certain amount of degrees.
-- @param deg The amount of rotation to apply in degrees.
-- @param ULx The top left corner X coordinate of the texture segment.
-- @param ULy The top left corner Y coordinate of the texture segment.
-- @param LLx The bottom left corner X coordinate of the texture segment.
-- @param LLy The bottom left corner Y coordinate of the texture segment.
-- @param URx The top right corner X coordinate of the texture segment.
-- @param URy The top right corner Y coordinate of the texture segment.
-- @param LRx The bottom right corner X coordinate of the texture segment.
-- @param LRy The bottom right corner Y coordinate of the texture segment.
local function RotateTexture(deg, ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
    -- Get coords.
    local o = math.rad(-deg);
    ULx, ULy = RotateCoordPair(ULx, ULy, 0.5, 0.5, o, 1);
    LLx, LLy = RotateCoordPair(LLx, LLy, 0.5, 0.5, o, 1);
    URx, URy = RotateCoordPair(URx, URy, 0.5, 0.5, o, 1);
    LRx, LRy = RotateCoordPair(LRx, LRy, 0.5, 0.5, o, 1);
    -- Set coords!
    return ULx, ULy, LLx, LLy, URx, URy, LRx, LRy;
end

--- Sets the texture of a display. Hooked function for supporting spell names
--  and ID's.
local function SetTexture(region, tex)
	-- Check if the textures match.
	if(region:GetTexture() == tex) then
		return true;
	end

	-- Are we processing a path or a possible spell?
	if(tex:find("\\", 1, true)) then
		return region:__SetTexture(tex);
	else
		-- If enclosed in brackets, remove them.
		if(tex:sub(1, 1) == "[" and tex:sub(-1, -1) == "]") then
			tex = tex:sub(2, -2);
		end

		-- See if it's a spell.
		local id = tonumber(tex);
		if(id) then
			local _, _, icon = GetSpellInfo(id);
			if(icon) then
				return region:__SetTexture(icon);
			end
		else
			-- Spell name?
			local _, _, icon = GetSpellInfo(tex);
			if(icon) then
				return region:__SetTexture(icon);
			else
				-- Failed.
				region:__SetTexture(PowerAuras.DefaultIcon);
			end
		end
	end
end

--- Styles the passed frame with data from the passed parameters.
-- @param frame    The frame to style.
-- @param params   The parameters to use for styling.
local function Styler(frame, params)
	-- Configure frame according to parameters.
	frame:SetAlpha(params["Alpha"]);
	frame:SetFrameStrata(params["Strata"]);
	local w, h = unpack(params["Size"]);
	w, h = w * params["Scale"], h * params["Scale"];
	frame:SetSize(w, h);
	-- Create texture if necessary.
	if(not frame.Texture) then
		frame.Texture = frame:CreateTexture(nil, "ARTWORK");
		frame.Texture:SetAllPoints(frame);
		frame.Texture.__SetTexture = frame.Texture.SetTexture;
		frame.Texture.SetTexture = SetTexture;
	end
	-- Style texture.
	frame.Texture:SetBlendMode(params["Mode"]);
	frame.Texture:SetVertexColor(unpack(params["Tint"]));
	frame.Texture:SetTexture(params["Texture"] or PowerAuras.DefaultIcon);
	frame.Texture:SetDesaturated(params["Desaturate"]);
	-- Texcoord modifications. 
	if(params["TexCoords"]) then
		frame.Texture:SetTexCoord(unpack(params["TexCoords"]));
	else
		-- Build coords from flip/rotation.
		local h, v = params["Flip"][1], params["Flip"][2];
		local r = params["Rotation"];
		if(h and not v) then
			frame.Texture:SetTexCoord(
				RotateTexture(r, 1, 0, 1, 1, 0, 0, 0, 1)
			);
		elseif(not h and v) then
			frame.Texture:SetTexCoord(
				RotateTexture(r, 0, 1, 0, 0, 1, 1, 1, 0)
			);
		elseif(h and v) then
			frame.Texture:SetTexCoord(
				RotateTexture(r, 1, 1, 1, 0, 0, 1, 0, 0)
			);
		else
			frame.Texture:SetTexCoord(
				RotateTexture(r, 0, 0, 0, 1, 1, 0, 1, 1)
			);
		end
	end
end

--- Display class definition.
local Texture = PowerAuras:RegisterDisplayClass("Texture", {
	--- Dictionary of default parameters this display uses.
	Parameters = {
		Alpha = 1.0,
		Desaturate = false,
		Flip = { false, false },
		Mode = "BLEND",
		Rotation = 0,
		Scale = 1.0,
		Size = { 128, 128 },
		Strata = "LOW",
		Texture = [[Interface\AddOns\PowerAuras\Textures\Aura1.tga]],
		Tint = { 1.0, 1.0, 1.0 },
	},
	--- Dictionary of action classes this display supports.
	Actions = {
		DisplayActivate   = true,
		DisplayAlpha      = true,
		DisplayBlend      = true,
		DisplayColor      = true,
		DisplayRotation   = true,
		DisplaySaturation = true,
		DisplayScale      = true,
		DisplaySound      = true,
		DisplayTexture    = true,
	},
	--- Dictionary of provider services required by this display type.
	Services = {
	},
	--- Dictionary of optional provider services that can be used by this
	--  display type.
	OptServices = {
		Texture = true,
	},
});

--- Constructs a new instance of the display and returns it.
-- @param frame    A frame to use for the display. The frame may have been
--                 used by a previous display of this type.
-- @param id       The ID number of the display.
-- @param params   The parameters to construct the display from.
function Texture:New(frame, id, params)
	-- Style the display.
	Styler(frame, params);

	if(frame.Provider.Texture) then
		-- Store the default fallback texture.
		local default = params["Texture"];

		--- Called when the provider is updated due to an event.
		function frame:OnProviderUpdate()
			-- Grab the texture data.
			if(not self.HasOverrideTexture) then
				-- Backup various things and restore post-change.
				local tex = self.Texture;
				local sat = tex:IsDesaturated();

				-- Set the texture.
				tex:SetTexture(
					self.Provider.Texture()
						or tex:GetTexture()
						or default
				);

				-- Restore.
				tex:SetDesaturated(sat);
			else
				self.OverrideRestore = self.Provider.Texture()
					or self.Texture:GetTexture()
					or default;
			end
		end

		-- Update.
		frame:OnProviderUpdate();
	end

	-- Done.
	frame:Hide();
	return frame;
end

--- Applies an action to an instance of the display class.
-- @param display The display instance itself.
-- @param action  The action class name, such as "DisplayColor".
-- @param ...     Sequence parameters of the action.
function Texture:ApplyAction(action, display, ...)
	if(action == "DisplayColor") then
		local r, g, b = ...;
		display.Texture:SetVertexColor(r, g, b, display.Texture:GetAlpha());
	elseif(action == "DisplayScale") then
		display:SetSize(...);
	elseif(action == "DisplayAlpha") then
		display.Texture:SetAlpha(...);
	elseif(action == "DisplayBlend") then
		display.Texture:SetBlendMode(...);
	elseif(action == "DisplayRotation") then
		local angle = ...;
		-- Apply rotation to original coords.
		if(angle == 0) then
			display.Texture:SetTexCoord(select(2, ...));
		else
			display.Texture:SetTexCoord(RotateTexture(angle, select(2, ...)));
		end
	elseif(action == "DisplaySaturation") then
		display.Texture:SetDesaturated(... or false);
	elseif(action == "DisplayTexture") then
		local path, set = ...;
		-- Backup certain things that change on a texture replacement.
		local tex = display.Texture;
		local sat = tex:IsDesaturated();

		-- Update the texture.
		if(set) then
			if(not display.HasOverrideTexture) then
				display.OverrideRestore = tex:GetTexture();
			end
			tex:SetTexture(path);
			display.HasOverrideTexture = true;
		else
			-- Use override restore if present.
			if(display.OverrideRestore) then
				tex:SetTexture(display.OverrideRestore);
				display.OverrideRestore = nil;
			else
				-- Use passed one.
				tex:SetTexture(path);
			end
			display.HasOverrideTexture = false;
		end

		-- Restore.
		tex:SetDesaturated(sat);
	end
end

--- Creates a static preview of a display for use with the editor.
-- @param frame The frame to attach the preview to.
-- @param id    The ID of the display to preview.
function Texture:CreatePreview(frame, id)
	-- Initial styling.
	local display = PowerAuras:GetAuraDisplay(id);
	Styler(frame, display["Parameters"], false);
	-- Get the provider.
	if(not PowerAuras:HasAuraProvider(display["Provider"])) then
		-- Not got one.
		return;
	end

	-- Get it.
	local prov = PowerAuras:GetAuraProvider(display["Provider"]);
	prov = prov["Texture"];
	if(prov) then
		-- Get the texture class.
		local class = PowerAuras:GetServiceClassImplementation(
			prov["Type"],
			"Texture"
		);
		-- Use the default value return.
		local sat = frame.Texture:IsDesaturated();
		frame.Texture:SetTexture(class:GetDefaultValues(prov["Parameters"]));
		frame.Texture:SetDesaturated(sat);
	end
end

--- Populates the style editor frame with widgets for controlling the
--  parameters of the display.
-- @param frame The frame to populate with controls.
-- @param ...   ID's to match against for the editor.
function Texture:CreateStyleEditor(frame, ...)
	-- Texture (static).
	local texture = PowerAuras:Create("DialogBox", frame, nil, "TextureDialog");
	texture:SetUserTooltip("DTexture_Path");
	texture:SetRelativeWidth(1.0);
	texture:SetPadding(4, 0, 4, 0);
	texture:SetTitle(L["Texture"]);
	texture:SetText(PowerAuras:GetParameter("Display", "Texture", ...));
	texture:ConnectParameter("Display", "Texture", texture.SetText, ...);
	texture.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Display", "Texture", value, ${...});
	]], ...));

	-- Width.
	local sizeX = PowerAuras:Create("P_NumberBox");
	sizeX:SetUserTooltip("DTexture_Width");
	sizeX:SetRelativeWidth(0.175);
	sizeX:SetPadding(4, 0, 2, 0);
	sizeX:SetMinMaxValues(0, 4096);
	sizeX:LinkParameter("Display", "Size", 1, ...);
	sizeX:SetTitle(L["Width"]);

	-- Height.
	local sizeY = PowerAuras:Create("P_NumberBox");
	sizeY:SetUserTooltip("DTexture_Height");
	sizeY:SetRelativeWidth(0.175);
	sizeY:SetPadding(2, 0, 2, 0);
	sizeY:SetMinMaxValues(0, 4096);
	sizeY:LinkParameter("Display", "Size", 2, ...);
	sizeY:SetTitle(L["Height"]);

	-- Texture flipping.
	local flip = PowerAuras:Create("SimpleDropdown", frame);
	flip:SetUserTooltip("DTexture_Flip");
	flip:SetRelativeWidth(0.3);
	flip:SetPadding(2, 0, 2, 0);
	flip:SetTitle(L["Flip"]);
	flip:AddCheckItem(1, L["Horizontal"], false, true);
	flip:AddCheckItem(2, L["Vertical"], false, true);
	local update = PowerAuras:Loadstring(PowerAuras:FormatString([[
		local self = ...;
		local f = PowerAuras:GetParameter("Display", "Flip", ${...});
		self:SetItemChecked(1, f[1]);
		self:SetItemChecked(2, f[2]);
		if(f[1] and not f[2]) then
			self:SetRawText(PowerAuras.L["Horizontal"]);
		elseif(not f[1] and f[2]) then
			self:SetRawText(PowerAuras.L["Vertical"]);
		elseif(f[1] and f[2]) then
			self:SetRawText(PowerAuras.L["Both"]);
		else
			self:SetRawText(NONE);
		end
	]], ...));
	flip:ConnectParameter("Display", "Flip", update, ...);
	update(flip);
	flip.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, key = ...;
		-- Reuse flip table if possible.
		local f = PowerAuras:GetParameter("Display", "Flip", ${...}) or {};
		f[key] = not f[key];
		self:SetItemChecked(key, f[key]);
		PowerAuras:SetParameter("Display", "Flip", f, ${...});
	]], ...));

	-- Alpha slider.
	local alpha = PowerAuras:Create("P_AlphaSlider", frame);
	alpha:SetUserTooltip("Opacity");
	alpha:LinkParameter("Display", "Alpha", ...);
	alpha:SetRelativeWidth(0.35);
	alpha:SetPadding(2, 0, 4, 0);

	-- Frame strata.
	local strata = PowerAuras:Create("P_StrataDropdown", frame);
	strata:SetUserTooltip("Layer");
	strata:LinkParameter("Display", "Strata", ...);
	strata:SetRelativeWidth(0.35);
	strata:SetPadding(4, 0, 2, 0);

	-- Blend mode.
	local blend = PowerAuras:Create("P_BlendDropdown", frame);
	blend:SetUserTooltip("Blend");
	blend:LinkParameter("Display", "Mode", ...);
	blend:SetRelativeWidth(0.3);
	blend:SetPadding(2, 0, 2, 0);

	-- Rotation slider.
	local rotate = PowerAuras:Create("P_Slider", frame);
	rotate:SetUserTooltip("DTexture_Rotation");
	rotate:SetMinMaxValues(0, 270);
	rotate:SetValueStep(90);
	rotate:LinkParameter("Display", "Rotation", ...);
	rotate:SetRelativeWidth(0.35);
	rotate:SetPadding(2, 0, 4, 0);
	rotate:SetMinMaxLabels("%d°", "%d°");
	rotate:SetTitle(L["Rotation"]);

	-- Desaturation.
	local desat = PowerAuras:Create("P_Checkbox", frame);
	desat:SetUserTooltip("DTexture_Desaturate");
	desat:LinkParameter("Display", "Desaturate", ...);
	desat:SetMargins(0, 20, 0, 0);
	desat:SetRelativeWidth(0.35);
	desat:SetPadding(4, 0, 2, 0);
	desat:SetText(L["Desaturate"]);

	-- Color picker.
	local picker = PowerAuras:Create("P_ColorPicker", frame);
	picker:SetUserTooltip("Color");
	picker:LinkParameter("Display", "Tint", ...);
	picker:SetMargins(0, 20, 0, 0);
	picker:SetPadding(2, 0, 2, 0);
	picker:SetRelativeWidth(0.3);

	-- Scale.
	local scale = PowerAuras:Create("P_ScaleSlider", frame);
	scale:SetUserTooltip("Scale");
	scale:SetRelativeWidth(0.35);
	scale:SetPadding(2, 0, 4, 0);
	scale:SetMinMaxValues(1, 1000);
	scale:LinkParameter("Display", "Scale", ...);

	-- Add widgets to layout.
	frame:AddWidget(texture);
	frame:AddRow(4);
	frame:AddWidget(sizeX);
	frame:AddWidget(sizeY);
	frame:AddWidget(flip);
	frame:AddWidget(alpha);
	frame:AddRow(4);
	frame:AddWidget(strata);
	frame:AddWidget(blend);
	frame:AddWidget(rotate);
	frame:AddRow(4);
	frame:AddWidget(desat);
	frame:AddWidget(picker);
	frame:AddWidget(scale);
end

--- Returns a table of default sequence parameters to pass to ApplyAction
--  in the event that no sequence is activated. May return nil.
-- @param action  The action class name, such as "DisplayColor".
-- @param display The display instance itself.
function Texture:GetActionDefaults(action, display)
	if(action == "DisplayColor") then
		return { display.Texture:GetVertexColor() };
	elseif(action == "DisplayScale") then
		return { display:GetSize() };
	elseif(action == "DisplayAlpha") then
		return { display.Texture:GetAlpha() };
	elseif(action == "DisplayBlend") then
		return { display.Texture:GetBlendMode() };
	elseif(action == "DisplayRotation") then
		return { display.Texture:GetTexCoord() };
	elseif(action == "DisplaySaturation") then
		return { display.Texture:IsDesaturated() };
	elseif(action == "DisplayTexture") then
		return { display.Texture:GetTexture() };
	else
		-- No targets.
		return nil;
	end
end

--- Returns a boolean based on whether or not this display supports
--  animations.
function Texture:SupportsAnimation()
	return true;
end

--- Upgrades an display from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The display parameters to upgrade.
function Texture:Upgrade(version, params)
	-- 5.0.0.A -> 5.0.0.N
	if(version < PowerAuras.Version("5.0.0.N")) then
		-- Added scale parameter.
		params.Scale = 1.0;
	end
end