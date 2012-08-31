-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

-- Modules.
local Metadata = PowerAuras:GetModules("Metadata");

--- Current style editor category.
local CurrentStyle = nil;

--- Current selected service (custom).
local CurrentService = nil;

--- Called when the service type dropdown is updated.
-- @param menu The menu frame.
-- @param key  The selected key.
local function OnManualServiceUpdated(menu, key)
	-- Update and refresh.
	CurrentService = key;
	menu:GetParent():GetParent():UpdatePage();
end

--- Called when the service class dropdown is updated.
-- @param menu The menu frame.
-- @param key  The selected key.
local function OnManualTypeUpdated(menu, key)
	-- Delete any existing interfaces of the current type on the provider.
	local pID = menu:GetID();
	PowerAuras:DeleteAuraProviderService(pID, CurrentService);
	-- Now create the new one and refresh.
	if(key ~= -1) then
		PowerAuras:CreateAuraProviderService(pID, CurrentService, key);
	end
end

--- Called when an optional source checkbox is toggled.
-- @param check The checkbox frame.
-- @param state The checked state.
local function OnOptSourceToggled(check, state)
	-- Get the current source flags.
	local optFlag = check:GetID();
	local _, id = PowerAuras:GetCurrentDisplay();
	local vars = PowerAuras:GetAuraDisplay(id);
	local optFlags = bit.band(vars["Flags"], Metadata.DISPLAY_OPTMASK);
	-- Are we enabling or disabling?
	if(state) then
		Metadata:SetDisplayFlags(id, bit.bor(optFlags, optFlag), "Opt");
	else
		Metadata:SetDisplayFlags(
			id,
			bit.band(optFlags, bit.bnot(optFlag)),
			"Opt"
		);
	end
	-- Update frame.
	check:GetParent():GetParent():UpdatePage();
end

--- Called when the source configuration mode is changed.
-- @param menu The menu frame.
-- @param key  The selected key.
local function OnSourceConfigModeChanged(menu, key)
	-- Close all menus.
	menu:CloseMenu();
	-- Update the mode and the pane.
	Metadata:SetDisplayFlags(menu:GetID(), key, "Source");
	menu:GetParent():GetParent():GetParent():UpdatePage();
end

--- Called when the chosen trigger ID has changed.
-- @param edit  The editbox widget.
-- @param value The selected value.
local function OnSourceTriggerChanged(edit, value)
	-- Update.
	local flags = PowerAuras:GetAuraDisplay(edit:GetID())["Flags"];
	Metadata:SetDisplayFlags(
		edit:GetID(),
		Metadata:SetFlagID(flags, value, "Trigger")
	);
	edit:GetParent():GetParent():UpdatePage();
end

