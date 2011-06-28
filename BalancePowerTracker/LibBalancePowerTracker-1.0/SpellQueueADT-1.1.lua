-- Spell Queue ADT for Balance Druids
-- Created by Kurohoshi (Minahonda-EU)
-- v1.1.7
-- Can be used by any class, but it's designed for Balance Druids 
-- Designed to use in BalancePowerTracker and LibBalancePowerTracker

--[[Changelog:
v1.1.7: Removed SpecilaWR, no it's handled by LibBalancePowerTracker
v1.1.6: Fixed SpecialWR bug and 4.1 fix
		Changed SpellQueue:tonumber()
v1.1.5: Added SpellQueue:tonumber()
		Added SpellQueue.FromNumberToTable(number,t)
		Modified SpellQueue:tostring() to show abbreviations when able to.
v1.1.4: Added SpellQueue:RemoveAllSpellsById(id)
v1.1.3: Changed WRname to WRspellId
v1.1.2: Improved sWR calculation for missed wraths
		Added another field to store things (missChance)
		Code improved a little
		Changed special, if 0 then 14, else 13, but it stores specialWR (0,1,2) (Merged two vars)
--]]

local version = {1,1,7};

if (SpellQueueADT and SpellQueueADT:CompareVersion(version)) then return; end;

--Initialize Global Lib
SpellQueueADT = {};

function SpellQueueADT:CompareVersion(versionTable) --Returns false if versionTable is newer than version
	for i,v in ipairs(versionTable) do
		if version[i] < v then
			return false;
		end;
	end;
	return true;
