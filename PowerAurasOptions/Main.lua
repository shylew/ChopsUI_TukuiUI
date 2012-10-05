-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Frame used for firing OnOptionsLoaded in the main addon.
local Frame = CreateFrame("Frame");
Frame:RegisterEvent("ADDON_LOADED");
Frame:SetScript("OnEvent", function(_, _, addon)
	if(addon == "PowerAurasOptions") then
		-- Unregister the event and script handler.
		Frame:UnregisterAllEvents();
		Frame:SetScript("OnEvent", nil);
		Frame = nil;
		-- Connect our handlers to OnOptionsEvent.
		PowerAuras.OnOptionsEvent:Connect(function(event, ...)
			-- Handle events.
			if(event:sub(1, 7) == "PROFILE") then
				-- Profile related event.
				local _, subtype = ("_"):split(event);
				if(subtype == "LOADED" or subtype == "UNLOADED") then
					-- Profile changes require a full resync of all our widgets.
					PowerAuras:SetCurrentAura(nil);
				end
			end
		end);
		-- Fire the callbacks, then clear our loaded one.
		PowerAuras.OnOptionsEvent("OPTIONS_LOADED");
		PowerAuras.OnOptionsLoaded("OPTIONS_LOADED");
		PowerAuras.OnOptionsLoaded:Reset();
		-- Next, "modify" the OnOptionsLoaded callback. As we've been loaded,
		-- we need to set it to the Connect method immediately returns.
		function PowerAuras.OnOptionsLoaded:Connect(func)
			return func("OPTIONS_LOADED");
		end;
		-- Finally, update the LastVersion saved var.
		PowerAuras.GlobalSettings["LastVersion"] = PowerAuras.CurrentVersion;
	end
end);

--- Dictionary of all registered widget classes.
local Widgets = {};

--- Cached metatable for custom environments.
local envMT = { __index = PowerAuras };

--- Alters the environment of a class function to include a function named
--  "base" which calls the base-class equivalent of this function.
local function RegisterBaseFunction(class, key, func)
	-- Class needs a base class of course.
	if(not class["Base"]) then return; end
	-- Ensure this class has a base function of the same key.
	if(type(class["Base"][key]) == "function"
		and type(func) == "function") then
		-- Set the environment.
		setfenv(func, setmetatable({ base = class["Base"][key] }, envMT));
	end
end

local RegisterFrameScriptHandlers;

do
	--- Stores the toplevel class used by the frame.
	local frameClass = nil;

	--- Iterates over all functions in a class and its base classes to find
	--  any defined functions that serve as script handlers.
	-- @param frame The frame to attach script to.
	-- @param class The class to iterate over.
	function RegisterFrameScriptHandlers(frame, class)
		-- Needs scripting support.
		if(not frame.SetScript) then
			return;
		end
		-- Store class if toplevel.
		if(not frameClass) then
			frameClass = class;
		end
		-- Now handle this class.
		for key, func in pairs(class) do
			if(type(func) == "function" and frame:HasScript(key)
				and not frame:GetScript(key)) then
				-- Register. The logic here is a bit odd, we don't want to
				-- enable the OnEnter/OnLeave scripts present in the base
				-- Widget class if there's no OnTooltipShow method anywhere.
				-- Otherwise, we can attach the script.
				if(not (class == PowerAuras:GetWidget("Widget")
						and (key == "OnEnter" or key == "OnLeave")
						and not frameClass.OnTooltipShow)) then
					frame:SetScript(key, func);
				end
			end
		end
		-- Handle base class next.
		if(class["Base"]) then
			RegisterFrameScriptHandlers(frame, class["Base"]);
		end
		-- Clear frame class local.
		if(frameClass == class) then
			frameClass = nil;
		end
	end
end

--- Creates a new instance of a GUI widget.
-- @param name The class name of the widget to create.
-- @param ...  Additional arguments to pass to the constructor.
function PowerAuras:Create(name, ...)
	-- Validate the widget actually exists.
	if(not Widgets[name]) then
		error(L("GUIErrorWidgetClassMissing", name));
	end
	-- Call the constructor.
	local class = Widgets[name];
	local frame = class:New(...);
	if(not frame) then
		error(L("GUIErrorNoFrame", name));
	end
	-- Handle class script handlers.
	RegisterFrameScriptHandlers(frame, class);
	-- Properly set the metatable of the frame.
	local mt = getmetatable(frame);
	if(type(mt.__index) == "table") then
		setmetatable(frame, {
			--- Called when a missing key is looked for in the table.
			__index = function(self, key)
				if(key == "OnRecycled") then
					self.OnRecycled = PowerAuras.Callback();
					return self.OnRecycled;
				else
					return (key == "Class" and class
						or key == "ClassName" and class.ClassName
						or key:sub(1, 2) == "__" and mt.__index[key:sub(3)]
						or class["__index"] and class.__index(self, key, mt)
						or key ~= "New" and class[key]
						or mt.__index[key]);
				end
			end,
		});
	end
	-- Enable mouse interaction if tooltip script is present.
	if(frame.OnTooltipShow) then
		frame:EnableMouse(true);
	end
	-- Final initialisation.
	if(frame["Initialise"]) then
		frame:Initialise(...);
	end
	-- TODO: Test to see if this bug is dead.
	assert(frame.ClassName == class.ClassName,
		("Assert failed: frame.ClassName == class.ClassName (%s == %s)"):format(
			tostringall(frame.ClassName, class.ClassName)
		)
	);
	assert(frame.Class == class,
		("Assert failed: frame.Class == class (%s == %s)"):format(
			tostringall(frame.ClassName, class.ClassName)
		)
	);
	return frame;
end

--- Returns a widget class definition with the specified name, or errors out.
-- @param name The name of the widget class.
function PowerAuras:GetWidget(name)
	return Widgets[name] or error(L("ErrorWidgetClassMissing", name));
end
--- Checks if a widget class with the specified name has been loaded.
-- @param name The name of the widget class.
function PowerAuras:HasWidget(name)
	return not not Widgets[name];
end

--- Registers a new widget class for use in the GUI.
-- @param name     Name of the class.
-- @param inherits Name of a class to inherit. This may be omitted and instead
--                 used as the class parameter, if class is left as nil.
-- @param class    The class definition.
function PowerAuras:RegisterWidget(name, inherits, class)
	-- Allow skipping the inherits parameter.
	if(type(inherits) == "table" and not class) then
		class = inherits;
		inherits = nil;
	elseif(not class) then
		class = {};
	end
	-- Ensure ye name not be taken, yarr!
	if(Widgets[name]) then
		error(L("GUIErrorWidgetClassExists", name));
	end
	-- Ensure yer inheritin' a proper class there, yarr.
	if(inherits and not Widgets[inherits]) then
		error(L("GUIErrorWidgetClassMissing", inherits));
	end
	-- Be properly settin' the env fer functions!
	if(inherits) then
		-- Also be storin' yer base class in yer table!
		class["Base"] = Widgets[inherits];
		-- Be iteratin' over the key/values in yer class.
		for key, value in pairs(class) do
			RegisterBaseFunction(class, key, value);
		end
	end
	-- Store the name in the class!
	class["ClassName"] = name;
	-- Be creatin' the class!
	setmetatable(class, {
		__index = (inherits and class["Base"] or nil),
		__newindex = function(_, key, value)
			-- Is the value a function?
			if(type(value) == "function") then
				RegisterBaseFunction(class, key, value);
			end
			-- Set the value.
			rawset(class, key, value);
		end,
	});
	-- And now be registerin' the class!
	Widgets[name] = class;
	return class;
end