-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Loads all auras.
function PowerAuras:LoadAuras()
	-- Load displays.
	for id, _ in self:GetAllDisplays() do
		self:LoadDisplay(id);
	end
	-- Load actions.
	for id, _ in self:GetAllActions() do
		self:LoadAction(id);
	end
	-- Notify the UI.
	self.OnOptionsEvent("AURAS_LOADED");
end

--- Completely unloads all of our auras, unloading displays, actions and
--  providers.
function PowerAuras:UnloadAuras()
	-- Clear GUI selections.
	if(PowerAuras.SetCurrentAura) then
		PowerAuras:SetCurrentAura(nil);
	end
	-- Start with the providers.
	local map = self:GetLoadedProviders();
	local id = next(map);
	while(id) do
		self:UnloadProvider(id);
		id = next(map, id);
	end
	-- Go to our displays.
	local map = self:GetLoadedDisplays();
	local id = next(map);
	while(id) do
		self:UnloadDisplay(id);
		id = next(map, id);
	end
	-- Move to actions.
	local map = self:GetLoadedActions();
	local id = next(map);
	while(id) do
		self:UnloadAction(id);
		id = next(map, id);
	end
	-- Notify the UI.
	self.OnOptionsEvent("AURAS_UNLOADED");
end

--- Upgrades all of the auras in the active profile.
-- @param version The version to upgrade from.
function PowerAuras:UpgradeAuras(version)
	-- Iterate over all auras.
	for id, aura in self:GetAllAuras() do
		-- Upgrade actions first.
		for i = 1, #(aura["Actions"]) do
			local action = aura["Actions"][i];
			if(self:HasActionClass(action["Type"])) then
				local class = self:GetActionClass(action["Type"]);
				-- Run over all the sequences.
				for j = 1, #(action["Sequences"]) do
					local sequence = action["Sequences"][j];
					class:Upgrade(version, sequence["Parameters"]);
				end
			end
			-- Upgrade the triggers.
			for j = 1, #(action["Triggers"]) do
				local tri = action["Triggers"][j];
				if(self:HasTriggerClass(tri["Type"])) then
					local class = self:GetTriggerClass(tri["Type"]);
					class:Upgrade(version, tri["Parameters"]);
				end
			end
		end
		-- Move on to displays.
		for i = 1, #(aura["Displays"]) do
			local display = aura["Displays"][i];
			if(self:HasDisplayClass(display["Type"])) then
				local class = self:GetDisplayClass(display["Type"]);
				class:Upgrade(version, display["Parameters"]);
			end

			-- Animations.
			local rootAnims = display.Animations;
			for _, atype in self:IterList("Static", "Triggered") do

				-- Static animations?
				if(atype == "Static") then
					for _, ctype in self:IterList("Show", "Hide") do
						local anim = rootAnims[atype][ctype];
						if(anim and self:HasAnimationClass(anim.Type)) then
							local cls = self:GetAnimationClass(anim.Type);
							cls:Upgrade(version, anim.Parameters);
						end
					end
				else
					-- Triggered.
					for _, ctype in self:IterList("Single", "Repeat") do
						for _, chan in ipairs(rootAnims[atype][ctype]) do
							for _, anim in ipairs(chan.Animations) do
								if(self:HasAnimationClass(anim.Type)) then
									local cls = self:GetAnimationClass(
										anim.Type
									);
									cls:Upgrade(version, anim.Parameters);
								end
							end
						end
					end
				end
			end
		end
		-- And now the providers.
		for i = 1, #(aura["Providers"]) do
			for int, svc in pairs(aura["Providers"][i]) do
				if(self:HasServiceClassImplemented(svc["Type"], int)) then
					local class = self:GetServiceClassImplementation(
						svc["Type"],
						int
					);
					class:Upgrade(version, svc["Parameters"]);
				end
			end
		end
	end
end