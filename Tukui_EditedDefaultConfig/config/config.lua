local C = {}

-- Override TukUI general settings.
C["general"] = {
  ["autoscale"] = false, -- Disable auto scaling.
  ["overridelowtohigh"] = true, -- Always use high resolution UI, regardless of screen resolution.
  ["bordercolor"] = { .36, .36, .36 }, -- Use a brighter border color than the default UI.
  ["blizzardreskin"] = false -- Don't reskin Blizzard frames.
}

-- Override TukUI unit frame settings.
C["unitframes"] = {
  ["cbicons"] = false, -- Disable cast bar icons.
  ["totdebuffs"] = true, -- Enable target-of-target debuffs.
  ["showtotalhpmp"] = true, -- Show total HP/MP on unit frames.
  ["maintank"] = true, -- Show main tank frames.
  ["onlyselfdebuffs"] = true, -- Only show own debuffs on target.
  ["weakenedsoulbar"] = false -- Disable the Weakened Soul bar.
}

-- Override TukUI aura settings.
C["auras"] = {
  ["flash"] = true -- Flash warning for buff with time < 30 seconds.
}

-- Override TukUI bag settings.
C["bags"] = {
  ["enable"] = false -- Disable the TukUI bags.
}

-- Override TukUI loot settings.
C["loot"] = {
  ["autogreed"] = false -- Disable auto-greed/auto-disenchant.
}

-- Override TukUI chat settings.
C["chat"] = {
  ["background"] = true -- Use background panels behind chat frames.
}

-- Override TukUI nameplate settings.
C["nameplate"] = {
  ["showhealth"] = true, -- Show health in name plates.
  ["enhancethreat"] = true -- Use threat-enhanced name plates.
}

-- Override TukUI invite settings.
C["invite"] = {
  ["autoaccept"] = false -- Disable auto-accepting group invites.
}

-- Make the configuration changes public.
TukuiEditedDefaultConfig = C
