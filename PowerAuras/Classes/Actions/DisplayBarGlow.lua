-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Makes a bar display glow or not glow.
local DisplayBarGlow = PowerAuras:RegisterActionClass("DisplayBarGlow", {
	Parameters = {},
});

--- Constructor function for the action. Generates and returns an activator.
-- @param id        The ID of the action.
-- @param params    Parameters for constructing the action.
-- @param display   The display to create the action for.
-- @param displayID The ID of the display.
function DisplayBarGlow:New(id, parameters, display, displayID)
	-- Use overriden function if applicable.
	if(display.OnBarGlow) then
		return display.OnBarGlow;
	else
		return function(sequenceID, oldSequenceID)
			-- Get the texture.
			local texture = display.FlashTexture;
			if(not texture) then return; end
			local alpha = texture:GetAlpha();
			if(sequenceID) then
				-- Show flash.
				if(alpha < 1.0 and not texture.BeginShow:IsPlaying()) then
					texture.BeginShow:Play();
				end
			elseif(not sequenceID) then
				-- Hide flash.
				if(alpha > 0.0 and not texture.BeginHide:IsPlaying()) then
					texture.BeginHide:Play();
				end
			end
		end;
	end
end

--- Constructs the sequence editor for an action.
-- @param frame The frame to apply widgets to.
-- @param ...   The ID's to pass to Get/SetParameter calls.
function DisplayBarGlow:CreateSequenceEditor(frame, ...)
	-- No-op, because there's no sequence params.
end

--- Returns the target for this action. A target is what the action needs
--  to be applied to in order to work as intended.
function DisplayBarGlow:GetTarget()
	return "Display";
end

--- Upgrades an action from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function DisplayBarGlow:Upgrade(version, params)
	
end