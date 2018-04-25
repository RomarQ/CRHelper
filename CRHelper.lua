CRHelper = {
	name = "CRHelper",
	version	= "1",
	varVersion = 1,
	trialZoneId = 1051,

	-- core flags
	active = false,	-- true when inside Cloudrest
	monitoringFight = false, -- true when inCombat agains Z'Maja

	----- Portal Phase (Shadow Realm) -----

		Start_SRealm_CD = 105890,
		BossReset = 107478,
		PortalSpawn = 103946,
		PortalEnd = 105218,
		--
		portalTimer = 0,
		stopPortalTimer = true,

	----- /Portal Phase (Shadow Realm) -----


	----- ROARING FLARE (FIRE) -----
		roaringFlareId = 103531, -- {103531, 103922, 103921}
		roaringFlareDuration = 6, -- countdown for timer
		roaringFlareMessage = "|cFFA500<<a:1>>|r: |cFF4500<<2>>|r", -- name: <<1>> countdown: <<2>>

		fireStarted = false,
		fireTargetName = "", -- Roaring Flare target name
		fireCount = 0,  -- Roaring Flare counter
	----- /ROARING FLARE (FIRE) -----
	

	----- Hoarfrost (FROST) -----

	hoarfrostIds = {103760, 105151},
	hoarfrostSynergyId = 103697,
	hoarfrostDuration = 10, -- how many seconds until synergy available
	hoarfrostMessage = "|c00FFFF<<a:1>>|r: |c1E90FF<<2>>|r", -- name: <<1>> countdown: <<2>>
	hoarfrostSynergyMessage = "|c1E90FF<<a:1>>|r DROPS FROST!", -- name: <<1>>
	
	frostStarted = false,
	frostEffectGained = false,
	frostTargetName = "", -- Hoarfrost target name
	frostCount = 0,  -- Hoarfrost counter
	frostAlpha = 1,  -- Hoarfrost counter opacity
	frostSynergy = false, -- Hoarfrost synergy available

	----- /Hoarfrost (FROST) -----


	----- Weapon Swap mechanic ( Shock ) -----

		-- Shock animation started on a player
		voltaicCurrentIds = {103895, 103896},

		-- Big shock aoe on a player (lasts 10 seconds)
		voltaicOverloadIds = {87346} ,

		shockCount = 0,  -- Voltaic Overload counter
		shockAlpha = 1,  -- Voltaic Overload counter opacity
		swapped = false, -- Whether a player swapped his weapons after getting Voltaic Overload debuff

	----- /Weapon Swap mechanic ( Shock ) -----



	----- (Beam) -----
		beamId = 105161,
	----- /(Beam) -----



	----- Shadow Splash Cast (Interrupt) -----
		shadowSplashCastId = 105123,
	----- /Shadow Splash Cast (Interrupt) -----
}


LUNIT = LibStub:GetLibrary("LibUnits")

function CRHelper.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads - but we only care about when our own addon loads.
	if addonName ~= CRHelper.name then return end

	EVENT_MANAGER:UnregisterForEvent(CRHelper.name, EVENT_ADD_ON_LOADED);
	CRHelper.Init()

end

function CRHelper.Init()

	-- Gets configs from savedVariables, if file doesn't exist then also creates it
	CRHelper.savedVariables = ZO_SavedVars:New("CRHelperSavedVariables", CRHelper.varVersion , nil, {})
	d('ola')
	-- Builds a Settings menu on addon settings tab
	CRHelper:buildMenu(CRHelper.savedVariables)

	-- Sets window position
	CRHelper:RestorePosition()

	EVENT_MANAGER:RegisterForEvent( CRHelper.name, EVENT_PLAYER_ACTIVATED, CRHelper.PlayerActivated );

end


