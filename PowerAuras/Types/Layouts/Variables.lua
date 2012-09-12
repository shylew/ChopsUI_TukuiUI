-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Creates a layout for the current profile.
-- @param name The class name of the layout.
function PowerAuras:CreateLayout(name)
	-- Get the layout class.
	local class = self:GetLayoutClass(name);
	-- No limits on layouts, get the ID and add it.
	local id = self:GetLayoutCount() + 1;
	self:GetCurrentProfile()["Layouts"][id] = {
		Type = name,
		Parameters = self:CopyTable(class:GetDefaultLayoutParameters()),
	};
	-- Return ID.
	self.OnOptionsEvent("LAYOUT_CREATED");
	return id;
end

function PowerAuras:DeleteLayout()
end

do
	--- Internal stateless iterator function for GetAllLayouts.
	local function iterator(_, i)
		i = i + 1;
		if(PowerAuras:HasLayout(i)) then
			return i, PowerAuras:GetLayout(i);
		else
			return nil, nil;
		end
	end

	--- Returns an iterator that can be used for accessing every layout within
	--  the current profile.
	function PowerAuras:GetAllLayouts()
		return iterator, nil, 0;
	end
end

--- Retrieves the specified layout if it exists.
-- @param id The ID of the layout.
function PowerAuras:GetLayout(id)
	assert(self:HasLayout(id), L("ErrorLayoutIDInvalid", id));
	return self:GetCurrentProfile()["Layouts"][id];
end

--- Returns the total number of layouts in the active profile.
function PowerAuras:GetLayoutCount()
	return (self:IsProfileLoaded()
		and #(self:GetCurrentProfile()["Layouts"])
		or 0);
end

--- Returns the table containing all layouts for this profile.
function PowerAuras:GetLayouts()
	return self:GetCurrentProfile()["Layouts"];
end

--- Validates the passed layout ID.
-- @param id The ID of the layout.
-- @return True if an layout with this ID exists. False if not.
function PowerAuras:HasLayout(id)
	return (self:IsProfileLoaded()
		and type(id) == "number"
		and self:GetCurrentProfile()["Layouts"][id] ~= nil);
end