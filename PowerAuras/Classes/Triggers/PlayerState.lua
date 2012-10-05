-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Check if player is in druid travel form.
local function IsDruidTravelForm()
	-- Need to be a druid, apparently.
	local _, class = UnitClass("Player");
	if(class ~= "DRUID") then
		return;
	end
	-- Check for flight/travel forms.
	local form = GetShapeshiftFormID();
	return form and (form == 3 or form == 27);
end

--- Trigger class definition.
local PlayerState = PowerAuras:RegisterTriggerClass("PlayerState", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Resting = -1,
		Alive = 1,
		InVehicle = -1,
		Mounted = -1,
		PvP = -1,
		InParty = -1,
		InRaid = -1,
		Combat = -1,
		IsLeader = -1,
		IsAssist = -1,
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		PLAYER_DEAD = "PlayerState",
		PLAYER_ALIVE = "PlayerState",
		PLAYER_UNGHOST = "PlayerState",
		PARTY_MEMBERS_CHANGED = "PlayerState",
		RAID_ROSTER_UPDATE = "PlayerState",	
		PLAYER_UPDATE_RESTING = "PlayerState",
		PLAYER_REGEN_DISABLED = "PlayerState",
		PLAYER_REGEN_ENABLED = "PlayerState",
		PLAYER_FLAGS_CHANGED = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PlayerState"] = true;
			end 
		end,
		UNIT_AURA = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PlayerState"] = true;
			end 
		end,
		UNIT_FACTION = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PlayerState"] = true;
			end 
		end,
		UNIT_ENTERED_VEHICLE = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PlayerState"] = true;
			end 
		end,
		UNIT_EXITED_VEHICLE = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PlayerState"] = true;
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
function PlayerState:New(parameters)
	-- Function upvalues.
	local IsMounted = IsMounted;
	local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
	local GetNumGroupMembers = GetNumGroupMembers;
	local GetNumSubgroupMembers = GetNumSubgroupMembers;
	local UnitInVehicle = UnitInVehicle;
	local InCombatLockdown = InCombatLockdown;
	local UnitIsGroupLeader = UnitIsGroupLeader;
	local UnitIsRaidOfficer = UnitIsRaidOfficer;
	-- Parameter upvalues.
	local combat, mounted, pvp, alive, inraid, inparty, invehicle, 
		isleader, isassist = 
		parameters["Combat"], parameters["Mounted"], parameters["PvP"],
		parameters["Alive"], parameters["InRaid"], parameters["InParty"],
		parameters["InVehicle"], parameters["IsLeader"],
		parameters["IsAssist"];
	-- Return the function.
	return function()
		-- Check conditions.
		return (
			(combat == 1 and InCombatLockdown()
				or combat == 0 and not InCombatLockdown()
				or combat == -1)
			and (mounted == 1 and (IsMounted() or IsDruidTravelForm())
				or mounted == 0 and not (IsMounted() or IsDruidTravelForm())
				or mounted == -1)
			and (pvp == 1 and UnitIsPVP("player")
				or pvp == 0 and not UnitIsPVP("player")
				or pvp == -1)
			and (alive == 1 and not UnitIsDeadOrGhost("player")
				or alive == 0 and UnitIsDeadOrGhost("player")
				or alive == -1)
			and (inraid == 1 and GetNumGroupMembers() > 0
				or inraid == 0 and GetNumGroupMembers() == 0
				or inraid == -1)
			and (inparty == 1 and GetNumSubgroupMembers() > 0
				or inparty == 0 and GetNumSubgroupMembers() == 0
				or inparty == -1)
			and (invehicle == 1 and UnitInVehicle("player")
				or invehicle == 0 and not UnitInVehicle("player")
				or invehicle == -1)
			and (isleader == 1 and UnitIsGroupLeader("player")
				or isleader == 0 and not UnitIsGroupLeader("player")
				or isleader == -1)
			and (isassist == 1 and UnitIsRaidOfficer("player")
				or isassist == 0 and not UnitIsRaidOfficer("player")
				or isassist == -1)
		);
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function PlayerState:CreateTriggerEditor(frame, ...)
	-- Construct widgets.
	local combat = PowerAuras:Create("TriCheckbox", frame);
	combat:SetRelativeWidth(0.3);
	combat:SetText(L["Combat"]);
	combat:SetState(PowerAuras:GetParameter("Trigger", "Combat", ...));
	combat:ConnectParameter("Trigger", "Combat", combat.SetState, ...);
	combat.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "Combat", value, ${...});
	]], ...));

	local mounted = PowerAuras:Create("TriCheckbox", frame);
	mounted:SetRelativeWidth(0.3);
	mounted:SetText(L["Mounted"]);
	mounted:SetState(PowerAuras:GetParameter("Trigger", "Mounted", ...));
	mounted:ConnectParameter("Trigger", "Mounted", mounted.SetState, ...);
	mounted.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "Mounted", value, ${...});
	]], ...));

	local pvp = PowerAuras:Create("TriCheckbox", frame);
	pvp:SetRelativeWidth(0.3);
	pvp:SetText(L["PvP"]);
	pvp:SetState(PowerAuras:GetParameter("Trigger", "PvP", ...));
	pvp:ConnectParameter("Trigger", "PvP", pvp.SetState, ...);
	pvp.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "PvP", value, ${...});
	]], ...));

	local alive = PowerAuras:Create("TriCheckbox", frame);
	alive:SetRelativeWidth(0.3);
	alive:SetText(L["Alive"]);
	alive:SetState(PowerAuras:GetParameter("Trigger", "Alive", ...));
	alive:ConnectParameter("Trigger", "Alive", alive.SetState, ...);
	alive.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "Alive", value, ${...});
	]], ...));

	local inRaid = PowerAuras:Create("TriCheckbox", frame);
	inRaid:SetRelativeWidth(0.3);
	inRaid:SetText(L["InRaid"]);
	inRaid:SetState(PowerAuras:GetParameter("Trigger", "InRaid", ...));
	inRaid:ConnectParameter("Trigger", "InRaid", inRaid.SetState, ...);
	inRaid.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "InRaid", value, ${...});
	]], ...));

	local inParty = PowerAuras:Create("TriCheckbox", frame);
	inParty:SetRelativeWidth(0.3);
	inParty:SetText(L["InParty"]);
	inParty:SetState(PowerAuras:GetParameter("Trigger", "InParty", ...));
	inParty:ConnectParameter("Trigger", "InParty", inParty.SetState, ...);
	inParty.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "InParty", value, ${...});
	]], ...));

	local inVehicle = PowerAuras:Create("TriCheckbox", frame);
	inVehicle:SetRelativeWidth(0.3);
	inVehicle:SetText(L["InVehicle"]);
	inVehicle:SetState(PowerAuras:GetParameter("Trigger", "InVehicle", ...));
	inVehicle:ConnectParameter("Trigger", "InVehicle", inVehicle.SetState, ...);
	inVehicle.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "InVehicle", value, ${...});
	]], ...));

	local isLeader = PowerAuras:Create("TriCheckbox", frame);
	isLeader:SetRelativeWidth(0.3);
	isLeader:SetText(L["IsLeader"]);
	isLeader:SetState(PowerAuras:GetParameter("Trigger", "IsLeader", ...));
	isLeader:ConnectParameter("Trigger", "IsLeader", isLeader.SetState, ...);
	isLeader.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "IsLeader", value, ${...});
	]], ...));

	local isAssist = PowerAuras:Create("TriCheckbox", frame);
	isAssist:SetRelativeWidth(0.3);
	isAssist:SetText(L["IsAssist"]);
	isAssist:SetState(PowerAuras:GetParameter("Trigger", "IsAssist", ...));
	isAssist:ConnectParameter("Trigger", "IsAssist", isAssist.SetState, ...);
	isAssist.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "IsAssist", value, ${...});
	]], ...));

	-- Add widgets to frame.
	frame:AddWidget(combat);
	frame:AddWidget(mounted);
	frame:AddWidget(pvp);
	frame:AddWidget(alive);
	frame:AddWidget(inRaid);
	frame:AddWidget(inParty);
	frame:AddWidget(inVehicle);
	frame:AddWidget(isLeader);
	frame:AddWidget(isAssist);
end

--- Returns true if the trigger is considered a 'support' trigger and can
--  be shown as an additional trigger option within the simple activation
--  editor.
function PlayerState:IsSupportTrigger()
	return true;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function PlayerState:Upgrade(version, params)
end