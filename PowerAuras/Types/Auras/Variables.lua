-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

-- Modules.
local Coroutines = PowerAuras:GetModules("Coroutines");

--- Creates a new aura, and returns the ID number of the created aura.
--  If no auras can be created, nil is returned.
function PowerAuras:CreateAura()
	-- Get the next available ID.
	local id = self:GetAuraCount() + 1;
	-- Test if the ID is within the needed range.
	if(not self:IsProfileLoaded()
		or self:HasAura(id)
		or id > PowerAuras.MAX_AURAS_PER_PROFILE) then
		return nil;
	end
	-- Construct the aura table.
	self:GetCurrentProfile()["Auras"][id] = {
		Actions = {},
		Providers = {},
		Displays = {},
		Icon = "",
		Name = L("AuraID", id),
		Description = L["NoDescription"],
	};
	-- Notify the UI.
	self.OnOptionsEvent("AURAS_CREATED", id);
	-- Create a display for the aura.
	self:CreateAuraDisplay(id, "Texture");
	return id;
end

--- Deletes the aura with the specified ID. The delete operation is not
--  instant, and relies on a coroutine which will be attached to the workspace
--  for processing.
-- @param id The ID of the aura to delete.
-- @return True on success, false on failure.
function PowerAuras:DeleteAura(id)
	-- When deleting an aura, deselect the current one.
	self:SetCurrentAura(nil);
	self.Editor:Hide();
	-- Next, verify the aura exists.
	if(not self:HasAura(id)) then
		return false;
	end
	-- Remove the aura table.
	local aura = tremove(self:GetCurrentProfile()["Auras"], id);
	-- Get the resource counts.
	local aCount = #(aura["Actions"]);
	local dCount = #(aura["Displays"]);
	local pCount = #(aura["Providers"]);
	-- Reindex all resources that pointed to this aura.
	Coroutines:Queue(
		self:ReindexResourceID("Aura", id, nil),
		L["ReindexResourceAuraID"]
	);
	-- Notify the UI.
	self.OnOptionsEvent("AURAS_DELETED", id);
	return true;
end

--- Removes all unused resources from the profile, deleting them and
--  reindexing links in the process.
function PowerAuras:DeleteUnusedResources()
	-- Due to the amount of time this can take, coroutine it.
	return coroutine.create(function()
		-- Count all actions.
		local count = 0;
		for _, _ in self:GetAllActions() do
			count = count + 1;
		end
		-- Run over all actions.
		local i = 1;
		for j = self:GetAuraCount(), 1, -1 do
			for k = #(self:GetAura(j)["Actions"]), 1, -1 do
				local id = self:GetAuraActionID(j, k);
				local action = self:GetAuraAction(id);
				-- Unused actions need specific target types.
				local class = self:GetActionClass(action["Type"]);
				local used = false;
				if(class:GetTarget() == "Animation") then
					-- Run over all displays...
					for _, display in self:GetAllDisplays() do
						-- Over all animation channels...
						local anims = display["Animations"]["Triggered"];
						for _, t in pairs(anims) do
							for _, channel in ipairs(t) do
								if(channel["Action"] == id) then
									used = true;
									break;
								end
							end
							-- Break if we found a hit.
							if(used) then
								break;
							end
						end
						-- Break if we found a hit.
						if(used) then
							break;
						end
					end
				elseif(class:GetTarget() == "Display") then
					-- Run over all displays and find uses of this action.
					for _, display in self:GetAllDisplays() do
						if(display["Actions"][action["Type"]] == id) then
							used = true;
							break;
						end
					end
				else
					-- Standalone action, ignore.
					used = true;
				end
				-- Is the resource unused?
				if(not used) then
					self:DeleteAuraAction(id);
				end
				-- Yield every so often.
				if(i % 5 == 0) then
					coroutine.yield((i / count) / 2);
				end
				i = i + 1;
			end
		end
		-- Count all providers.
		local count = 0;
		for _, _ in self:GetAllProviders() do
			count = count + 1;
		end
		-- Run over all providers.
		local i = 1;
		for j = self:GetAuraCount(), 1, -1 do
			for k = #(self:GetAura(j)["Providers"]), 1, -1 do
				local id = self:GetAuraProviderID(j, k);
				-- Set used flag to false initially.
				local used = false;
				-- Run over all displays and find uses of this provider.
				for _, display in self:GetAllDisplays() do
					if(display["Provider"] == id) then
						used = true;
						break;
					end
				end
				-- And now run over all actions and their triggers...
				if(not used) then
					for aID, action in self:GetAllActions() do
						for _, trig in self:GetAllAuraActionTriggers(aID) do
							if(trig["Provider"] == id) then
								used = true;
								break;
							end
						end
					end
				end
				-- Is the resource unused?
				if(not used) then
					self:DeleteAuraProvider(id);
				end
				-- Yield every so often.
				if(i % 5 == 0) then
					coroutine.yield((1 / 2) + ((i / count) / 2));
				end
				i = i + 1;
			end
		end
		-- Count all displays.
		local count = 0;
		for _, _ in self:GetAllDisplays() do
			count = count + 1;
		end
	end), L["DeleteUnusedResources"];
end

do
	--- Internal stateless iterator function for GetAllAuras.
	local function iterator(_, i)
		i = i + 1;
		if(PowerAuras:HasAura(i)) then
			return i, PowerAuras:GetAura(i);
		else
			return nil, nil;
		end
	end

	--- Returns an iterator that can be used for accessing every aura within
	--  the current profile.
	function PowerAuras:GetAllAuras()
		return iterator, nil, 0;
	end
end

--- Retrieves the specified aura if it exists.
-- @param id The ID of the aura.
function PowerAuras:GetAura(id)
	assert(self:HasAura(id), L("ErrorAuraIDInvalid", id));
	return self:GetCurrentProfile()["Auras"][id];
end

--- Returns the total number of auras in the active profile.
function PowerAuras:GetAuraCount()
	return (self:IsProfileLoaded()
		and #(self:GetCurrentProfile()["Auras"])
		or 0);
end

--- Returns the table containing all auras for this profile.
function PowerAuras:GetAuras()
	return self:GetCurrentProfile()["Auras"];
end

--- Validates the passed aura ID.
-- @param id The ID of the aura.
-- @return True if an aura with this ID exists. False if not.
function PowerAuras:HasAura(id)
	return (self:IsProfileLoaded()
		and type(id) == "number"
		and self:GetCurrentProfile()["Auras"][id] ~= nil);
end