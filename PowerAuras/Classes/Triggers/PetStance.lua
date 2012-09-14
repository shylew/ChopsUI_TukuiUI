-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras); 

--- Trigger class definition.
local PetStance = PowerAuras:RegisterTriggerClass("PetStance", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Stance = "Passive",
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		PET_BAR_UPDATE = "PetStance",
		UNIT_PET = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PetStance"] = true;
			end
		end,
	},
	--- Dictionary of provider services required by this trigger type.
	Services = {
	},
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
function PetStance:New(parameters)
	-- Pull and convert to text
	local stance = parameters["Stance"]
	-- Generate trigger, return function.
	return function()
		if (not HasPetSpells()) then
			return false;
		end;
		
		-- Cycle through the spells on the pet action bar
		-- Do in reverse order as 8-10 are most likely to be the stance ones.
		for i = NUM_PET_ACTION_SLOTS, 1, -1 do
			local name, _, _, isToken, isActive = GetPetActionInfo(i);
			if (isToken and isActive) then
				-- Check names against stance
				if(name == "PET_MODE_ASSIST" and stance == "Assist"
					or name == "PET_MODE_DEFENSIVE" and stance == "Defensive"
					or name == "PET_MODE_PASSIVE" and stance == "Passive") then
					-- Match.
					return true;
				end
			end;
		end;
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function PetStance:CreateTriggerEditor(frame, ...)
	-- Stance dropdown.
	local stance = PowerAuras:Create("P_Dropdown", frame);
	stance:SetUserTooltip("Pet_Stance");
	stance:SetRelativeWidth(0.5);
	stance:SetPadding(4, 0, 2, 0);
	stance:SetTitle(L["Stance"]);
	stance:AddCheckItem("Assist", L["Assist"]);
	stance:AddCheckItem("Defensive", L["Defensive"]);
	stance:AddCheckItem("Passive", L["Passive"]);
	stance:LinkParameter("Trigger", "Stance", ...);
	frame:AddWidget(stance);
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function PetStance:Upgrade(version, params)
end