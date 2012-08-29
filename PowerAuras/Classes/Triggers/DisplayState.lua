-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class definition.
local DisplayState = PowerAuras:RegisterTriggerClass("DisplayState", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		ID = -1,
		State = "Show",
	},
	--- Dictionary of events this trigger responds to.
	Events = {
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
function DisplayState:New(parameters)
	-- If we're using a specific state, optimise for that.
	if(DisplayStates[parameters["State"]]) then
		return ([[PowerAuras:GetDisplayActivationState(%d) == %d]]):format(
			parameters["ID"],
			DisplayStates[parameters["State"]]
		);
	else
		-- Create upvalues.
		local id = parameters["ID"];
		local states = { ("/"):split(parameters["State"]) };
		-- Process the states.
		for i = 1, #(states) do
			states[i] = PowerAuras.DisplayStates[states[i]];
		end
		-- Return trigger function.
		return function()
			local state = PowerAuras:GetDisplayActivationState(id);
			for i = 1, #(states) do
				if(state == states[i]) then
					return true;
				end
			end
			return false;
		end;
	end
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function DisplayState:CreateTriggerEditor(frame, ...)
	-- Pick your display!
	local disp = PowerAuras:Create("DisplayBox", frame, PowerAuras.Editor);
	disp:SetUserTooltip("Display_ID");
	disp:SetRelativeWidth(0.6);
	disp:SetPadding(4, 0, 2, 0);
	disp:SetTitle(L["Display"]);
	disp:SetText(PowerAuras:GetParameter("Trigger", "ID", ...) or "");
	disp:ConnectParameter("Trigger", "ID", disp.SetNumber, ...);
	disp.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		-- Validate display exists.
		value = (value:trim() ~= "" and tonumber(value) or nil);
		if(PowerAuras:HasAuraDisplay(value)) then
			PowerAuras:SetParameter("Trigger", "ID", value, ${...});
		else
			PowerAuras:SetParameter("Trigger", "ID", -1, ${...});
		end
	]], ...));
	-- Pick your state!
	local state = PowerAuras:Create("SimpleDropdown", frame);
	state:SetUserTooltip("Display_State");
	state:SetTitle(L["State"]);
	state:SetPadding(2, 0, 4, 0);
	state:SetRelativeWidth(0.4);
	state:AddCheckItem("BeginShow", L["StateBeginShow"], false, true);
	state:SetItemTooltip("BeginShow", L["StateBeginShowTT"]);
	state:AddCheckItem("Show", L["StateShow"], false, true);
	state:SetItemTooltip("Show", L["StateShowTT"]);
	state:AddCheckItem("BeginHide", L["StateBeginHide"], false, true);
	state:SetItemTooltip("BeginHide", L["StateBeginHideTT"]);
	state:AddCheckItem("Hide", L["StateHide"], false, true);
	state:SetItemTooltip("Hide", L["StateHideTT"]);
	-- Set item states.
	local count, value = 0, PowerAuras:GetParameter("Trigger", "State", ...);
	for key in value:gmatch("[^/]+") do
		state:SetItemChecked(key, true);
		state:SetText(key);
		count = count + 1;
	end
	-- Amount of checked items == 0 or > 1?
	if(count == 0 or count > 1) then
		state:SetRawText(count == 0 and NONE or count > 1 and L["Multiple"]);
	end
	-- Connect callbacks.
	state:ConnectParameter("Trigger", "State", PowerAuras:Loadstring([[
		local self, value = ...;
		-- Reset checked states.
		for _, item in pairs(self.ItemsByKey["__ROOT__"]) do
			self:SetItemChecked(item.Key, false);
		end
		-- Set item states.
		local count = 0
		for key in value:gmatch("[^/]+") do
			if(self:HasItem(key)) then
				self:SetItemChecked(key, true);
				self:SetText(key);
				count = count + 1;
			end
		end
		-- Amount of checked items == 0 or > 1?
		if(count == 0 or count > 1) then
			self:SetRawText(count == 0 and NONE
				or count > 1 and PowerAuras.L["Multiple"]);
		end
	]]), ...);
	state.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		-- Update stored value.
		local new = {};
		for key, item in pairs(self.ItemsByKey) do
			if(key == value and not item.State
				or key ~= value and item.State) then
				-- Add key to temp table.
				tinsert(new, key);
			end
		end
		PowerAuras:SetParameter("Trigger", "State", table.concat(new, "/"),
			${...});
	]], ...));
	-- Add widgets to frame.
	frame:AddWidget(disp);
	frame:AddWidget(state);
end

--- Returns a dictionary of displays that this trigger will depend upon in
--  terms of state changes. Returns display IDs as the keys of the table.
-- @param params The parameters of the trigger.
function DisplayState:GetDisplayDependencies(params)
	return { [params["ID"]] = true };
end

--- Returns true if the trigger is considered a 'support' trigger and can
--  be shown as an additional trigger option within the simple activation
--  editor.
function DisplayState:IsSupportTrigger()
	return true;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function DisplayState:Upgrade(version, params)
	
end