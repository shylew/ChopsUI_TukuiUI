-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Dictionary of provider ID's to the actual compiled provider.
local ProviderMap = {};

--- Returns the loaded provider frame for the passed provider ID.
-- @param id The ID of the loaded provider.
function PowerAuras:GetLoadedProvider(id)
	return ProviderMap[id] or error(L("ErrorProviderNotLoaded", id));
end

--- Returns the dictionary of loaded displays.
function PowerAuras:GetLoadedProviders()
	return ProviderMap;
end

--- Checks if the passed provider ID has been loaded successfully.
-- @param id The provider ID to check the state of.
function PowerAuras:IsProviderLoaded(id)
	return not not ProviderMap[id];
end

--- Loads a data provider and its services from the passed data.
-- @param source The data provider to load, as a numeric ID.
function PowerAuras:LoadProvider(id)
	-- Validate the provider ID.
	if(not self:HasAuraProvider(id)) then
		self:LogResourceMessage(1, "Provider", id, "MissingResource");
		return false;
	end
	-- Do nothing if already loaded.
	if(self:IsProviderLoaded(id)) then
		return true;
	end
	-- Get the saved variable data.
	local data = self:GetAuraProvider(id);
	-- Create the provider table and storage for types.
	local provider = {};
	-- Run over the services in the provider.
	for type, data in pairs(data) do
		if(self:HasServiceInterface(type)) then
			-- Validate the service class exists.
			if(not self:HasServiceClassImplemented(data["Type"], type)) then
				self:LogResourceMessage(1, "Provider", id, "MissingService",
					data["Type"], type);
				return false;
			end
			-- Get the service class.
			local class = self:GetServiceClassImplementation(
				data["Type"],
				type
			);
			-- Construct the class.
			local state, result = pcall(class.New, class, data["Parameters"]);
			if(not state) then
				-- Error occured.
				self:LogResourceMessage(1, "Provider", id, "Error", result);
				return false;
			end
			-- Store the service instance.
			provider[type] = result;
		end
	end
	-- All is done.
	ProviderMap[id] = provider;
	self:LogResourceMessage(3, "Provider", id, "Loaded");
	return true;
end

--- Unloads the specified provider.
-- @param id     The ID of the provider to unload.
function PowerAuras:UnloadProvider(id)
	-- If not loaded, don't even bother.
	if(not self:IsProviderLoaded(id)) then
		return;
	end
	-- If the dispatcher is currently loaded, unload it and reload later.
	local reload = self:IsDispatcherLoaded();
	if(reload) then
		self:PrintWarning("Unloading resource with dispatcher active.");
		self:UnloadDispatcher();
	end
	-- Unloading is as simple as removing from the map and changing the state.
	ProviderMap[id] = nil;
	self:LogResourceMessage(3, "Provider", id, "Unloaded");
	-- Reload the dispatcher if needed.
	if(reload) then
		self:LoadDispatcher();
	end
end