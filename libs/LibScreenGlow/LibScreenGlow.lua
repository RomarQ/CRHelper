local MAJOR, MINOR = "LibScreenGlow", 1
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end	--the same or newer version of this lib is already loaded into memory

local wm = GetWindowManager() 

local glowWindow = wm:CreateTopLevelWindow("GlowWindow")
local glowLeft, glowRight, glowTop, glowBottom

local glowSize
local glowR, glowG, glowB

local glowAlphaStart = 0.9
local glowAlphaEnd = 0

local function CreateGlow()

	glowWindow:SetAnchorFill(GuiRoot)
	glowWindow:SetDrawLayer(DL_BACKGROUND)
	glowWindow:SetMouseEnabled(false)
	glowWindow:SetAlpha(1)

	glowLeft = wm:CreateControl(nil, glowWindow, CT_TEXTURE)
	glowLeft:SetPixelRoundingEnabled(false)
	glowLeft:SetAnchor(TOPLEFT, glowWindow, TOPLEFT, 0, 0)
	glowLeft:SetHidden(true)
	
	glowRight = wm:CreateControl(nil, glowWindow, CT_TEXTURE)
	glowRight:SetPixelRoundingEnabled(false)
	glowRight:SetAnchor(TOPRIGHT, glowWindow, TOPRIGHT, 0, 0)
	glowRight:SetHidden(true)

	glowTop = wm:CreateControl(nil, glowWindow, CT_TEXTURE)
	glowTop:SetPixelRoundingEnabled(false)
	glowTop:SetAnchor(TOPLEFT, glowWindow, TOPLEFT, 0, 0)
	glowTop:SetHidden(true)

	glowBottom = wm:CreateControl(nil, glowWindow, CT_TEXTURE)
	glowBottom:SetPixelRoundingEnabled(false)
	glowBottom:SetAnchor(BOTTOMLEFT, glowWindow, BOTTOMLEFT, 0, 0)
	glowBottom:SetHidden(true)

	EVENT_MANAGER:RegisterForEvent("ResizeGlow", EVENT_SCREEN_RESIZED, function()
		-- Adjust glow size on window resize
		if (glowSize) then
			lib:SetGlowSize(glowSize)
		end
	end)

end

--[[
	0 = no glow
	0.5 = half of the screen
	1 = full screen
]]
function lib:SetGlowSize(size)

	local SCREEN_WIDTH, SCREEN_HEIGHT = GuiRoot:GetDimensions()

	glowLeft:SetDimensions(SCREEN_WIDTH * size, SCREEN_HEIGHT)
	glowRight:SetDimensions(SCREEN_WIDTH * size, SCREEN_HEIGHT)
	glowTop:SetDimensions(SCREEN_WIDTH, SCREEN_HEIGHT * size)
	glowBottom:SetDimensions(SCREEN_WIDTH, SCREEN_HEIGHT * size)

	glowSize = size

end

function lib:SetGlowColor(r, g, b)

	glowLeft:SetGradientColors(ORIENTATION_HORIZONTAL, r, g, b, glowAlphaStart, r, g, b, glowAlphaEnd)
	glowRight:SetGradientColors(ORIENTATION_HORIZONTAL, r, g, b, glowAlphaEnd, r, g, b, glowAlphaStart)
	glowTop:SetGradientColors(ORIENTATION_VERTICAL, r, g, b, glowAlphaEnd, r, g, b, glowAlphaStart)
	glowBottom:SetGradientColors(ORIENTATION_VERTICAL, r, g, b, glowAlphaStart, r, g, b, glowAlphaEnd)

	glowR = r
	glowG = g
	glowB = b

end

function lib:ShowGlow()

	glowLeft:SetHidden(false)
	glowRight:SetHidden(false)
	glowTop:SetHidden(false)
	glowBottom:SetHidden(false)

end

function lib:HideGlow()

	glowLeft:SetHidden(true)
	glowRight:SetHidden(true)
	glowTop:SetHidden(true)
	glowBottom:SetHidden(true)

end

CreateGlow()