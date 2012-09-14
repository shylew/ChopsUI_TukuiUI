-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

-- Modules.
local Coroutines, Metadata = PowerAuras:GetModules("Coroutines", "Metadata");

do
	--- Reused lookup table for storing ID parameters.
	local lookup = {};

	--- Adjusts a single ID.
	-- @param type    The type of ID to adjust.
	-- @param from    The ID to adjust from.
	-- @param to      The ID to adjust to.
	-- @param resType The type of the passed ID.
	-- @param resID   The resource ID to be adjusted.
	-- @param resDef  The default value to set this ID to, if needed.
	local function adjustID(type, from, to, resType, resID, resDef)
		-- First off, if the passed ID is nil or not valid then just bail.
		if(not resID or resID <= 0) then
			return resID;
		end
		-- Calculate a usable delta. Defaults to 1, even in a deletion.
		local delta = (to or (from + 1)) - from;
		-- Are we adjusting aura ID's?
		if(type == "Aura") then
			-- Certain resource types can be skipped. Do so.
			if(resType == "Animation" or resType == "Layout") then
				return resID;
			end
			-- Split the resource ID.
			local funcName = ("%%sAura%sID"):format(resType);
			local auraID, subID = PowerAuras[funcName:format("Split")](
				PowerAuras, resID
			);
			-- Was this aura actually affected?
			if(auraID == from and not to) then
				-- Same aura, and it was deleted. Return the default.
				return resDef;
			elseif(auraID >= from) then
				-- Aura was one later on, or it has moved, so reindex it.
				return PowerAuras[funcName:format("Get")](
					PowerAuras, auraID - delta, subID
				);
			else
				-- No change.
				return resID;
			end
		else
			-- In other cases, the type/resType need to match.
			if(type ~= resType) then
				return resID;
			end
			-- Handle type in that case.
			if(type == "Animation" or type == "Layout") then
				-- Animations and layouts are sequential, and aren't as messy
				-- because there's no aura boundaries.
				if(resID == from and not to) then
					return resDef;
				elseif(resID > from or resID == from) then
					return resID - delta;
				else
					return resID;
				end
			elseif(type == "Provider" or type == "Action"
				or type == "Display") then
				-- Providers/actions/displays need to take care of the aura
				-- boundary during adjustments. Was this an exact match?
				if(from == resID) then
					-- It was, return the new ID or the default.
					return to or resDef;
				elseif(from > resID and (not to or to > resID)) then
					-- We're adjusting a higher ID and it isn't moving to
					-- an earlier spot.
					return resID;
				else
					-- Split the resource ID.
					local splitName = "SplitAura%sID";
					local joinName = "GetAura%sID";
					local rAID, rSID = PowerAuras[splitName:format(resType)](
						PowerAuras, resID
					);
					-- Split the from/to ID's.
					local fAID, fSID = PowerAuras[splitName:format(type)](
						PowerAuras, from
					);
					-- Basic rule is: You can't move it to an occupied
					-- spot. So we're just adjusting references to
					-- existing ID's.
					if(rAID == fAID and rSID > fSID) then
						-- Adjustment needed.
						return resID - 1;
					else
						-- Doesn't affect us, don't care.
						return resID;
					end
				end
			end
		end
	end

	--- Adjusts any ID references in the parameters of a resource.
	-- @param class  The class of the resource.
	-- @param params The parameters of the resource.
	-- @param type   The type of the ID being adjusted.
	-- @param from   The ID to adjust from.
	-- @param to     The ID to adjust to, or nil for deletion.
	local function adjustParameters(class, params, type, from, to)
		-- Fill the parameters lookup table.
		wipe(lookup);
		class:GetIDParameters(params, lookup);
		-- Get class defaults.
		local defaults;
		-- HACK: Layouts are the only type that doesn't conform to the
		-- naming standard here.
		if(class.GetDefaultDisplayParameters) then
			defaults = class:GetDefaultDisplayParameters();
		else
			defaults = class:GetDefaultParameters();
		end
		-- Iterate over everything.
		local key, data = next(lookup);
		while(key) do
			-- Is the data a table?
			if(_G.type(data) == "table") then
				-- Anything left?
				local subkey, subval = next(data);
				while(subkey) do
					-- Adjust it.
					params[key][subkey] = adjustID(
						type, from, to,
						subval, params[key][subkey], defaults[key][subkey]
					);
					-- Next item.
					subkey, subval = next(data, subkey);
				end
			else
				-- Simple adjustment then.
				params[key] = adjustID(
					type, from, to,
					data, params[key], defaults[key]
				);
			end
			-- Next item.
			key, data = next(lookup, key);
		end
	end

	local function reindexAnimation(self, type, from, to, ...)
		-- Animations are only ever referenced by actions.
		local dID, cType, cID = ...;
		local dVars = self:GetAuraDisplay(dID);
		local chan = dVars["Animations"]["Triggered"][cType][cID];

		-- Get the action that controls this channel.
		local aVars = self:GetAuraAction(chan["Action"]);
		local aClass = self:GetActionClass(aVars["Type"]);
		local aParams = aVars["Parameters"];
		adjustParameters(aClass, aParams, type, from, to);
	end

	local function reindexLayout(self, type, from, to, ...)
		-- Layouts are only linked to displays.
		for _, vars in self:GetAllDisplays() do
			vars["Layout"]["ID"] = adjustID(
				type, from, to,
				"Layout", vars["Layout"]["ID"]
			);
		end
	end

	local function reindexProvider(self, type, from, to, ...)
		-- Providers are found on displays and triggers.
		for _, vars in self:GetAllDisplays() do
			vars["Provider"] = adjustID(
				type, from, to,
				"Provider", vars["Provider"]
			);
		end

		-- Triggers next.
		for aID, action in self:GetAllActions() do
			for _, vars in self:GetAllAuraActionTriggers(aID) do
				vars["Provider"] = adjustID(
					type, from, to,
					"Provider", vars["Provider"]
				);
			end
		end
	end

	local function reindexAction(self, type, from, to, ...)
		-- Actions can be in many places, so start with displays.
		for _, display in self:GetAllDisplays() do
			-- Check all the actions on displays.
			for actionType, actionID in pairs(display["Actions"]) do
				display["Actions"][actionType] = adjustID(
					type, from, to,
					"Action", actionID
				);
			end

			-- Remove from animations channels.
			local anims = display["Animations"]["Triggered"];
			for _, channels in pairs(anims) do
				for i = 1, #(channels) do
					local chan = channels[i];
					chan["Action"] = adjustID(
						type, from, to,
						"Action", chan["Action"]
					);
				end
			end
		end

		-- Remove from triggers.
		for aID, action in self:GetAllActions() do
			for _, vars in self:GetAllAuraActionTriggers(aID) do
				local class = self:GetTriggerClass(vars["Type"]);
				local params = vars["Parameters"];
				adjustParameters(class, params, type, from, to);
			end
		end

		-- And from providers.
		for _, prov in self:GetAllProviders() do
			for int, svc in pairs(prov) do
				local params = svc["Parameters"];
				local class = self:GetServiceClassImplementation(
					svc["Type"], int
				);
				adjustParameters(class, params, type, from, to);
			end
		end
	end

	local function reindexDisplay(self, type, from, to, ...)
		-- Remove from layouts.
		for id, vars in self:GetAllDisplays() do
			local layout = self:GetLayout(vars["Layout"]["ID"]);
			local class = self:GetLayoutClass(layout["Type"]);
			local params = vars["Layout"]["Parameters"];
			adjustParameters(class, params, type, from, to);

			-- Remove from display flags.
			local lID = Metadata:GetFlagID(vars.Flags, "Display");
			if(lID > 0 and type ~= "Aura") then
				-- Get the full ID of the link.
				local auraID = PowerAuras:SplitAuraDisplayID(id);
				local fullID = PowerAuras:GetAuraDisplayID(auraID, lID);

				-- Adjust and split it back down to a relative ID.
				local nFull = adjustID(type, from, to, "Display", fullID);
				local _, nLID = PowerAuras:SplitAuraDisplayID(nFull);

				-- Store adjusted one.
				vars.Flags = Metadata:SetFlagID(vars.Flags, nLID, "Display");
			end
		end

		-- Remove from triggers.
		for aID, action in self:GetAllActions() do
			for _, vars in self:GetAllAuraActionTriggers(aID) do
				local class = self:GetTriggerClass(vars["Type"]);
				local params = vars["Parameters"];
				adjustParameters(class, params, type, from, to);
			end
		end
	end

	--- Reindexes a resource ID and the ID's of any other resources that
	--  point to it, or come after it sequentially.
	-- @param type The resource type to adjust.
	-- @param from The ID to adjust from.
	-- @param to   The new ID of the resource. If nil, the resource is
	--             treated as if it were being deleted. If a number, then
	--             it will be considered as simply moving.
	-- @param ...  Additional arguments based upon the resource type.
	function PowerAuras:ReindexResourceID(type, from, to, ...)
		-- Certain types are easier to adjust than others, so we'll work in
		-- that order.
		if(type == "Animation") then
			reindexAnimation(self, type, from, to, ...);
		elseif(type == "Layout") then
			reindexLayout(self, type, from, to, ...);
		elseif(type == "Provider") then
			reindexProvider(self, type, from, to, ...);
		elseif(type == "Action") then
			reindexAction(self, type, from, to, ...);
		elseif(type == "Display") then
			reindexDisplay(self, type, from, to, ...);
		elseif(type == "Aura") then
			-- Auras are wrapped in a coroutine because they take so damn long.
			local aMax, dMax, pMax = 0, 0, 0;
			-- Count all the resources.
			for _, _ in self:GetAllActions() do aMax = aMax + 1; end
			for _, _ in self:GetAllDisplays() do dMax = dMax + 1; end
			for _, _ in self:GetAllProviders() do pMax = pMax + 1; end
			-- Return coroutine.
			return coroutine.create(function()
				-- Adjust all the things!
				reindexProvider(self, type, from, to);
				coroutine.yield(1 / 6);
				reindexAction(self, type, from, to);
				coroutine.yield(2 / 6);
				reindexDisplay(self, type, from, to);
				coroutine.yield(3 / 6);
				-- Also handle unused resources.
				local co = self:DeleteUnusedResources();
				while(true) do
					-- Resume coroutine.
					local state, prog = coroutine.resume(co);
					-- Did it error out?
					if(not state) then
						error(prog);
					elseif(coroutine.status(co) == "dead") then
						-- It finished.
						break;
					else
						-- Report progress.
						coroutine.yield((3 / 6) + ((3 / 6) * prog));
					end
				end
			end);
		end
	end
end