--- Callback for when the active style category changes.
-- @param frame The list frame.
-- @param pane  The content frame.
-- @param key   The selected category key.
local function OnStyleContentRefreshed(frame, pane, key)
	-- Store key.
	CurrentStyle = key;
	local _, id = PowerAuras:GetCurrentDisplay();
	if(not key or not PowerAuras:HasAuraDisplay(id)) then
		return;
	end
	-- Population: Frames.
	local vars = PowerAuras:GetAuraDisplay(id);
	if(key == 0) then
		-- Style.
		local class = PowerAuras:GetDisplayClass(vars.Type);
		class:CreateStyleEditor(pane, id);
		pane:AddRow(4);

		-- Add options for optional sources.
		local flags = vars.Flags;
		local fTri = Metadata:GetFlagID(flags, "Trigger");
		local aID = vars.Actions["DisplayActivate"];
		local aVars = PowerAuras:GetAuraAction(aID);
		local tri = aVars.Triggers[fTri];
		if(tri) then
			-- Determine the supported conversions from this trigger.
			local tClass = PowerAuras:GetTriggerClass(tri.Type);
			for int, req in pairs(class:GetAllServices()) do
				local name = tClass:SupportsServiceConversion(int);
				if(name and not req) then
					-- Add a checkbox for it.
					local check = PowerAuras:Create("Checkbox", pane);
					check:SetRelativeWidth(1.0);
					check:SetPadding(4, 0, 4, 0);
					if(rawget(L["ServiceClasses"], tri.Type)) then
						check:SetText(L["ServiceClasses"][tri.Type][int]);
					else
						check:SetText(L["ServiceClasses"][name][int]);
					end
					-- Disable if required.
					check:SetEnabled(not req);
					-- Check the box if needed.
					local opt = Metadata["DISPLAY_OPT_" .. int:upper()];
					check:SetChecked((bit.band(vars["Flags"], opt) > 0));
					-- Callback handling.
					check:SetID(opt);
					check.OnValueUpdated:Connect(OnOptSourceToggled);
					-- Add to frame.
					pane:AddWidget(check);
				elseif(not name and req) then
					break;
				end
			end
		end
	elseif(key == 1) then
		-- Layout.
		local lVars = PowerAuras:GetLayout(vars["Layout"]["ID"]);
		local lClass = PowerAuras:GetLayoutClass(lVars["Type"]);
		lClass:CreateDisplayEditor(pane, id);
	elseif(key == 2) then
		-- Super-advanced display options.
		local class = PowerAuras:GetDisplayClass(vars["Type"]);
		if(class.CreateAdvancedStyleEditor) then
			class:CreateAdvancedStyleEditor(pane, id);
		end
		-- Source options. These vary based upon the metadata flags.
		local flags = vars["Flags"];
		local sFlags = bit.band(flags, Metadata.DISPLAY_SOURCEMASK);
		if(sFlags == Metadata.DISPLAY_SOURCE_AUTO
			or sFlags == Metadata.DISPLAY_SOURCE_TRIGGER) then

			-- Extract trigger ID.
			local fTri = Metadata:GetFlagID(flags, "Trigger");
			local aID = vars.Actions["DisplayActivate"];
			local aVars = PowerAuras:GetAuraAction(aID);
			local tri = aVars["Triggers"][fTri];

			-- Get services used by the display.
			local class = PowerAuras:GetDisplayClass(vars["Type"]);
			local services = class:GetAllServices();

			-- Allow picking a trigger ID in Trigger mode.
			local labelPl, labelMt = 4, 0;
			if(sFlags == Metadata.DISPLAY_SOURCE_TRIGGER) then
				-- Add numberbox for this.
				local box = PowerAuras:Create("NumberBox", pane);
				box:SetPadding(4, 0, 2, 0);
				box:SetRelativeWidth(0.25);
				box:SetTitle(L["Trigger"]);
				box:SetMinMaxValues(0, PowerAuras.MAX_TRIGGERS_PER_ACTION);
				box:SetValueStep(1);
				box:SetValue(fTri);
				box:SetID(id);
				box.OnValueUpdated:Connect(OnSourceTriggerChanged);
				-- Add widget to frame.
				pane:AddWidget(box);
				labelPl = 2;
				labelMt = 20;
			end

			-- Add label to tell the user what trigger is being used.
			local lab = PowerAuras:Create("Label", pane);
			lab:SetRelativeWidth(0.75);
			lab:SetFixedHeight(24);
			lab:SetPadding(labelPl, 0, 4, 0);
			lab:SetMargins(0, labelMt, 0, 0);
			lab:SetFontObject(GameFontHighlight);
			lab:SetJustifyH("LEFT");
			lab:SetJustifyV("MIDDLE");
			lab:SetText(L("UsingTrigger",
				fTri,
				tri and L["TriggerClasses"][tri["Type"]]["Name"]
					or _G.NONE
			));
			pane:AddWidget(lab);
			pane:AddRow(4);

			-- Add checkboxes for source types.
			local invalidTrigger = (not tri);
			if(tri) then
				-- Determine the supported conversions from this trigger.
				local tClass = PowerAuras:GetTriggerClass(tri["Type"]);
				for int, req in pairs(services) do
					local name = tClass:SupportsServiceConversion(int);
					if(name) then
						-- Add a checkbox for it.
						local check = PowerAuras:Create("Checkbox", pane);
						check:SetRelativeWidth(1.0);
						check:SetPadding(4, 0, 4, 0);
						check:SetText(L["ServiceClasses"][name][int]);
						-- Disable if required.
						check:SetEnabled(not req);
						-- Check the box if needed.
						local opt = Metadata["DISPLAY_OPT_" .. int:upper()];
						check:SetChecked((bit.band(vars["Flags"], opt) > 0));
						-- Callback handling.
						check:SetID(opt);
						check.OnValueUpdated:Connect(OnOptSourceToggled);
						-- Add to frame.
						pane:AddWidget(check);
					elseif(not name and req) then
						-- If this occurs, we've selected an invalid trigger.
						invalidTrigger = true;
						break;
					end
				end
			end
		end
	end
end

--- Creates the style and layout editor pane.
-- @param frame The frame to apply widgets to.
-- @param node  The currently selected node.
function PowerAuras:CreateStyleEditor(frame, node)
	-- Get the display.
	local _, id = self:SplitNodeID(node);
	local vars = self:GetAuraDisplay(id);
	-- Construct the sections list.
	local list = PowerAuras:Create("ListInlay", frame);
	list:SetRelativeSize(1.0, 1.0);
	list:SetPadding(-3, -6, -6, -8);
	list:PauseLayout();
	-- Add subcategories.
	list:AddItem(0, L["Style"]);
	list:AddItem(1, L["LayoutPositioning"]);
	-- Default to the style section unless told otherwise.
	list:SetCurrentItem(CurrentStyle or 0);
	-- Connect to callbacks.
	list.OnContentRefreshed:Connect(OnStyleContentRefreshed);
	list:ResumeLayout();
	frame:AddWidget(list);
end