end;
function SpellQueueADT:New()
	local SpellQueue = {}
	
	local lastSpellCasting = {n=false ,num=-1,s = false,mc=1}
	local flyingQueue = {queue={},last=0}

	function SpellQueue:BeginCastingSpell(name,num,missChance)
		lastSpellCasting.n=name
		lastSpellCasting.num=num
		lastSpellCasting.mc = missChance
		return true
	end

	function SpellQueue:FailedCastingSpell(num)
		if num ~= lastSpellCasting.num then return false end
		lastSpellCasting.n=false
		lastSpellCasting.num=-1
		lastSpellCasting.mc = 1
		return true
	end
	
	function SpellQueue:InterruptedCastingSpell(id)
		if id ~= lastSpellCasting.n then return false end
		lastSpellCasting.n=false
		lastSpellCasting.num=-1
		lastSpellCasting.mc = 1
		return true
	end
	
	function SpellQueue:FinishCastingSpell(name,num,missChance) --returns true if it was an instant spell
		if num ~= lastSpellCasting.num then --Instant
			self:AddInstantSpell(name,specialWR,missChance)
			
			lastSpellCasting.n=false
			lastSpellCasting.num=-1
			lastSpellCasting.mc = 1
			return true
		else --Casted
			self:AddInstantSpell(lastSpellCasting.n,lastSpellCasting.mc)
						
			lastSpellCasting.n=false
			lastSpellCasting.num=-1
			lastSpellCasting.mc = 1
			return false
		end
	end
	
	function SpellQueue:AddInstantSpell(name,missChance)
		local last = flyingQueue.last + 1
		flyingQueue.last=last
		flyingQueue.queue[last]={n=name,t=GetTime(),mc=missChance};
		return true
	end
		
	function SpellQueue:RemoveFlyingSpell(name)
		local v
		for i = 1, flyingQueue.last do
			v = flyingQueue.queue[i]
			if v.n == name then
				local last = flyingQueue.last-1
				flyingQueue.last=last
				
				for j=i,last do
					flyingQueue.queue[j]=flyingQueue.queue[j+1]
				end
				
				return true
			end
		end
		return false
	end
	
	function SpellQueue:RemoveTimedOutFlyingSpell(timeFlying)
		local timeOrigin = GetTime()-timeFlying
		local v
		for i = 1, flyingQueue.last do
			v = flyingQueue.queue[i]
			if v.t >= (timeOrigin) then
				if i == 1 then return true end
				
				for j=1,flyingQueue.last do
					flyingQueue.queue[j]=flyingQueue.queue[j+i-1]
				end
				
				flyingQueue.last = flyingQueue.last-i +1				
				
				return true
			end
		end
		flyingQueue = {queue={},last=0}
		return true
	end

	function SpellQueue:RemoveAllSpellsById(id)
		local ret,v = false
		for i = 1, flyingQueue.last do
			v = flyingQueue.queue[i]
			if v.n == id then
				flyingQueue.last = flyingQueue.last-1
			
				for j=i,flyingQueue.last do
					flyingQueue.queue[j]=flyingQueue.queue[j+1]
				end
				ret=true;
			end
		end
		return ret
	end

	function SpellQueue:Clear()
		flyingQueue = {queue={},last=0}
		lastSpellCasting.n=false
		lastSpellCasting.num=-1
		lastSpellCasting.mc = 1
		return true
	end

	do
		local abbrev = {[5176]="WR",	[2912]="SF",[78674]="SS"}
		local index = {[5176]=0,	[2912]=1,	[78674]=2}
		local revex = {[3]=false,[2]=78674,[1]=2912,[0]=5176}
		local offset ={[0] = 0,[1] = 3,[2] = 12,[3] = 39,[4] = 120,[5] = 363}
		
		function SpellQueue:tostring()
			local temp = ""
			local v,w
			
			for i = 1, flyingQueue.last do
				v = flyingQueue.queue[i]
				w = abbrev[v.n] 
				if w then
					temp = i..w..temp
				else
					temp = i..":"..v.n..";"..temp
				end
			end
			
			if lastSpellCasting.n then
				w = abbrev[lastSpellCasting.n]
				if w then	temp = "C"..w..temp
				else		temp = "C: "..lastSpellCasting.n..";"..temp
				end
			else			temp = "C-"..temp
			end
			return temp
		end
		
		function SpellQueue:tonumber()
			if flyingQueue.last <= 0 then return (index[lastSpellCasting.n] or 3) end

			local ac = offset[flyingQueue.last-1] or 120;
			local w
			
			for i = 0, flyingQueue.last-1 do
				w = index[flyingQueue.queue[i+1].n] 
				if w then
					ac = ac + w*(3^i)
				end
			end
			
			return (ac+1)*4+(index[lastSpellCasting.n] or 3)
		end
		
		function SpellQueue.FromNumberToTable(number,temp)
			if (not temp) or type(temp) ~= "table" then temp = {} end
			
			local resto = number % 4
			temp[0]=revex[resto]
			number = (number-resto)/4
			
			local numberOfSpells = 0
			for i=0,4 do
				if number > offset[i] then
					numberOfSpells = i+1
				end
			end
			for indice = 1,5 do
				temp[indice]=nil
			end
			
			if numberOfSpells==0 then 
				--if temp[0] then print("Cast: "..select(1,GetSpellInfo(temp[0]))) end
				return temp
			end
			
			number = number - offset[numberOfSpells-1]-1
						
			for indice = 1,numberOfSpells do 
				resto = number % 3
				temp[indice]=revex[resto]
				number=(number-resto)/3
			end
			
			--for k,v in ipairs(temp) do print(k..": "..select(1,GetSpellInfo(v))) end 
			--if temp[0] then print("Cast: "..select(1,GetSpellInfo(temp[0]))) end
			return temp
		end
	end
	
	function SpellQueue:First()
		if flyingQueue.last >0 then
			return flyingQueue.queue[1].n,flyingQueue.queue[1].mc;
		end
	end
	
	function SpellQueue:iterator ()
		local i,n = 0,flyingQueue.last;
		return 	function () --function next()
					i = i + 1;
					if i <= n then return flyingQueue.queue[i];
					elseif i == n+1 and lastSpellCasting.n then return lastSpellCasting;
					end
				end
    end
	
	return SpellQueue
end
