-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class definition.
local WeaponEnchant = PowerAuras:RegisterTriggerClass("WeaponEnchant", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		-- Each slot is a match.
		[1] = PowerAuras:EncodeMatch({
			[0] = {
				Effect = "<Enchant Name>",
				Charges = 0,
				ChargesOp = ">=",
				Expires = 0,
				ExpiresOp = ">=",
			},
			[1] = {},
		}),
		[2] = PowerAuras:EncodeMatch({
			[0] = {
				Effect = "<Enchant Name>",
				Charges = 0,
				ChargesOp = ">=",
				Expires = 0,
				ExpiresOp = ">=",
			},
			[1] = {},
		}),
	},
	--- Dictionary of events this trigger responds to.
	Events = {},
	--- Dictionary of provider services required by this trigger type.
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
-- @param params The parameters to construct the trigger from.
function WeaponEnchant:New(params)
	-- Decode the matches.
	local slots = PowerAuras:CopyTable(params);
	slots[1] = PowerAuras:DecodeMatch(slots[1], true);
	slots[2] = PowerAuras:DecodeMatch(slots[2], true);

	-- We store enchant data determined in execution in some tables.
	local enchantData = { [1] = {}, [2] = {} };

	-- Upvalues.
	local tooltip = PowerAuras.ScanTooltip;

	-- Generate the function.
	return function(self, buffer, action, store)
		-- Check the enchant.
		for i = 1, 6, 3 do
			local state, exp, charge = select(i, GetWeaponEnchantInfo());
			local matches = slots[(i + 2) / 3];
			local data = enchantData[(i + 2) / 3];
			wipe(data);
			-- Set up the tooltip for scanning.
			tooltip:SetOwner(UIParent, "ANCHOR_NONE");
			tooltip:SetInventoryItem("player", 15 + ((i + 2) / 3));

			-- Check the matches.
			local found = false;
			for i = 1, #(matches) do
				local match = matches[i];
				local mEffect, mC, mCOp, mExp, mEOp = 
					match.Effect, match.Charges, match.ChargesOp,
					match.Expires, match.ExpiresOp;

				-- Inverted match?
				local mInv = false;
				if(mEffect:sub(1, 1) == "!") then
					mInv, mEffect = true, mEffect:sub(2);
				end

				-- Find the effect.
				if(not state) then
					-- No need to check.
					exists = false;
				else
					-- Scan the tooltip.
					for _, left, right in PowerAuras:GetTooltipLines() do
						-- Check the tooltip lines.
						local exists = left:find(mEffect, 1, true)
							or right:find(mEffect, 1, true);
						-- Got it?
						if(exists) then
							-- Test charges/expiration.
							found = (PowerAuras:CheckOperator(charge, mCOp, mC)
								and PowerAuras:CheckOperator(
									exp / 1000, mEOp, mExp
								));

							-- Still good? I hope so. Update our stored data.
							if(found) then
								data.Name = (left:find(mEffect, 1, true)
									and left
									or right);
								data.Expires = exp;
								data.Charges = charge;
							end

							-- Exit on the first hit.
							break;
						end
					end
				end

				-- Did we fail to find it, but if so are we inverted?
				if(not found and mInv) then
					found = true;
				elseif(found and mInv) then
					-- We found it, but we didn't want to.
					found = false;
				end

				-- Can we break yet?
				if(found) then
					break;
				end
			end

			-- Hide the tooltip again.
			tooltip:Hide();

			-- Did we fail that check?
			if(not found) then
				return false;
			end
		end

		-- Getting here indicates success. Determine which of our matched
		-- effects expires first.
		local exp, index = math.huge, 0;
		for i = 1, #(enchantData) do
			local data = enchantData[i];
			if(data.Expires and data.Expires < exp) then
				index = i;
				exp = data.Expires;
			end
		end

		-- So which was it?
		if(index > 0) then
			local data = enchantData[index];
			-- Update the store.
			store.Text["name"] = data.Name;
			store.Texture      = GetInventoryItemTexture("player", 15 + index);
			store.Stacks       = data.Charges;
			store.TimerStart   = 0;
			store.TimerEnd     = data.Expires / 1000;
		else
			store.Text["name"] = "";
			store.Texture      = nil;
			store.Stacks       = nil;
			store.TimerStart   = nil;
			store.TimerEnd     = nil;
		end
		return true;
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function WeaponEnchant:CreateTriggerEditor(frame, ...)
	-- Match box for each slot.
	local mainHand = PowerAuras:Create("WeaponEnchantDialog", frame,
		"Trigger", 1, ...);
	mainHand:SetUserTooltip("WeaponEnchant_MainHand");
	mainHand:SetTitle(L["MainHand"]);
	mainHand:SetRelativeWidth(0.5);
	mainHand:SetPadding(4, 0, 2, 0);
	mainHand:SetText(PowerAuras:GetParameter("Trigger", 1, ...));
	mainHand:ConnectParameter("Trigger", 1, mainHand.SetText, ...);
	mainHand.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", 1, value, ${...});
	]], ...));
	frame:AddWidget(mainHand);

	local offHand = PowerAuras:Create("WeaponEnchantDialog", frame,
		"Trigger", 2, ...);
	offHand:SetUserTooltip("WeaponEnchant_OffHand");
	offHand:SetTitle(L["OffHand"]);
	offHand:SetRelativeWidth(0.5);
	offHand:SetPadding(4, 0, 2, 0);
	offHand:SetText(PowerAuras:GetParameter("Trigger", 2, ...));
	offHand:ConnectParameter("Trigger", 2, offHand.SetText, ...);
	offHand.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", 2, value, ${...});
	]], ...));
	frame:AddWidget(offHand);
