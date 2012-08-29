-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Creates a provider on the specified aura. The provider will be empty by
--  default and have no services.
-- @param id The ID of the aura.
function PowerAuras:CreateAuraProvider(id)
	-- Get the specified aura.
	local aura = self:GetAura(id);
	-- Determine a provider ID.
	local providerID = self:GetAuraProviderCount(id) + 1;
	if(providerID > self.MAX_PROVIDERS_PER_AURA) then
		self:PrintError("Maximum providers per aura reached.");
		return nil;
	end
	-- Create the provider.
	aura["Providers"][providerID] = {};
	self.OnOptionsEvent("PROVIDER_CREATED", id, providerID);
	return self:GetAuraProviderID(id, providerID);
end

--- Creates a service and attaches it to a provider.
-- @param id   The ID of the provider.
-- @param svc  The service type to construct.
-- @param name The class name of the service.
function PowerAuras:CreateAuraProviderService(id, svc, name)
	-- Get the provider.
	local provider = self:GetAuraProvider(id);
	-- Get the implementation.
	local impl = self:GetServiceClassImplementation(name, svc);
	-- Does the service exist already?
	if(provider[svc]) then
		-- Replace it.
		provider[svc] = nil;
	end
	-- Create service.
	provider[svc] = {
		Type = name,
		Parameters = self:CopyTable(impl:GetDefaultParameters()),
	};
	-- Fire callbacks, we're done.
	self.OnOptionsEvent("SERVICE_CREATED", id, svc, name);
	return true;
end

--- Deletes the specified provider.
-- @param id The provider to delete.
function PowerAuras:DeleteAuraProvider(id)
	-- Verify the provider exists.
	if(not self:HasAuraProvider(id)) then
		return false;
	end
	-- Good. Kill it.
	local auraID, pID = self:SplitAuraProviderID(id);
	local aura = self:GetAura(auraID);
	tremove(aura["Providers"], pID);
	-- Remove references.
	self:ReindexResourceID("Provider", id, nil);
	-- Fire callbacks.
	self.OnOptionsEvent("PROVIDER_DELETED", id);
	return true;
end

--- Deletes a service on a provider.
-- @param id  The provider to delete from.
-- @param svc The service to delete.
function PowerAuras:DeleteAuraProviderService(id, svc)
	-- Verify the provider exists.
	if(not self:HasAuraProvider(id)) then
		return false;
	end
	-- Get the provider.
	local prov = self:GetAuraProvider(id);
	-- Remove the service.
	if(prov[svc]) then
		prov[svc] = nil;
		self.OnOptionsEvent("SERVICE_DELETED", id, svc);
		return true;
	else
		return false;
	end
end

do
	--- Internal stateless iterator function for GetAllProviders.
	local function iterator(_, i)
		-- Attempt to access the next action.
		i = i + 1;
		-- Valid?
		if(PowerAuras:HasAuraProvider(i)) then
			return i, PowerAuras:GetAuraProvider(i);
		else
			-- Go to the next aura.
			local aura = PowerAuras:SplitAuraProviderID(i) + 1;
			while(PowerAuras:HasAura(aura)) do
				i = PowerAuras:GetAuraProviderID(aura, 1);
				if(PowerAuras:HasAuraProvider(i)) then
					-- Action here exists.
					return i, PowerAuras:GetAuraProvider(i);
				else
					aura = aura + 1;
				end
			end
		end
	end

	--- Returns an iterator that can be used for accessing every provider
	--  within the current profile.
	function PowerAuras:GetAllProviders()
		return iterator, nil, 0;
	end
end

--- Retrieves the specified provider if it exists.
-- @param id The ID to resolve.
-- @return The referenced provider.
function PowerAuras:GetAuraProvider(id)
	assert(self:HasAuraProvider(id), L("ErrorAuraProviderIDInvalid", id));
	local auraID, providerID = self:SplitAuraProviderID(id);
	return self:GetAura(auraID)["Providers"][providerID];
end

--- Returns the total number of provider in the specified aura.
-- @param id The aura ID.
function PowerAuras:GetAuraProviderCount(id)
	return (self:HasAura(id)
		and #(self:GetAura(id)["Providers"])
		or 0);
end

--- Calculates the ID of an provider for the given aura and provider ID's.
-- @param auraID    The ID of the aura.
-- @param displayID The ID of the action within the aura.
function PowerAuras:GetAuraProviderID(auraID, providerID)
	return ((auraID - 1) * PowerAuras.MAX_PROVIDERS_PER_AURA) + providerID;
end

--- Returns the providers table for the specified aura.
-- @param id The aura ID.
function PowerAuras:GetAuraProviders(id)
	assert(self:HasAura(id), L("ErrorAuraIDInvalid", id));
	return self:GetAura(id)["Providers"];
end

--- Validates the passed provider ID.
-- @param id The ID of the provider.
-- @return True if a provider with this ID exists. False if not.
function PowerAuras:HasAuraProvider(id)
	-- Validate type, then split the ID.
	if(type(id) ~= "number") then
		return false;
	end
	local auraID, providerID = self:SplitAuraProviderID(id);
	-- Validate aura ID, then the display ID.
	return (self:HasAura(auraID) 
		and self:GetAura(auraID)["Providers"][providerID] ~= nil);
end

--- Splits the passed provider ID into the aura ID and the index of the
--  provider within the aura.
-- @param id The ID to split.
function PowerAuras:SplitAuraProviderID(id)
	if(type(id) ~= "number") then
		return 0, 0;
	else
		return math.ceil((id / PowerAuras.MAX_PROVIDERS_PER_AURA)),
			((id - 1) % PowerAuras.MAX_PROVIDERS_PER_AURA) + 1;
	end
end