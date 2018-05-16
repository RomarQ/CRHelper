local MAJOR, MINOR = "LibPositionIndicator", 1
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end	--the same or newer version of this lib is already loaded into memory

-- Position Indicator
PLAYER_UNIT_TAG = "player"
ARROW = nil
REFRESH_TIME = 40

-- Target for arrow
-- Use lib:SetTargetUnitTag(tag) function to change it
local targetUnitTag = "player"

-- Functions

local function GetTexturePath()
	local textureIndex = CRHelper.savedVariables.positionIndicatorTexture or 1
	return CRHelper.name.."/texture/arrow"..textureIndex..".dds"
end

function lib:GetTargetUnitTag()
	return targetUnitTag
end

function lib:SetTargetUnitTag(tag)
	targetUnitTag = tag
end

function lib:CreateTexture()
	--[[
	The texture is defined here. To enable/disable the arrow, while using another scene,
	the parent is "RETICLE.control" and will turn off when the reticle is not visible.
	]]
	ARROW = WINDOW_MANAGER:CreateControl(CRHelper.name.."_Arrow", RETICLE.control, CT_TEXTURE)
	ARROW:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	ARROW:SetDrawLayer(1)
	ARROW:SetScale(CRHelper.savedVariables.positionIndicatorScale)
	ARROW:SetDimensions(128, 128)
	ARROW:SetTexture(GetTexturePath())
	-- ARROW:SetScale(1.25)
	ARROW:SetColor(unpack(CRHelper.savedVariables.positionIndicatorColor))
	ARROW:SetAlpha(CRHelper.savedVariables.positionIndicatorAlpha)
	-- Set the arrow hidden, because it has to make a few checks first.
	ARROW:SetHidden(true)
	-- Updates
	lib:ApplyStyle()
end

function lib:PostitionIndicatorShow()
	ARROW:SetHidden(false)
end

function lib:PostitionIndicatorHide()
	ARROW:SetHidden(true)
end

function lib:ApplyStyle()
	-- This function is used to apply a style to the position indicator when addon loads and when you choose a color in colorpicker.
	ARROW:SetColor(unpack(CRHelper.savedVariables.positionIndicatorColor))
	ARROW:SetTexture(GetTexturePath())
	ARROW:SetScale(CRHelper.savedVariables.positionIndicatorScale)
end

function lib:EndUpdate()
	-- Unsubscribes to [ UpdatePositionIndicator ] and set arrow texture hidden.
	EVENT_MANAGER:UnregisterForUpdate("UpdatePositionIndicator")
	ARROW:SetHidden(true)
end

local function GetDistancePlayerToPlayer(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local function AngleRotation(angle)
	return angle - 2*math.pi * math.floor( (angle + math.pi) / 2*math.pi )
end

local function GetRotationAngle(playerX, playerY, targetX, targetY)
	return AngleRotation(-1*(AngleRotation(GetPlayerCameraHeading()) - math.atan2(playerX-targetX, playerY-targetY)))
end

local function StartUpdate()
    
    -- Every REFRESH_TIME it updates the texture rotation.
    
	ARROW:SetHidden(true)
	EVENT_MANAGER:RegisterForUpdate(
        "UpdatePositionIndicator", 
        REFRESH_TIME, 
        function()

			local playerX, playerY = GetMapPlayerPosition(PLAYER_UNIT_TAG)
			local targetX, targetY = GetMapPlayerPosition(targetUnitTag)
			local distance = GetDistancePlayerToPlayer(playerX, playerY, targetX, targetY)

			if (distance < CRHelper.roaringFlareRadius) then
				ARROW:SetColor(0, 1, 0, 1)
			else
				ARROW:SetColor(unpack(CRHelper.savedVariables.positionIndicatorColor))
			end
			
			ARROW:SetTextureRotation(GetRotationAngle(playerX, playerY, targetX, targetY))

        end
    )
end

function lib:HandleUpdate()

	-- Starts the update control.

	if CRHelper.active and CRHelper.savedVariables.positionIndicatorEnabled and IsUnitGrouped( PLAYER_UNIT_TAG ) then
		StartUpdate()
		return
	end

	lib:EndUpdate()
end