function CRHelper.PlayerActivated( eventCode, initial )
	if ( GetZoneId(GetUnitZoneIndex("player")) == CRHelper.trialZoneId ) then
		if ( not CRHelper.active ) then

			d("Inside Cloudrest, CRHelper is now enabled!")

			CRHelper.active = true;
			CRHelper.StopMonitoringFight()

			CRHelper:RegisterRoaringFlare()

			CRHelper:RegisterHoarfrost()

			CRHelper:RegisterVoltaicCurrent()
			CRHelper:RegisterVoltaicOverload()

			EVENT_MANAGER:RegisterForEvent("CloudrestWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, CRHelper.WeaponSwap )
			EVENT_MANAGER:AddFilterForEvent("CloudrestWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER )

			-- Main Boss Interrupt Mechanic
			EVENT_MANAGER:RegisterForEvent("ShadowSplashCast", EVENT_COMBAT_EVENT, CRHelper.ShadowSplashCast)
			EVENT_MANAGER:AddFilterForEvent("ShadowSplashCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.shadowSplashCastId)

			-- Beam mechanic that comes from main boss head
			EVENT_MANAGER:RegisterForEvent("Beam", EVENT_COMBAT_EVENT, CRHelper.Beam)
			EVENT_MANAGER:AddFilterForEvent("Beam", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.beamId )

			-- Register for when portal cooldown starts
			EVENT_MANAGER:RegisterForEvent("StartSRealmCD", EVENT_COMBAT_EVENT, CRHelper.startSRealmCoolDown )
			EVENT_MANAGER:AddFilterForEvent("StartSRealmCD", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID , CRHelper.Start_SRealm_CD )

			-- Register for BossReset
			EVENT_MANAGER:RegisterForEvent("BossReset", EVENT_COMBAT_EVENT, CRHelper.ResetPortalTimer )
			EVENT_MANAGER:AddFilterForEvent("BossReset", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.BossReset )

			-- Resgister for Portal Spawn
			EVENT_MANAGER:RegisterForEvent("portalSpawn", EVENT_COMBAT_EVENT, CRHelper.PortalPhase )
			EVENT_MANAGER:AddFilterForEvent("portalSpawn", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.PortalSpawn )


			-- Resgister for when portal closes
			EVENT_MANAGER:RegisterForEvent("portalEnd", EVENT_COMBAT_EVENT, CRHelper.PortalPhaseEnd )
			EVENT_MANAGER:AddFilterForEvent("portalEnd", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.PortalEnd )

			CRHelper.PlayerCombatState() -- not being used it

		end
	else
		if ( CRHelper.active ) then
			
			d("Outside Cloudrest, CRHelper is now disabled!")

			CRHelper.active = false
			CRHelper.StopMonitoringFight()
			
			-- UnRegister to all subscribed Events

			EVENT_MANAGER:UnregisterForEvent("CloudrestWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
			EVENT_MANAGER:UnregisterForEvent("ShadowSplashCast", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("Beam", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("StartSRealmCD", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("BossReset", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("portalSpawn", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("RoaringFlare", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("HoarfrostSynergy", EVENT_COMBAT_EVENT)

			-- UnRegister all subscribed VoltaicCurrent events
			for i, id in ipairs(CRHelper.voltaicCurrentIds) do
				EVENT_MANAGER:UnregisterForEvent("VoltaicCurrent" .. i, EVENT_COMBAT_EVENT)
			end

			-- UnRegister all subscribed VoltaicOverload events 
			for i, id in ipairs(CRHelper.voltaicOverloadIds) do
				EVENT_MANAGER:UnregisterForEvent("VoltaicOverload" .. i, EVENT_EFFECT_CHANGED)
			end

			EVENT_MANAGER:UnregisterForUpdate(CRHelper.name)

		end
	end
end

function CRHelper.PlayerCombatState( )
	if ( IsUnitInCombat("player") and string.find(string.lower(GetUnitName("boss1")), "Z'Maja") ) then
		CRHelper.StartMonitoringFight()
	else
		-- Avoid false positives of combat end, often caused by combat rezzes
		zo_callLater(function() if (not IsUnitInCombat("player")) then CRHelper.StopMonitoringFight() end end, 3000)
	end
end

function CRHelper.StartMonitoringFight( )
	CRHelper.monitoringFight = true
end

function CRHelper.StopMonitoringFight( )
	CRHelper.monitoringFight = false
end

-- This function will be called when engaging Main Boss
function CRHelper.startSRealmCoolDown(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( not CRHelper.savedVariables.trackPortalTimer ) then return end

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

	if ( not CRHelper.savedVariables.trackPortalTimer ) then return end

	if ( result == ACTION_RESULT_EFFECT_GAINED ) then
		
		CRHelper.portalTimer = 100
		CRHelper.stopPortalTimer = false
		CRHelperFrame:SetHidden(false)
		CRHelper.PortalTimerUpdate()

	end

end

function CRHelper.PortalPhaseEnd(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	-- Will fix interrupt message of shadow realm boss from displaying after portal closes 
	CRInterrupt:SetHidden(true)
end

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


----- ROARING FLARE (FIRE) ------

function CRHelper:RegisterRoaringFlare()

	EVENT_MANAGER:RegisterForEvent("RoaringFlare", EVENT_COMBAT_EVENT, self.RoaringFlare)
	EVENT_MANAGER:AddFilterForEvent("RoaringFlare", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.roaringFlareId)	

end

function CRHelper.RoaringFlare(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( not CRHelper.savedVariables.trackRoaringFlare ) then return end

	if (result == ACTION_RESULT_BEGIN) then

		CRHelper.fireStarted = true
		CRHelper.fireTargetName = LUNIT:GetNameForUnitId(targetUnitId) -- get name of target
		CRHelper.fireCount = CRHelper.roaringFlareDuration -- countdown

		EVENT_MANAGER:UnregisterForUpdate("FireTimer")
		EVENT_MANAGER:RegisterForUpdate("FireTimer", 1000, CRHelper.FireTimerTick)

		CRHelper.FireControlShow(zo_strformat(CRHelper.roaringFlareMessage, CRHelper.fireTargetName, CRHelper.fireCount))
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
		CRFire_Label:SetText(zo_strformat(CRHelper.roaringFlareMessage, CRHelper.fireTargetName, CRHelper.fireCount))
		PlaySound(SOUNDS.DUEL_BOUNDARY_WARNING)
	end

end

function CRHelper.FireTimerStopAndHide()

	EVENT_MANAGER:UnregisterForUpdate("FireTimer")
	CRHelper.fireCount = 0
	CRHelper.FireControlHide()

end

-- Show fire timer with optional text
function CRHelper.FireControlShow(text)

	CRFire:SetHidden(false)

	if (text ~= nil) then
		CRFire_Label:SetText(text)
	end

end

function CRHelper.FireControlHide()

	CRFire:SetHidden(true)

end

----- /ROARING FLARE (FIRE) ------


----- HOARFROST (ICE) -----

function CRHelper:RegisterHoarfrost()

	EVENT_MANAGER:RegisterForEvent("HoarfrostSynergy", EVENT_COMBAT_EVENT, self.HoarfrostSynergy)
	EVENT_MANAGER:AddFilterForEvent("HoarfrostSynergy", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.hoarfrostSynergyId)

end

function CRHelper.HoarfrostSynergy(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( not CRHelper.savedVariables.trackHoarfrost ) then return end

	if (result == ACTION_RESULT_EFFECT_GAINED_DURATION) then

		CRHelper.frostSynergy = true
		CRHelper.FrostControlShow(targetType == COMBAT_UNIT_TYPE_PLAYER and "DROP NOW!" or zo_strformat(CRHelper.hoarfrostSynergyMessage, LUNIT:GetNameForUnitId(targetUnitId)))
		PlaySound(SOUNDS.DUEL_START)

	elseif (result == ACTION_RESULT_EFFECT_FADED) then

		CRHelper.frostSynergy = false
		CRHelper.FrostControlHide()
	
	end

end

-- Show frost control with optional text
function CRHelper.FrostControlShow(text)

	CRFrost:SetHidden(false)

	if (text ~= nil) then
		CRFrost_Label:SetText(text)
	end

end

function CRHelper.FrostControlHide()

	CRFrost:SetHidden(true)

end

----- /HOARFROST (ICE) -----



----- VOLTAIC OVERLOAD (SHOCK) -----

function CRHelper:RegisterVoltaicCurrent()

	-- Register VoltaicCurrent event handler for each possible id
	for i, id in ipairs(self.voltaicCurrentIds) do
		EVENT_MANAGER:RegisterForEvent("VoltaicCurrent" .. i, EVENT_COMBAT_EVENT, self.VoltaicCurrent)
		EVENT_MANAGER:AddFilterForEvent("VoltaicCurrent" .. i, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
	end

end

function CRHelper:RegisterVoltaicOverload()

	-- Register VoltaicOverload event handler for each possible id
	for i, id in ipairs(self.voltaicOverloadIds) do
		EVENT_MANAGER:RegisterForEvent("VoltaicOverload" .. i, EVENT_EFFECT_CHANGED, self.VoltaicOverload)
		EVENT_MANAGER:AddFilterForEvent("VoltaicOverload" .. i, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, id)
	end

end

function CRHelper.VoltaicCurrent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	
	if ( not CRHelper.savedVariables.trackVoltaicOverload) then return end

	-- If it's not on yourself, then just ignore it
	if (targetType ~= COMBAT_UNIT_TYPE_PLAYER) then return end
	
	if (result == ACTION_RESULT_EFFECT_GAINED) then
		CRHelper.ShockControlShow("SHOCK INC")
		PlaySound(SOUNDS.DUEL_START)
	elseif (result == ACTION_RESULT_EFFECT_FADED) then
		CRHelper.ShockControlHide()
	end

end

function CRHelper.VoltaicOverload(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName,  buffType, effectType, abilityType, statusEffectType)

	if ( not CRHelper.savedVariables.trackVoltaicOverload) then return end

	-- If it's not on yourself, then just ignore it
	if (unitTag ~= "player") then return end

	if (changeType == EFFECT_RESULT_FADED) then
		CRHelper.ShockTimerStopAndHide()
    elseif (changeType == EFFECT_RESULT_GAINED) or (changeType == EFFECT_RESULT_UPDATED) then
		CRHelper.swapped = false
		CRHelper.EnableShockTimer(beginTime, endTime)
    end

end

function CRHelper.WeaponSwap()

	if (CRHelper.shockCount > 0) then
		CRHelper.swapped = true
		CRShock_Label:SetText("NO SWAP: " .. string.format("%01d", CRHelper.shockCount))
	end

end

function CRHelper.EnableShockTimer(beginTime, endTime)

	EVENT_MANAGER:UnregisterForUpdate("ShockTimer")

	CRHelper.shockCount = math.ceil(endTime - beginTime)

	CRHelper.ShockControlShow(CRHelper.swapped and "NO SWAP: " .. string.format("%01d", self.shockCount) or "SWAP NOW!")

	PlaySound(SOUNDS.DUEL_START)

	EVENT_MANAGER:RegisterForUpdate("ShockTimer", 1000, CRHelper.ShockTimerTick)

end

function CRHelper.ShockTimerTick()

	CRHelper.shockCount = CRHelper.shockCount - 1

	if (CRHelper.shockCount < 0) then
		CRHelper.ShockTimerStopAndHide()
	else
		CRShock_Label:SetText(CRHelper.swapped and "NO SWAP: " .. string.format("%01d", CRHelper.shockCount) or "SWAP NOW!")
		PlaySound(SOUNDS.COUNTDOWN_TICK)
	end

end

function CRHelper.ShockTimerStopAndHide()

	EVENT_MANAGER:UnregisterForUpdate("ShockTimer")
	CRHelper.shockCount = 0
	CRHelper.ShockControlHide()

end

-- Show shock control with optional text
function CRHelper.ShockControlShow(text)

	CRShock:SetHidden(false)

	if (text ~= nil) then
		CRShock_Label:SetText(text)
	end

end

function CRHelper.ShockControlHide()

	CRShock:SetHidden(true)

end

----- /VOLTAIC OVERLOAD (SHOCK) -----



----- SHADOW SPLASH INTERRUPT ------

-- Shows a notification when boss is casting Shadow Splash and needs to be interrupted
function CRHelper.ShadowSplashCast(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( not CRHelper.savedVariables.trackShadowSplashCast ) then return end

	if ( result == ACTION_RESULT_EFFECT_FADED ) then
		CRInterrupt:SetHidden(true)
		return
	end

	CRInterrupt_Warning:SetText("Interrupt the Hypnotard!")
	CRInterrupt:SetHidden(false)
	PlaySound(SOUNDS.SKILL_LINE_ADDED)

end

function CRHelper.Beam(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( not CRHelper.savedVariables.trackLaserBeam) then return end

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
		CRShock_Label:SetFont('$(BOLD_FONT)|$(KB_28)|soft-shadow-thick')
		CRFire_Label:SetFont('$(BOLD_FONT)|$(KB_28)|soft-shadow-thick')
		CRFrost_Label:SetFont('$(BOLD_FONT)|$(KB_28)|soft-shadow-thick')
		CRInterrupt_Warning:SetFont('$(BOLD_FONT)|$(KB_28)|soft-shadow-thick')
	elseif (fontSize == 'medium') then
		CRShock_Label:SetFont('$(BOLD_FONT)|$(KB_36)|soft-shadow-thick')
		CRFire_Label:SetFont('$(BOLD_FONT)|$(KB_36)|soft-shadow-thick')
		CRFrost_Label:SetFont('$(BOLD_FONT)|$(KB_36)|soft-shadow-thick')
		CRInterrupt_Warning:SetFont('$(BOLD_FONT)|$(KB_36)|soft-shadow-thick')
	else
		CRShock_Label:SetFont('$(BOLD_FONT)|$(KB_54)|soft-shadow-thick')
		CRFire_Label:SetFont('$(BOLD_FONT)|$(KB_54)|soft-shadow-thick')
		CRFrost_Label:SetFont('$(BOLD_FONT)|$(KB_54)|soft-shadow-thick')
		CRInterrupt_Warning:SetFont('$(BOLD_FONT)|$(KB_54)|soft-shadow-thick')
	end
end

function CRHelper:unlockUI()

	-- Show dummy text so user can move the window

	CRHelper.FireControlShow("FIRE INC")
	CRHelper.FrostControlShow("FROST INC")
	CRHelper.ShockControlShow("SHOCK INC")

	CRInterrupt:SetHidden(false)
	CRInterrupt_Warning:SetText("Interrupt the Hypnotard!")

	CRBeam:SetHidden(false)
	CRBeam_Warning:SetText( 'Beam is on you, move out of the group!' )

	CRHelperFrame:SetHidden(false)

end

function CRHelper:lockUI()

	CRHelper.FireControlHide()
	CRHelper.FrostControlHide()
	CRHelper.ShockControlHide()

	CRInterrupt:SetHidden(true)
	CRInterrupt_Warning:SetText("")

	CRBeam:SetHidden(true)
	CRBeam_Warning:SetText( '' )

	CRHelperFrame:SetHidden(true)
end

-- SLASH CUSTOM COMMANDS
SLASH_COMMANDS["/cr"] = function ( command )

	if ( command == 'unlock' ) then
		-- Show dummy text so user can move the window

		CRHelper.FireControlShow("FIRE INC")
		CRHelper.FrostControlShow("FROST INC")
		CRHelper.ShockControlShow("SHOCK INC")

		CRInterrupt:SetHidden(false)
		CRInterrupt_Warning:SetText("Interrupt the Hypnotard!")

		CRBeam:SetHidden(false)
		CRBeam_Warning:SetText( 'Beam is on you, move out of the group!' )

		CRHelperFrame:SetHidden(false)

		return
	end

	if ( command == 'lock' ) then

		CRHelper.FireControlHide()
		CRHelper.FrostControlHide()
		CRHelper.ShockControlHide()

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