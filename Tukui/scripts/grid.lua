if not IsAddOnLoaded("Grid") then return end

-----------------------------------------------------------------------
-- SETUP GRID POSITIONING
-----------------------------------------------------------------------
local GridLayout = Grid:GetModule("GridLayout")
local GridStatus = Grid:GetModule("GridStatus")
local GridFrame = Grid:GetModule("GridFrame")
local GridIndicatorCornerIcons = GridFrame:GetModule("GridIndicatorCornerIcons")
local GridStatusAurasExt = GridStatus:GetModule("GridStatusAurasExt")

if TukuiCF["general"].healer == true then

  -- Anchor the frames to the bottom center edge
  GridLayout.db.profile.anchorRel = "BOTTOM"
  GridLayout.db.profile.anchor = "BOTTOM"
  GridLayout.db.profile.groupAnchor = "BOTTOMLEFT"

  -- Set the appropriate width and height for the frames
  local totalWidth = TukuiDB.Scale(470)
  local frameWidth = math.floor(totalWidth / 5)
  GridFrame.db.profile.frameWidth = frameWidth
  GridFrame.db.profile.frameHeight = TukuiDB.Scale(50)

  -- Style the frame
  GridFrame.db.profile.cornerSize = 16

  -- Position the frame
  local gridYOffset = InvTukuiActionBarBackground:GetTop() + TukuiDB.Scale(11)
  if TukuiCF["actionbar"].bottomrows < 2 then
    gridYOffset = TukuiDB.Scale(94)
  end
  GridLayout.db.profile.PosX = 0
  GridLayout.db.profile.PosY = gridYOffset

else

  -- Anchor the frames to the bottom left corner
  GridLayout.db.profile.anchorRel = "BOTTOMLEFT"
  GridLayout.db.profile.anchor = "BOTTOMLEFT"
  GridLayout.db.profile.groupAnchor = "BOTTOMLEFT"

  -- Set the appropriate width and height for the frames
  local totalWidth = ChopsuiChatBackgroundLeft:GetWidth() + TukuiDB.Scale(8)
  local frameWidth = math.floor(totalWidth / 5)
  GridFrame.db.profile.frameWidth = frameWidth
  GridFrame.db.profile.frameHeight = TukuiDB.Scale(42)

  -- Style the frame
  GridFrame.db.profile.cornerSize = 14

  -- Position the frame
  GridLayout.db.profile.PosX = TukuiDB.Scale(7)
  GridLayout.db.profile.PosY = TukuiDB.Scale(119)
  
end
