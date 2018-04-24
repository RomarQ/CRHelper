CRHelper = {
	name = "CRHelper",

	Start_SRealm_CD = 105890,
	BossReset = 107478,
	portalTimer = 0,
	stopPortalTimer = true
}

----- ROARING FLARE (FIRE) -----

CRHelper.roaringFlareId = 103531 -- {103531, 103922, 103921}
CRHelper.roaringFlareDuration = 6 -- countdown for timer
CRHelper.roaringFlareMessage = "|cFFA500<<a:1>>|r: |cFF4500<<2>>|r" -- name: <<1>> countdown: <<2>>

CRHelper.fireStarted = false
CRHelper.fireTargetName = "" -- Roaring Flare target name
CRHelper.fireCount = 0  -- Roaring Flare counter

----- /ROARING FLARE (FIRE) -----

-- Shock animation started on a player
CRHelper.VoltaicCurrentIds = {103895, 103896} 

-- Big shock aoe on a player (lasts 10 seconds)
CRHelper.VoltaicOverloadIds = {87346} 

CRHelper.PortalPhaseId = 103946

-- Frost animation started on a player
CRHelper.HoarfrostIds = {103760, 105151}
CRHelper.HoarfrostSynergyIds = {103697}
CRHelper.HoarfrostDuration = 10 -- how many seconds until synergy available
CRHelper.HoarfrostMessage = "|c00FFFF<<a:1>>|r: |c1E90FF<<2>>|r" -- name: <<1>> countdown: <<2>>
CRHelper.HoarfrostSynergyMessage = "|c1E90FF<<a:1>>|r DROPS FROST!" -- name: <<1>>

CRHelper.shockCount = 0  -- Voltaic Overload counter
CRHelper.shockAlpha = 1  -- Voltaic Overload counter opacity
CRHelper.swapped = false -- Whether a player swapped his weapons after getting Voltaic Overload debuff

CRHelper.frostStarted = false
CRHelper.frostEffectGained = false
CRHelper.frostTargetName = "" -- Hoarfrost target name
CRHelper.frostCount = 0  -- Hoarfrost counter
CRHelper.frostAlpha = 1  -- Hoarfrost counter opacity
CRHelper.frostSynergy = false -- Hoarfrost synergy available

CRHelper.beamId = 105161

CRHelper.shadowSplashCastId = 105123
CRHelper.shadowSplashCastAlpha = 1

LUNIT = LibStub:GetLibrary("LibUnits")

