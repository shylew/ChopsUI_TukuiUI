-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class for spell alerts.
local SpellAlert = PowerAuras:RegisterTriggerClass("SpellAlert", {
	Parameters = {
		Destination = "any",
		Duration = 0.5,
		Match = "Spinning Fire Blossom",
		Source = "player",
		Type = 2, -- Incoming = 1, Outgoing = 2, Both = 3. This setting
		          -- doesn't affect the logic, but can be used for
		          -- performance tuning.
	},
	Events = {
		COMBAT_LOG_EVENT_UNFILTERED = function(buffer, ...)
			-- Long list of locals, ahoy!
			local _, event, _, src, _, _, _, dest = ...;
			-- Outgoing spell?
			if(event == "SPELL_CAST_SUCCESS") then
				buffer:LogEvent("COMBAT_LOG_EVENT_UNFILTERED", ...);
				buffer:LogTrigger("SpellAlert");
				buffer:LogTrigger("SpellAlertByUnit");
			end
			-- Incoming spell?
			if(event:sub(1, 6) == "SPELL_") then
				buffer:LogEvent("COMBAT_LOG_EVENT_UNFILTERED", ...);
				buffer:LogTrigger("SpellAlert");
				buffer:LogTrigger("SpellAlertOnUnit");
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
function SpellAlert:New(parameters)
	-- Get our own type.
	local triggerType = self:GetTriggerType(parameters);
	-- Parameter upvalues.
	local pSrc, pDest, pDur, pType, pMatch = parameters["Source"],
		parameters["Destination"], parameters["Duration"],
		parameters["Type"], parameters["Match"];
	-- Convert match to a table.
	local matches = { ("/"):split(pMatch) };
	for i = 1, #(matches) do
		matches[i] = tonumber(matches[i]) or matches[i];
	end
	-- Activation time.
	local expires = nil;
	return function(self, buffer)
		-- Get the logged events for this trigger type.
		local events = buffer.TriggerEvents[triggerType];
		for i = 1, #(events) do
			-- Extract arguments.
			local data = events[i];
			local _, _, event, _, src, _, _, _, dest, _, _, _, id, name =
				unpack(data);
			-- Does this match our stuff?
			local found = false;
			if((pDest == "any" or UnitGUID(pDest) == dest)
				and (pSrc == "any" or UnitGUID(pSrc) == src)) then
				-- There's an incoming spell on our destination unit.
				for i = 1, #(matches) do
					local match = matches[i];
					if(id == match or name:match(match)) then
						-- Hit!
						found = true;
						break;
					end
				end
			end
			-- Found?
			if(found) then
				expires = buffer.Time + pDur;
				break;
			end
		end
		-- Otherwise, check if we're activated or not.
		if(expires and expires > buffer.Time) then
			return true;
		else
			expires = nil;
			return false;
		end
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function SpellAlert:CreateTriggerEditor(frame, ...)
end

--- Returns the trigger type name.
-- @param params The parameters of the trigger.
function SpellAlert:GetTriggerType(params)
	-- Filter by type.
	return params["Type"] == 1 and "SpellAlertOnUnit"
		or params["Type"] == 2 and "SpellAlertByUnit"
		or "SpellAlert";
end

--- Determines whether or not a trigger requires per-frame updates.
-- @param params The parameters of the trigger.
-- @return True if updates are required, false if not.
-- @return The first value is the default timed state on creation. The 
--         second boolean is whether or not the timed status is capable of
--         being toggled by the trigger.
function SpellAlert:IsTimed(params)
	return true, false;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function SpellAlert:Upgrade(version, params)
	
end