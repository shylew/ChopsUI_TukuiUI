--[[
Loader for 
	BalancePowerTracker_Pipe
	BalancePowerTracker_Options
	BalancePowerTracker_Log
--]]
if (select(2,UnitClass("player"))~="DRUID") then 
	return
end

local LoaderFrame = CreateFrame("Frame","BPTLoaderFrame",UIParent);
local addOns = {
	["BalancePowerTracker_Pipe"] = {
		nick = "PIPE",
		loaded = false,
		description = "Provides PowerAuras the ability to read BPT's values.\n Energy values are used like other PowerAuras resources.\n Eclipse Direction:\n   0: Unsued.\n   1: Moon.\n   2: None.\n   3: Sun.",
		priority = 3,
		global = "BPT_PIPE_STATUS",
	},
	["BalancePowerTracker_Log"] = {
		nick = "LOG",
		loaded = false,
		description = "Did you find a bug? Log it, please!",
		priority = 2,
		global = "BPT_LOG_STATUS",
	},
	["BalancePowerTracker_Options"] = {
		nick = "OPT",
		loaded = false,
		description = "BPT's Options were moved into a separate AddOn in order to free memory.",
		priority = 1,
		global = "BPT_OPT_STATUS",
	},
} 
local function checkAll()
	for k,v in pairs(addOns) do
		if GetAddOnInfo(k) then
			v.loaded = IsAddOnLoaded(k)
		end
	end
	if not BalancePowerTracker_DB then BalancePowerTracker_DB = {} end
	if not BalancePowerTracker_DB.modules then BalancePowerTracker_DB.modules = {} end

	local sthdone =false;
	
	local optionsTable = { 
		name	= "BalancePowerTracker Loader",
		type	= 'group',
		args	= {
		}
	}
	
	for k,v in pairs(addOns) do
		if select(4,GetAddOnInfo(k)) then
			if select(5,GetAddOnInfo(k)) and BalancePowerTracker_DB.modules[v.nick] and not IsAddOnLoaded(k) then 
				LoadAddOn(k) 
			end
			v.loaded = IsAddOnLoaded(k)
			
			optionsTable.args["header"..k] = {
				type	= 'header',
				name    = k,
				order = v.priority*10+0,
			}
			optionsTable.args["info"..k] = {
				type	= 'description',
				name	= v.description,
				order = v.priority*10+1,
			}
			optionsTable.args["load"..k]= {
				type	= 'execute',
				name	= "Load",
				desc	= "Load "..k,
				disabled = function() return IsAddOnLoaded(k) or not select(5,GetAddOnInfo(k)) end, 
				func	= function () LoadAddOn(k)  end,
				order = v.priority*10+2,
			}
			optionsTable.args["loadOnLog"..k]= {
				type	= 'toggle',
				name	= "Load on Login",
				desc	= "Enable/Disable loading "..k.." on login.",
				get		= function () return BalancePowerTracker_DB.modules[v.nick] end,
				set		= function () BalancePowerTracker_DB.modules[v.nick] = not BalancePowerTracker_DB.modules[v.nick]; end,
				order = v.priority*10+3,
			}
			if v.nick == "LOG" then
				optionsTable.args["Ok"..k]= {
					type	= 'execute',
					name	= "Show",
					desc	= "Show "..k.." UI",
					disabled = function() return not (LogBalancePowerTracker and _G[v.global]=="WORK") end, 
					func	= function () LogBalancePowerTracker.Show()  end,
					order = v.priority*10+4,
				}
			else
				optionsTable.args["Ok"..k]= {
					type	= 'toggle',
					name	= "Status OK",
					disabled = function() return true end,
					get		= function () return _G[v.global]=="WORK" end,
					set		= function () end,
					order = v.priority*10+4,
				}
			end
			sthdone=true;
		end
	end

	if sthdone then 
		LibStub("AceConfig-3.0"):RegisterOptionsTable("BPT Loader",optionsTable,nil)
		LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BPT Loader","BPT Loader")
	else
		BPTLoader = nil;
	end
end;
LoaderFrame:SetScript("OnEvent",checkAll);
LoaderFrame:RegisterEvent("PLAYER_LOGIN");

BPTLoader = {}
function BPTLoader.load(nickname)
	for k,v in pairs(addOns) do
		if v.nick==nickname then
			if select(4,GetAddOnInfo(k)) then
				if select(5,GetAddOnInfo(k)) and not IsAddOnLoaded(k) then 
					LoadAddOn(k) 
				end
				v.loaded = IsAddOnLoaded(k)
			end
		end
	end
end
function BPTLoader.loadAll()
	for k,v in pairs(addOns) do
		if select(4,GetAddOnInfo(k)) then
			if select(5,GetAddOnInfo(k)) and not IsAddOnLoaded(k) then 
				LoadAddOn(k) 
			end
			v.loaded = IsAddOnLoaded(k)
		end
	end
end