function CRHelper:Initialize()

	CRHelper:RegisterRoaringFlare()

	CRHelper:registerVoltaicCurrent()
	CRHelper:registerVoltaicOverload()

	CRHelper:registerHoarfrost()

	EVENT_MANAGER:RegisterForEvent("CloudrestWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, CRHelper.WeaponSwap)
	EVENT_MANAGER:AddFilterForEvent("CloudrestWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

	-- Main Boss Interrupt Mechanic
	EVENT_MANAGER:RegisterForEvent("ShadowSplashCast", EVENT_COMBAT_EVENT, self.ShadowSplashCast)
	EVENT_MANAGER:AddFilterForEvent("ShadowSplashCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.shadowSplashCastId)

	-- Beam mechanic that comes from main boss head
	EVENT_MANAGER:RegisterForEvent("Beam", EVENT_COMBAT_EVENT, self.Beam)
	EVENT_MANAGER:AddFilterForEvent("Beam", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.beamId )

	-- Register for when portal cooldown starts
	EVENT_MANAGER:RegisterForEvent("StartSRealmCD", EVENT_COMBAT_EVENT, self.startSRealmCoolDown )
	EVENT_MANAGER:AddFilterForEvent("StartSRealmCD", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID , CRHelper.Start_SRealm_CD )

	-- Register for BossReset
	EVENT_MANAGER:RegisterForEvent("BossReset", EVENT_COMBAT_EVENT, self.ResetPortalTimer )
	EVENT_MANAGER:AddFilterForEvent("BossReset", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.BossReset )

	-- Resgister for Portal Spawn
	EVENT_MANAGER:RegisterForEvent("portalSpawn", EVENT_COMBAT_EVENT, self.PortalPhase )
	EVENT_MANAGER:AddFilterForEvent("portalSpawn", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.PortalPhaseId )

	-- Not tested
	-- EVENT_MANAGER:RegisterForEvent("portal2", EVENT_COMBAT_EVENT, self.PortalPhaseEnd )
	-- EVENT_MANAGER:AddFilterForEvent("portal2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 105218 )--105218

	-- Gets configs from savedVariables, if file doesn't exist then also creates it
	self.savedVariables = ZO_SavedVars:New("CRHelperSavedVariables", 1, nil, {})

	-- Sets window position
	self:RestorePosition()
end

-- This fucntion will be called when engaging Main Boss
function CRHelper.startSRealmCoolDown(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( result == ACTION_RESULT_EFFECT_GAINED ) then
		
		CRHelper.portalTimer = 28
		CRHelper.stopPortalTimer = false
		CRHelperFrame:SetHidden(false)
		CRHelper.PortalTimerUpdate()

	end

end

-- This function is called on every wipe when fighting main boss in Cloudrest
function CRHelper.ResetPortalTimer(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( result == ACTION_RESULT_EFFECT_GAINED ) then
		CRHelper.portalTimer = 0
		CRHelperFrame:SetHidden(true)
		CRHelper.stopPortalTimer = true
	end

end

-- This function is called on every portal spawn
function CRHelper.PortalPhase(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( result == ACTION_RESULT_EFFECT_GAINED ) then
		
		CRHelper.portalTimer = 136
		CRHelper.stopPortalTimer = false
		CRHelperFrame:SetHidden(false)
		CRHelper.PortalTimerUpdate()

	end

end

-- Not tested yet
-- function CRHelper.PortalPhaseEnd(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
--	
--	d('----------------')
--	d('portal phase over')
--	d('event: ' .. eventCode)
--	d('result: ' .. result )
--	d('-------------')
--
--end

-- Timer for portal spawn
function CRHelper.PortalTimerUpdate()

	if ( CRHelper.stopPortalTimer ) then
		EVENT_MANAGER:UnregisterForUpdate("PortalTimer")
		return
	end

	CRHelper.portalTimer = CRHelper.portalTimer - 1
	if ( CRHelper.portalTimer > 20 ) then
		CRHelperFrame_Timer:SetText(string.format(" Portal in : |c19db1c %d |r", CRHelper.portalTimer ))
	else
		CRHelperFrame_Timer:SetText(string.format(" Portal in : |cf20018 %d |r", CRHelper.portalTimer ))
	end

	if ( CRHelper.portalTimer == 0 ) then
		CRHelper.stopPortalTimer = true
		CRHelperFrame:SetHidden(true)
		EVENT_MANAGER:UnregisterForUpdate("PortalTimer")
		return
	end
	
	EVENT_MANAGER:UnregisterForUpdate("PortalTimer")
	EVENT_MANAGER:RegisterForUpdate("PortalTimer", 1000, CRHelper.PortalTimerUpdate)

end

function CRHelper:registerVoltaicCurrent()

	-- Register VoltaicCurrent event handler for each possible id
	for i, id in ipairs(self.VoltaicCurrentIds) do
		EVENT_MANAGER:RegisterForEvent("VoltaicCurrent" .. i, EVENT_COMBAT_EVENT, self.VoltaicCurrent)
		EVENT_MANAGER:AddFilterForEvent("VoltaicCurrent" .. i, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
	end

end

function CRHelper:registerVoltaicOverload()

	-- Register VoltaicOverload event handler for each possible id
	for i, id in ipairs(self.VoltaicOverloadIds) do
		EVENT_MANAGER:RegisterForEvent("VoltaicOverload" .. i, EVENT_EFFECT_CHANGED, self.VoltaicOverload)
		EVENT_MANAGER:AddFilterForEvent("VoltaicOverload" .. i, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, id)
	end

end

function CRHelper:registerHoarfrost()

	-- Register Hoarfrost event handler for each possible id
	--for i, id in ipairs(self.HoarfrostIds) do
		--EVENT_MANAGER:RegisterForEvent("Hoarfrost" .. i, EVENT_COMBAT_EVENT, self.Hoarfrost)
		--EVENT_MANAGER:AddFilterForEvent("Hoarfrost" .. i, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
	--end

	-- Register Hoarfrost synergy event handler for each possible id
	for i, id in ipairs(self.HoarfrostSynergyIds) do
		EVENT_MANAGER:RegisterForEvent("HoarfrostSynergy" .. i, EVENT_COMBAT_EVENT, self.HoarfrostSynergy)
		EVENT_MANAGER:AddFilterForEvent("HoarfrostSynergy" .. i, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
	end

	-- Debuff on a player
	--EVENT_MANAGER:RegisterForEvent("HoarfrostEffect", EVENT_EFFECT_CHANGED, self.HoarfrostEffect)
	--EVENT_MANAGER:AddFilterForEvent("HoarfrostEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 103673)

end

function CRHelper.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == CRHelper.name then
    CRHelper:Initialize()
  end
end

function CRHelper.VoltaicCurrent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	
	-- If isn't on this player, then just ignore it
	if ( 1 ~= targetType ) then return end
	
	CRShock:SetHidden(false)
	CRShock_Timer:SetText("SHOCK INC")
	PlaySound(SOUNDS.DUEL_START)

end

----- ROARING FLARE (FIRE) ------

function CRHelper:RegisterRoaringFlare()

	EVENT_MANAGER:RegisterForEvent("RoaringFlare", EVENT_COMBAT_EVENT, self.RoaringFlare)
	EVENT_MANAGER:AddFilterForEvent("RoaringFlare", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.roaringFlareId)	

end

function CRHelper.RoaringFlare(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (result == ACTION_RESULT_BEGIN) then

		CRHelper.fireStarted = true
		CRHelper.fireTargetName = LUNIT:GetNameForUnitId(targetUnitId) -- get name of target
		CRHelper.fireCount = CRHelper.roaringFlareDuration -- countdown

		EVENT_MANAGER:UnregisterForUpdate("FireTimer")
		EVENT_MANAGER:RegisterForUpdate("FireTimer", 1000, CRHelper.FireTimerTick)

		CRHelper.FireTimerShow(zo_strformat(CRHelper.roaringFlareMessage, CRHelper.fireTargetName, CRHelper.fireCount))
		PlaySound(SOUNDS.DUEL_START)

	elseif (result == ACTION_RESULT_EFFECT_FADED) then

		CRHelper.fireStarted = false
		CRHelper.FireTimerStopAndHide()

	end

	CRHelper.fireStarted = true
end

function CRHelper.FireTimerTick()

	CRHelper.fireCount = CRHelper.fireCount - 1

	if (CRHelper.fireCount < 0) then
		CRHelper.FireTimerStopAndHide()
	else
		CRFire_Timer:SetText(zo_strformat(CRHelper.roaringFlareMessage, CRHelper.fireTargetName, CRHelper.fireCount))
		PlaySound(SOUNDS.DUEL_BOUNDARY_WARNING)
	end

end

function CRHelper.FireTimerStopAndHide()

	EVENT_MANAGER:UnregisterForUpdate("FireTimer")
	CRHelper.fireCount = 0
	CRHelper.FireTimerHide()

end

-- Show fire timer with optional text
function CRHelper.FireTimerShow(text)

	CRFire:SetHidden(false)

	if (text ~= nil) then
		CRFire_Timer:SetText(text)
	end

end

function CRHelper.FireTimerHide()

	CRFire:SetHidden(true)

end

----- ROARING FLARE (FIRE) ------

function CRHelper.Hoarfrost(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (CRHelper.frostStarted) then return end
	
	CRHelper.frostTargetName = LUNIT:GetNameForUnitId(targetUnitId) -- get name of target
	CRHelper.frostCount = CRHelper.HoarfrostDuration -- countdown

	CRFrost:SetHidden(false)
	CRFrost_Timer:SetText(zo_strformat(CRHelper.HoarfrostMessage, CRHelper.frostTargetName, CRHelper.frostCount))
	PlaySound(SOUNDS.DUEL_START)

	EVENT_MANAGER:UnregisterForUpdate("FrostTimer")
	EVENT_MANAGER:RegisterForUpdate("FrostTimer", 1000, CRHelper.UpdateFrostTimer)

	CRHelper.frostStarted = true
end

function CRHelper.HoarfrostEffect(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName,  buffType, effectType, abilityType, statusEffectType)
	
	if (2 == changeType) then
		CRHelper.frostStarted = false
		CRHelper.frostSynergy = false
		CRHelper.frostEffectGained = false

		-- fade out timer
		EVENT_MANAGER:RegisterForUpdate("FrostTimerFadeOut", 50,
			function()
				CRHelper.frostAlpha = CRHelper.frostAlpha - 0.05
				if (CRHelper.frostAlpha <= 0) then
					CRHelper.frostAlpha = 0
					EVENT_MANAGER:UnregisterForUpdate("FrostTimerFadeOut")
				end
				CRFrost_Timer:SetAlpha(CRHelper.frostAlpha)
			end
		)
    elseif (1 == changeType) or (3 == changeType) then
		-- Hoarfrost effect gained by a player
		CRHelper.frostEffectGained = true
    end

end

function CRHelper.HoarfrostSynergy(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (CRHelper.frostSynergy) then return end

	CRFrost:SetHidden(false)
	PlaySound(SOUNDS.DUEL_START)

	if (targetType == 1) then
		CRFrost_Timer:SetText("DROP NOW!")
	else
		CRFrost_Timer:SetText(zo_strformat(CRHelper.HoarfrostSynergyMessage, LUNIT:GetNameForUnitId(targetUnitId)))
	end

	CRHelper.frostSynergy = true

	-- fade out animation
	zo_callLater(
		function()
			EVENT_MANAGER:RegisterForUpdate("FrostSynergyFadeOut", 50,
				function()
					CRHelper.frostAlpha = CRHelper.frostAlpha - 0.05
					if (CRHelper.frostAlpha <= 0) then
						CRHelper.frostAlpha = 0
						CRHelper.frostSynergy = false
						EVENT_MANAGER:UnregisterForUpdate("FrostSynergyFadeOut")
					end
					CRFrost_Timer:SetAlpha(CRHelper.frostAlpha)
				end
			)
		end,
		3000
	)

end

function CRHelper.UpdateFrostTimer()
	CRHelper.frostCount = CRHelper.frostCount - 1
	if (CRHelper.frostCount <= 0) then
		CRHelper.frostCount = 0
		EVENT_MANAGER:UnregisterForUpdate("FrostTimer")
		
		-- if hoarfrost effect is not gained by the end of the timer, then probably something bad happened and need to reset values
		if (not CRHelper.frostEffectGained) then
			CRHelper.frostStarted = false
			CRHelper.frostSynergy = false
		end

	elseif (CRHelper.frostSynergy) then
		CRFrost_Timer:SetText("DROP NOW!")
	else
		CRFrost_Timer:SetText(zo_strformat(CRHelper.HoarfrostMessage, CRHelper.frostTargetName, CRHelper.frostCount))
		PlaySound(SOUNDS.DUEL_BOUNDARY_WARNING)
	end
end

function CRHelper.VoltaicOverload(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName,  buffType, effectType, abilityType, statusEffectType)
	
	-- If isn't on this player, then just ignore it
	if ( unitTag ~= "player" ) then return end
	
	if (2 == changeType) then
		-- Fade out the timer when the buff is removed
		EVENT_MANAGER:RegisterForUpdate("ShockTimerFadeOut", 50,
			function()
				CRHelper.shockAlpha = CRHelper.shockAlpha - 0.05
				if (CRHelper.shockAlpha <= 0) then
					CRHelper.shockAlpha = 0
					EVENT_MANAGER:UnregisterForUpdate("ShockTimerFadeOut")
				end
				CRShock_Timer:SetAlpha(CRHelper.shockAlpha)
			end
		)
    elseif (1 == changeType) or (3 == changeType) then
		CRHelper.swapped = false
		CRHelper:EnableShockTimer(beginTime, endTime)
    end
end

function CRHelper.WeaponSwap()
	if (CRHelper.shockCount > 0) then
		CRHelper.swapped = true
		CRShock_Timer:SetText("NO SWAP: " .. string.format("%01d", CRHelper.shockCount))
	end
end

function CRHelper:EnableShockTimer(beginTime, endTime)
	EVENT_MANAGER:UnregisterForUpdate("ShockTimer")
	EVENT_MANAGER:UnregisterForUpdate("ShockTimerFadeOut")
	CRShock_Timer:SetText("")
	CRShock:SetHidden(false)
	CRHelper.shockAlpha = 1
	self.shockCount = math.ceil(endTime - beginTime)
	PlaySound(SOUNDS.DUEL_START)
	CRShock_Timer:SetText(self.swapped and "NO SWAP: " .. string.format("%01d", self.shockCount) or "SWAP NOW!")

	EVENT_MANAGER:UnregisterForUpdate("ShockTimer")
	EVENT_MANAGER:RegisterForUpdate("ShockTimer", 1000, self.UpdateShockTimer)

end

function CRHelper.UpdateShockTimer()
	CRHelper.shockCount = CRHelper.shockCount - 1
	if (CRHelper.shockCount <= 0) then
		CRHelper.shockCount = 0
		EVENT_MANAGER:UnregisterForUpdate("ShockTimer")
	end
    CRShock_Timer:SetText(CRHelper.swapped and "NO SWAP: " .. string.format("%01d", CRHelper.shockCount) or "SWAP NOW!")
	PlaySound(SOUNDS.COUNTDOWN_TICK)
end

function CRHelper:fadeOut(timer)
	EVENT_MANAGER:RegisterForUpdate("fadeOut", timer, self.UpdateShockTimer)
end

----- SHADOW SPLASH INTERRUPT ------

-- Shows a notification when boss is casting Shadow Splash and needs to be interrupted
function CRHelper.ShadowSplashCast(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( result == ACTION_RESULT_EFFECT_FADED ) then
		CRInterrupt:SetHidden(true)
		return
	end

	CRInterrupt_Warning:SetText("Interrupt the Hypnotard!")
	CRInterrupt:SetHidden(false)
	PlaySound(SOUNDS.SKILL_LINE_ADDED)

end

function CRHelper.Beam(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( result == ACTION_RESULT_EFFECT_FADED ) then
		CRBeam:SetHidden(true)
		return
	end

	if ( targetType == 1 ) then
        CRBeam_Warning:SetText( 'Beam is on you, move out of the group!' )
        CRBeam:SetHidden(false)
        PlaySound(SOUNDS.SKILL_LINE_ADDED)
    end

end

----- /SHADOW SPLASH INTERRUPT -----

-- Fade out animation for any custom control
-- Hides control when animation ends
function CRHelper.FadeOutControl(control, duration)

    local animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, control)
 
    animation:SetAlphaValues(control:GetAlpha(), 0)
    animation:SetDuration(duration or 1000)
 
    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
	timeline:SetHandler('OnStop', function()
        control:SetHidden(true)
    end)
    timeline:PlayFromStart()

end

-- Gets the current window position and saves it in savedVariables
function CRHelper:OnShockControlMoveStop()
	CRHelper.savedVariables.shockLeft = CRShock:GetLeft()
	CRHelper.savedVariables.shockTop = CRShock:GetTop()
end

function CRHelper:OnFireControlMoveStop()
	CRHelper.savedVariables.fireLeft = CRFire:GetLeft()
	CRHelper.savedVariables.fireTop = CRFire:GetTop()
end

function CRHelper:OnFrostControlMoveStop()
	CRHelper.savedVariables.frostLeft = CRFrost:GetLeft()
	CRHelper.savedVariables.frostTop = CRFrost:GetTop()
end

function CRHelper:OnInterruptMoveStop()
	CRHelper.savedVariables.interruptLeft = CRInterrupt:GetLeft()
	CRHelper.savedVariables.interruptTop = CRInterrupt:GetTop()
end

function CRHelper:OnBeamMoveStop()
	CRHelper.savedVariables.beamLeft = CRBeam:GetLeft()
	CRHelper.savedVariables.beamTop = CRBeam:GetTop()
end

function CRHelper:OnFrameMoveStop()
	CRHelper.savedVariables.frameLeft = CRHelperFrame:GetLeft()
	CRHelper.savedVariables.frameTop = CRHelperFrame:GetTop()
end

-- Gets the saved window position and updates it
function CRHelper:RestorePosition()
	local shockLeft = self.savedVariables.shockLeft
	local shockTop = self.savedVariables.shockTop

	local fireLeft = self.savedVariables.fireLeft
	local fireTop = self.savedVariables.fireTop
	
	local frostLeft = self.savedVariables.frostLeft
	local frostTop = self.savedVariables.frostTop

	local interruptLeft = self.savedVariables.interruptLeft
	local interruptTop	= self.savedVariables.interruptTop

	local beamLeft = self.savedVariables.beamLeft
	local beamTop = self.savedVariables.beamTop
	
	local frameLeft = self.savedVariables.frameLeft
	local frameTop = self.savedVariables.frameTop

	local fontSize = self.savedVariables.fontSize

	if (shockLeft or shockTop) then
		CRShock:ClearAnchors()
		CRShock:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, shockLeft, shockTop)
	end

	if (fireLeft or fireTop) then
		CRFire:ClearAnchors()
		CRFire:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, fireLeft, fireTop)
	end
	
	if (frostLeft or frostTop) then
		CRFrost:ClearAnchors()
		CRFrost:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, frostLeft, frostTop)
	end

	if (interruptLeft and interruptTop) then
		CRInterrupt:ClearAnchors()
		CRInterrupt:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, interruptLeft, interruptTop)
	end

	if (beamLeft and beamTop) then
		CRBeam:ClearAnchors()
		CRBeam:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, beamLeft, beamTop)
	end
	
	if ( frameLeft and frameTop ) then
		CRHelperFrame:ClearAnchors();
		CRHelperFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, frameLeft, frameTop);
	end

	-- Restore font
	if (fontSize == 'small' or fontSize == 'medium' or fontSize == 'large') then
		CRHelper:setFontSize(fontSize)
	end
end

function CRHelper:setFontSize(fontSize)
	if (fontSize == 'small') then
		CRShock_Timer:SetFont('$(BOLD_FONT)|$(KB_28)|soft-shadow-thick')
		CRFire_Timer:SetFont('$(BOLD_FONT)|$(KB_28)|soft-shadow-thick')
		CRFrost_Timer:SetFont('$(BOLD_FONT)|$(KB_28)|soft-shadow-thick')
		CRInterrupt_Warning:SetFont('$(BOLD_FONT)|$(KB_28)|soft-shadow-thick')
	elseif (fontSize == 'medium') then
		CRShock_Timer:SetFont('$(BOLD_FONT)|$(KB_36)|soft-shadow-thick')
		CRFire_Timer:SetFont('$(BOLD_FONT)|$(KB_36)|soft-shadow-thick')
		CRFrost_Timer:SetFont('$(BOLD_FONT)|$(KB_36)|soft-shadow-thick')
		CRInterrupt_Warning:SetFont('$(BOLD_FONT)|$(KB_36)|soft-shadow-thick')
	else
		CRShock_Timer:SetFont('$(BOLD_FONT)|$(KB_54)|soft-shadow-thick')
		CRFire_Timer:SetFont('$(BOLD_FONT)|$(KB_54)|soft-shadow-thick')
		CRFrost_Timer:SetFont('$(BOLD_FONT)|$(KB_54)|soft-shadow-thick')
		CRInterrupt_Warning:SetFont('$(BOLD_FONT)|$(KB_54)|soft-shadow-thick')
	end
end

-- SLASH CUSTOM COMMANDS
SLASH_COMMANDS["/cr"] = function ( command )

	if ( command == 'unlock' ) then
		-- Show dummy text so user can move the window

		CRHelper.FireTimerShow("FIRE INC")

		CRShock:SetHidden(false)
		CRShock_Timer:SetAlpha(1)
		CRShock_Timer:SetText("SHOCK INC")

		CRFrost:SetHidden(false)
		CRFrost_Timer:SetText("FROST INC")

		CRInterrupt:SetHidden(false)
		CRInterrupt_Warning:SetText("Interrupt the Hypnotard!")

		CRBeam:SetHidden(false)
		CRBeam_Warning:SetText( 'Beam is on you, move out of the group!' )

		CRHelperFrame:SetHidden(false)

		return
	end

	if ( command == 'lock' ) then

		CRHelper.FireTimerHide()

		CRShock:SetHidden(true)
		CRShock_Timer:SetAlpha(0)
		CRShock_Timer:SetText("")
		
		CRFrost:SetHidden(true)
		CRFrost_Timer:SetText("")

		CRInterrupt:SetHidden(true)
		CRInterrupt_Warning:SetText("")

		CRBeam:SetHidden(true)
		CRBeam_Warning:SetText( '' )

		CRHelperFrame:SetHidden(true)

		return
	end

	if ( command == 'small') then
		CRHelper:setFontSize('small')
		d('Font size has been set to small.')
		CRHelper.savedVariables.fontSize = 'small'
	end
	
	if ( command == 'medium') then
		CRHelper:setFontSize('medium')
		d('Font size has been set to medium.')
		CRHelper.savedVariables.fontSize = 'medium'
	end

	if ( command == 'large') then
		CRHelper:setFontSize('large')
		d('Font size has been set to large.')
		CRHelper.savedVariables.fontSize = 'large'
	end

	if ( command == 'reset' ) then
		d("Positions reset. Reload UI.")
		CRHelper.savedVariables.shockLeft = nil
		CRHelper.savedVariables.shockTop = nil
		CRHelper.savedVariables.fireLeft = nil
		CRHelper.savedVariables.fireTop = nil
		CRHelper.savedVariables.frostLeft = nil
		CRHelper.savedVariables.frostTop = nil
		CRHelper.savedVariables.interruptLeft = nil
		CRHelper.savedVariables.interruptTop = nil
		CRHelper.savedVariables.beamLeft = nil
		CRHelper.savedVariables.beamTop = nil
		CRHelper.savedVariables.frameLeft = nil
		CRHelper.savedVariables.frameTop = nil
		return
	end

end

EVENT_MANAGER:RegisterForEvent(CRHelper.name, EVENT_ADD_ON_LOADED, CRHelper.OnAddOnLoaded)