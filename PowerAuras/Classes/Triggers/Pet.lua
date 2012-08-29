-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class for checking if your pet exists.
local Pet = PowerAuras:RegisterTriggerClass("Pet", {
	Parameters = {},
	Events = {
		PET_BAR_UPDATE = "Pet",
		UNIT_PET = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["Pet"] = true;
			end
		end,
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
function Pet:New(parameters)
	return [[HasPetSpells() and UnitExists("pet")]];
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function Pet:CreateTriggerEditor(frame, ...)
	-- No config message.
	local l = PowerAuras:Create("Label", frame);
	l:SetText(L["TriggerNoConf"]);
	l:SetRelativeWidth(1.0);
	l:SetHeight(36);
	l:SetJustifyH("CENTER");
	l:SetJustifyV("MIDDLE");
	frame:AddWidget(l);
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function Pet:Upgrade(version, params)
	
end