end

--- Initialises the per-trigger data store. This can be used to hold
--  values which can then be exposed to other parts of the system.
-- @param params The parameters of this trigger.
-- @return An item to store, or nil.
function WeaponEnchant:InitialiseDataStore()
	return {
		TimerStart = 0,
		TimerEnd = 2^31 - 1,
		Texture = PowerAuras.DefaultIcon,
		Stacks = 0,
		Text = {
			["name"] = "",
		},
	};
end

--- Determines whether or not a trigger requires per-frame updates.
-- @param params The parameters of the trigger.
-- @return True if updates are required, false if not.
-- @return The first value is the default timed state on creation. The 
--         second boolean is whether or not the timed status is capable of
--         being toggled by the trigger.
function WeaponEnchant:IsTimed(params)
	return true, false;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function WeaponEnchant:Upgrade(version, params)
end

-- Listen to UI options creation.
PowerAuras.OnOptionsLoaded:Connect(function()

	--- Dialogbox widget for WeaponEnchant matches.
	local Box = PowerAuras:RegisterWidget("WeaponEnchantDialog", "DialogBox");

	--- Initialises the widget.
	-- @param parent The parent of the editbox.
	-- @param ...    The ID's to use for Get/SetParameter calls.
	function Box:Initialise(parent, ...)
		-- Initialise as normal, connect to OnDialogOpened.
		base(self, parent, PowerAuras.Editor, "ModalDialog");
		self.OnDialogOpened:Connect(self.OnDialogCreated);
		self:SetEditable(false);
		-- Store parameter ID's.
		self.ParamType, self.ParamKey, self.ParamID1, self.ParamID2 = ...;
	end

	--- Called when the dialog frame is created.
	-- @param dialog The dialog frame.
	-- @param keep   Keeps the stored setting data.
	function Box:OnDialogCreated(dialog)
		-- Update settings?
		if(not keep) then
			local pt, id1, id2 = self.ParamType, self.ParamID1, self.ParamID2;
			self.Vars = PowerAuras:DecodeMatch(
				PowerAuras:GetParameter(pt, self.ParamKey, id1, id2)
					or WeaponEnchant.Parameters.Matches[self.ParamKey]
			);
		end

		-- Get the layout host frame and position it.
		local host = dialog.Host;
		host:SetPoint("TOPLEFT", 32, -32);
		host:SetPoint("BOTTOMRIGHT", -32, 32);
		host:SetContentPadding(6, 6, 6, 6);
		host:ClearWidgets();

		-- Add the match navigation tree.
		local tree = PowerAuras:Create("TreeView", host);
		tree:SetFixedWidth(170);
		tree:SetRelativeHeight(1.0);
		tree:SetMargins(0, 0, 0, -32);
		tree:SetPadding(0, 0, 0, 32);
		self:ConnectCallback(tree.OnCurrentNodeChanged, self.OnNodeChanged, 2);
		host:AddWidget(tree);
		host:AddRow(4);

		-- Cancel/Save buttons.
		local cancel = PowerAuras:Create("Button", host);
		cancel:SetText(L["Cancel"]);
		dialog:ConnectCallback(cancel.OnClicked, dialog.Cancel);
		host:AddStretcher();
		host:AddWidget(cancel);

		local apply = PowerAuras:Create("Button", host);
		apply:SetText(L["Apply"]);
		apply.OnClicked:Connect(function()
			-- Accept the dialog.
			dialog:SetAcceptData(
				PowerAuras:EncodeMatch(PowerAuras:CopyTable(self.Vars))
			);
			dialog:Accept();
		end);
		host:AddWidget(apply);

		-- Create our spare layout host if needed.
		if(not self.ControlHost) then
			self.ControlHost = PowerAuras:Create("LayoutHost", self);
			self.ControlHost:SetContentPadding(8, 8, 8, 8);
		end
		-- Position control host.
		local controls = self.ControlHost;
		controls:ClearAllPoints();
		controls:SetParent(host);
		controls:SetPoint("TOPLEFT", host, 178, -6);
		controls:SetPoint("BOTTOMRIGHT", host, -6, 38);
		controls:SetFrameStrata(host:GetFrameStrata());
		controls:Show();

		-- Tool host.
		if(not self.ToolHost) then
			self.ToolHost = PowerAuras:Create("LayoutHost", self);
			self.ToolHost:SetContentPadding(4, 4, 4, 4);
		end
		-- Position control host.
		local tools = self.ToolHost;
		tools:ClearAllPoints();
		tools:SetParent(host);
		tools:SetPoint("BOTTOMLEFT", host, 6, 6);
		tools:SetSize(170, 32);
		tools:SetFrameStrata(host:GetFrameStrata());
		tools:Show();

		-- Populate the tree.
		tree:PauseLayout();
		tree:AddNode(0, L["Defaults"]);
		tree:AddNode(-1, L["Matches"], nil, true, false, true);
		for i = 1, #(self.Vars) do
			tree:AddNode(i, L("MatchID", i), -1);
		end
		-- Select node #1 if it exists.
		if(tree:HasNode(1)) then
			tree:SetCurrentNode(1);
		elseif(tree:HasNode(0)) then
			-- Defaults are just as good as any.
			tree:SetCurrentNode(0);
		end
		tree:OnCurrentNodeChanged(tree:GetCurrentNode());
		tree:ResumeLayout();

		-- Remove our controls when the dialog is recycled.
		dialog.OnRecycled:Connect(function()
			self.ControlHost:ClearAllPoints();
			self.ControlHost:Hide();
			self.ControlHost:ClearWidgets();
			self.ToolHost:ClearAllPoints();
			self.ToolHost:Hide();
			self.ToolHost:ClearWidgets();
		end);
	end

	--- Called when the treeview node changes.
	-- @param node The selected node ID.
	function Box:OnNodeChanged(node)
		-- Discard if root. Should be impossible to get to it, but be safe.
		if(node == "__ROOT__") then
			return;
		end
		-- Reset the controls in our frame.
		local host = self.ControlHost;
		host:PauseLayout();
		host:ClearWidgets();

		-- Repopulate the container. Start with effect name.
		local effect = PowerAuras:Create("EditBox", host);
		effect:SetUserTooltip("UnitAura_Match");
		effect:SetSaveOnChange(true);
		effect:SetPadding(4, 0, 4, 0);
		effect:SetRelativeWidth(1.0);
		effect:SetTitle(L["UnitAura_Match"]);
		effect:SetText(self.Vars[node].Effect or "");
		effect.OnValueUpdated:Connect(function(ctrl, value)
			self.Vars[node].Effect = tostring(value or "");
			ctrl:SetText(self.Vars[node].Effect);
		end);
		host:AddWidget(effect);
		host:AddRow(4);

		-- Stacks matching.
		local h1 = PowerAuras:Create("Header", host);
		h1:SetText(L["Stacks"]);
		host:AddWidget(h1);

		-- Stacks operator.
		local op = PowerAuras:Create("SimpleDropdown", host);
		op:SetUserTooltip("Operator");
		op:SetPadding(4, 0, 2, 0);
		op:SetRelativeWidth(1 / 2);
		op:SetTitle(L["Operator"]);
		for i = 1, #(PowerAuras.Operators) do
			op:AddCheckItem(PowerAuras.Operators[i], PowerAuras.Operators[i]);
		end
		op:SetItemChecked(self.Vars[node].ChargesOp, true);
		op:SetText(self.Vars[node].ChargesOp);
		op.OnValueUpdated:Connect(function(ctrl, value)
			ctrl:CloseMenu();
			ctrl:SetItemChecked(self.Vars[node].ChargesOp, false);
			self.Vars[node].ChargesOp = value;
			ctrl:SetItemChecked(self.Vars[node].ChargesOp, true);
			ctrl:SetText(self.Vars[node].ChargesOp);
		end);
		host:AddWidget(op);

		-- Stacks count.
		local count = PowerAuras:Create("NumberBox", host);
		count:SetUserTooltip("UnitAura_Count");
		count:SetPadding(2, 0, 2, 0);
		count:SetRelativeWidth(1 / 2);
		count:SetTitle(L["Count"]);
		count:SetMinMaxValues(0, 2^31 - 1);
		count:SetValueStep(1);
		count:SetValue(self.Vars[node].Charges);
		count.OnValueUpdated:Connect(function(ctrl, value)
			self.Vars[node].Charges = (tonumber(value) or 0);
			ctrl:SetValue(self.Vars[node].Charges);
		end);
		host:AddWidget(count);

		-- Time matching.
		local h2 = PowerAuras:Create("Header", host);
		h2:SetText(L["TimeRemaining"]);
		host:AddWidget(h2);

		-- Time operator.
		local op = PowerAuras:Create("SimpleDropdown", host);
		op:SetUserTooltip("Operator");
		op:SetPadding(4, 0, 2, 0);
		op:SetRelativeWidth(1 / 2);
		op:SetTitle(L["Operator"]);
		for i = 1, #(PowerAuras.Operators) do
			op:AddCheckItem(PowerAuras.Operators[i], PowerAuras.Operators[i]);
		end
		op:SetItemChecked(self.Vars[node].ExpiresOp, true);
		op:SetText(self.Vars[node].ExpiresOp);
		op.OnValueUpdated:Connect(function(ctrl, value)
			ctrl:CloseMenu();
			ctrl:SetItemChecked(self.Vars[node].ExpiresOp, false);
			self.Vars[node].ExpiresOp = value;
			ctrl:SetItemChecked(self.Vars[node].ExpiresOp, true);
			ctrl:SetText(self.Vars[node].ExpiresOp);
		end);
		host:AddWidget(op);

		-- Time count.
		local count = PowerAuras:Create("NumberBox", host);
		count:SetUserTooltip("WeaponEnchant_Count");
		count:SetPadding(2, 0, 2, 0);
		count:SetRelativeWidth(1 / 2);
		count:SetTitle(L["Count"]);
		count:SetMinMaxValues(0, 2^31 - 1);
		count:SetValueStep(1);
		count:SetValue(self.Vars[node].Expires);
		count.OnValueUpdated:Connect(function(ctrl, value)
			self.Vars[node].Expires = (tonumber(value) or 0);
			ctrl:SetValue(self.Vars[node].Expires);
		end);
		host:AddWidget(count);

		-- Resume the layout.
		host:ResumeLayout();

		-- Now redo the tools!
		local tools = self.ToolHost;
		tools:PauseLayout();
		tools:ClearWidgets();

		-- Add Match button.
		local add = PowerAuras:Create("IconButton", tools);
		add:SetIcon([[Interface\PaperDollInfoFrame\Character-Plus]]);
		add.OnClicked:Connect(function()
			tinsert(self.Vars, PowerAuras:CopyTable(self.Vars[0]));
			-- Hackish reset.
			self:OnDialogCreated(self.Dialog, true);
			-- Even more hackish selection.
			self.Dialog.Host.Widgets[1]:SetCurrentNode(#(self.Vars));
			self.Dialog.Host.Widgets[1]:OnCurrentNodeChanged(#(self.Vars));
		end);
		tools:AddWidget(add);

		-- Delete Match button.
		if(node > 0) then
			local delete = PowerAuras:Create("IconButton", tools);
			delete:SetIcon([[Interface\PetBattles\DeadPetIcon]]);
			delete.OnClicked:Connect(function()
				tremove(self.Vars, node);
				-- Hackish reset.
				self:OnDialogCreated(self.Dialog, true);
			end);
			tools:AddStretcher();
			tools:AddWidget(delete);
		end

		tools:ResumeLayout();
	end

	--- Recycles the frame, allowing it to be reused.
	function Box:Recycle()
		-- Recycle as normal, after hiding our control/tools host.
		if(self.ControlHost) then
			self.ControlHost:ClearAllPoints();
			self.ControlHost:Hide();
		end
		if(self.ToolHost) then
			self.ToolHost:ClearAllPoints();
			self.ToolHost:Hide();
		end
		base(self);
	end

end);