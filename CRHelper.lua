CRHelper = {}

-- Shock animation started on a player
CRHelper.VoltaicCurrentIds = {103895, 103896} 

-- Big shock aoe on a player (lasts 10 seconds)
CRHelper.VoltaicOverloadIds = {87346} 

-- Fire animation started on a player
CRHelper.RoaringFlareIds = {103531, 103922, 103921}
CRHelper.RoaringFlareDuration = 6 -- countdown for timer
CRHelper.RoaringFlareMessage = "|cFFA500<<a:1>>|r: |cFF4500<<2>>|r" -- name: <<1>> countdown: <<2>>

-- Frost animation started on a player
CRHelper.HoarfrostIds = {103760, 105151}
CRHelper.HoarfrostSynergyIds = {103697}
CRHelper.HoarfrostDuration = 10 -- how many seconds until synergy available
CRHelper.HoarfrostMessage = "|c00FFFF<<a:1>>|r: |c1E90FF<<2>>|r" -- name: <<1>> countdown: <<2>>
CRHelper.HoarfrostSynergyMessage = "|c1E90FF<<a:1>>|r DROPS FROST!" -- name: <<1>>

CRHelper.name = "CRHelper"

CRHelper.shockCount = 0  -- Voltaic Overload counter
CRHelper.shockAlpha = 1  -- Voltaic Overload counter opacity
CRHelper.swapped = false -- Whether a player swapped his weapons after getting Voltaic Overload debuff

CRHelper.fireStarted = false
CRHelper.fireTargetName = "" -- Roaring Flare target name
CRHelper.fireCount = 0  -- Roaring Flare counter
CRHelper.fireAlpha = 1  -- RoaringFlare counter opacity

CRHelper.frostStarted = false
CRHelper.frostEffectGained = false
CRHelper.frostTargetName = "" -- Hoarfrost target name
CRHelper.frostCount = 0  -- Hoarfrost counter
CRHelper.frostAlpha = 1  -- Hoarfrost counter opacity
CRHelper.frostSynergy = false -- Hoarfrost synergy available

CRHelper.shadowSplashCastId = 105123
CRHelper.shadowSplashCastAlpha = 1

LUNIT = LibStub:GetLibrary("LibUnits")

function CRHelper:Initialize()

	CRShock_Timer:SetText("")
	CRShock_Timer:SetAlpha(0)

	CRFire_Timer:SetText("")
	CRFire_Timer:SetAlpha(0)

	CRFrost_Timer:SetText("")
	CRFrost_Timer:SetAlpha(0)
	
	CRHelper:registerVoltaicCurrent()
	CRHelper:registerVoltaicOverload()

	CRHelper:registerRoaringFlare()
	
	CRHelper:registerHoarfrost()

	EVENT_MANAGER:RegisterForEvent("CloudrestWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, CRHelper.WeaponSwap)
	EVENT_MANAGER:AddFilterForEvent("CloudrestWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

	EVENT_MANAGER:RegisterForEvent("ShadowSplashCast", EVENT_COMBAT_EVENT, self.ShadowSplashCast)
	EVENT_MANAGER:AddFilterForEvent("ShadowSplashCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.shadowSplashCastId)

	-- Gets configs from savedVariables, if file doesn't exist then also creates it
	self.savedVariables = ZO_SavedVars:New("CRHelperSavedVariables", 1, nil, {})

	-- Sets window position
	self:RestorePosition()
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

function CRHelper:registerRoaringFlare()

	-- Register Roaring Flare event handler for each possible id
	for i, id in ipairs(self.RoaringFlareIds) do
		EVENT_MANAGER:RegisterForEvent("RoaringFlare" .. i, EVENT_COMBAT_EVENT, self.RoaringFlare)
		EVENT_MANAGER:AddFilterForEvent("RoaringFlare" .. i, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
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
	
	CRShock_Timer:SetAlpha(1)
	CRShock_Timer:SetText("SHOCK INC")
	PlaySound(SOUNDS.DUEL_START)

end

function CRHelper.RoaringFlare(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (CRHelper.fireStarted) then return end
	
	CRHelper.fireTargetName = LUNIT:GetNameForUnitId(targetUnitId) -- get name of target
	CRHelper.fireCount = CRHelper.RoaringFlareDuration -- countdown

	CRFire_Timer:SetAlpha(1)
	CRFire_Timer:SetText(zo_strformat(CRHelper.RoaringFlareMessage, CRHelper.fireTargetName, CRHelper.fireCount))
	PlaySound(SOUNDS.DUEL_START)

	EVENT_MANAGER:UnregisterForUpdate("FireTimer")
	EVENT_MANAGER:RegisterForUpdate("FireTimer", 1000, CRHelper.UpdateFireTimer)

	CRHelper.fireStarted = true
end

function CRHelper.Hoarfrost(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (CRHelper.frostStarted) then return end
	
	CRHelper.frostTargetName = LUNIT:GetNameForUnitId(targetUnitId) -- get name of target
	CRHelper.frostCount = CRHelper.HoarfrostDuration -- countdown

	CRFrost_Timer:SetAlpha(1)
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

	CRFrost_Timer:SetAlpha(1)
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

function CRHelper.UpdateFireTimer()
	CRHelper.fireCount = CRHelper.fireCount - 1
	if (CRHelper.fireCount < 0) then
		CRHelper.fireCount = 0
		EVENT_MANAGER:UnregisterForUpdate("FireTimer")
		-- fade out
		EVENT_MANAGER:RegisterForUpdate("FireTimerFadeOut", 50,
			function()
				CRHelper.fireAlpha = CRHelper.fireAlpha - 0.05
				if (CRHelper.fireAlpha <= 0) then
					CRHelper.fireAlpha = 0
					CRHelper.fireStarted = false
					EVENT_MANAGER:UnregisterForUpdate("FireTimerFadeOut")
				end
				CRFire_Timer:SetAlpha(CRHelper.fireAlpha)
			end
		)
	else
		CRFire_Timer:SetText(zo_strformat(CRHelper.RoaringFlareMessage, CRHelper.fireTargetName, CRHelper.fireCount))
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
	CRShock_Timer:SetAlpha(1)
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

	if ( result == 2250 ) then
		CRInterrupt_Warning:SetAlpha(0)
		return
	end

	CRInterrupt_Warning:SetText("Interrupt the Hypnotard!")
	CRInterrupt_Warning:SetAlpha(1)
	PlaySound(SOUNDS.SKILL_LINE_ADDED)

end

----- /SHADOW SPLASH INTERRUPT -----


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
		CRShock_Timer:SetAlpha(1)
		CRShock_Timer:SetText("SHOCK INC")
		
		CRFire_Timer:SetAlpha(1)
		CRFire_Timer:SetText("FIRE INC")
		
		CRFrost_Timer:SetAlpha(1)
		CRFrost_Timer:SetText("FROST INC")

		CRInterrupt_Warning:SetAlpha(1)
		CRInterrupt_Warning:SetText("Interrupt the Hypnotard!")
		return
	end

	if ( command == 'lock' ) then
		-- Hide dummy
		CRShock_Timer:SetAlpha(0)
		CRShock_Timer:SetText("")

		CRFire_Timer:SetAlpha(0)
		CRFire_Timer:SetText("")
		
		CRFrost_Timer:SetAlpha(0)
		CRFrost_Timer:SetText("")

		CRInterrupt_Warning:SetAlpha(0)
		CRInterrupt_Warning:SetText("")
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
		return
	end

end

EVENT_MANAGER:RegisterForEvent(CRHelper.name, EVENT_ADD_ON_LOADED, CRHelper.OnAddOnLoaded)