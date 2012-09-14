-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Display action definition.
local DisplayTexture = PowerAuras:RegisterActionClass("DisplayTexture", {
	Parameters = {
		[1] = [[Interface\AddOns\PowerAuras\Textures\Aura1.tga]],
	},
});

--- Constructor function for the action. Generates and returns an activator.
-- @param id        The ID of the action.
-- @param params    Parameters for constructing the action.
-- @param display   The display to create the action for.
-- @param displayID The ID of the display.
-- @param cls       The class of the display.
function DisplayTexture:New(id, parameters, display, displayID, cls)
	-- Store the default target values.
	local def = cls:GetActionDefaults("DisplayTexture", display);
	-- Allow the display to override the action.
	if(display.OnTexture) then
		return display.OnTexture;
	else
		-- Return activator.
		return function(seqID, oldID, texture)
			-- Do nothing if we have no targets/sequence changes.
			if(seqID == oldID) then return; end
			if(not seqID) then
				cls:ApplyAction("DisplayTexture", display, unpack(def), false);
			else
				cls:ApplyAction("DisplayTexture", display, texture, true);
			end
		end;
	end
end

--- Constructs the sequence editor for an action.
-- @param frame The frame to apply widgets to.
-- @param ...   The ID's to pass to Get/SetParameter calls.
function DisplayTexture:CreateSequenceEditor(frame, ...)
	-- Texture.
	local texture = PowerAuras:Create("DialogBox", frame, nil, "TextureDialog");
	texture:SetUserTooltip("DTexture_Path");
	texture:SetRelativeWidth(0.8);
	texture:SetPadding(4, 0, 2, 0);
	texture:SetTitle(L["Texture"]);
	texture:SetText(PowerAuras:GetParameter("Sequence", 1, ...));
	texture:ConnectParameter("Sequence", 1, texture.SetText, ...);
	texture.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Sequence", 1, value, ${...});
	]], ...));
	frame:AddWidget(texture);
end

--- Returns the target for this action. A target is what the action needs
--  to be applied to in order to work as intended.
function DisplayTexture:GetTarget()
	return "Display";
end

--- Upgrades an action from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function DisplayTexture:Upgrade(version, params)
end