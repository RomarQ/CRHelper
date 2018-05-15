CRHelper = {
	name = "CRHelper",
	version	= "1",
	varVersion = 2,
	trialZoneId = 1051,
	UI = WINDOW_MANAGER:CreateTopLevelWindow("CRHelperUI"),

	defaultSettings = {

		trackRoaringFlare = true,
		RoaringFlareColor = {255,165,0},

		trackHoarfrost = true,
		HoarfrostColor = {0,255,255},
		
		trackVoltaicOverload = true,
		VoltaicOverloadColor = {255, 255, 255},

		trackCrushingDarkness = true,
		trackCrushingDarknessTimer = true,
		trackShadowSplashCast = true,
		trackPortalSpawn = true,
		trackPortalTimer = true,
		trackOrbSpawn = true,
		trackBanefulMarkTimer = true,

		positionIndicatorEnabled = true,
		positionIndicatorTexture = 2,
		positionIndicatorColor = { 1, 0, 0, 1 },
		positionIndicatorAlpha = 1,
		positionIndicatorScale = 1.20

	},

	-- Core flags
	active = false,	-- true when inside Cloudrest
	monitoringFight = false, -- true when inCombat against Z'Maja

	----- Portal Phase (Shadow Realm) -----

		Start_SRealm_CD = 105890,
		BossReset = 107478,
		PortalSpawn = 103946,
		PortalSpawnTipId = 100,
		PortalEnd = 105218, -- 105218 only occurs after a portal wipe
		PortalPhaseEndId = 109017,
		--
		portalTimer = 0,
		stopPortalTimer = true,
		--
		currentPortalGroup = 1,
		PortalSpawn_CSA_Priority = 1,

	----- /Portal Phase (Shadow Realm) -----


	----- ROARING FLARE (FIRE) -----
		roaringFlareId = 103531, -- {103531, 103922, 103921}
		roaringFlareDuration = 6, -- countdown for timer
		roaringFlareMessage = "<<a:1>>: |cFF4500<<2>>|r", -- name: <<1>> countdown: <<2>>
		roaringFlareMessage2 = "<<a:1>> |cFF0000+|r <<a:2>>: |cFF4500<<3>>|r", -- name1: <<1>> name2: <<2>> countdown: <<3>>
		roaringFlareRadius = 0.0035, -- used by LibPositionIndicator to determine if a player is within fire aoe radius

		fireStarted = false,
		fireTargetUnit1 = 0, -- unit id of the first target
		fireTargetUnit2 = 0, -- unit id of the second target (only on execute)
		fireTargetName = "", -- Roaring Flare target name
		fireCount = 0,  -- Roaring Flare counter

		fireUnitTag = "player",
	----- /ROARING FLARE (FIRE) -----


	----- Hoarfrost (FROST) -----

		hoarfrostId = 103695,
		hoarfrostCastId = 103760,
		hoarfrostSynergyId = 103697,
		hoarfrostAoeId = 103765,
		hoarfrostDuration = 6, -- how many seconds until synergy available
		hoarfrostMessage = "DROP FROST: |c00BFFF<<1>>|r", -- countdown: <<1>>
		hoarfrostSynergyMessage = "|c1E90FF<<a:1>>|r DROPS FROST!", -- name: <<1>>

		frostStarted = false,
		frostEffectGained = false,
		frostTargetName = "", -- Hoarfrost target name
		frostCount = 0,  -- Hoarfrost counter
		frostAlpha = 1,  -- Hoarfrost counter opacity
		frostSynergy = false, -- Hoarfrost synergy available
		frostAoeActive = false, -- Frost AoE on the ground
		frostAoeTickGained = 0, -- Time of the last gained tick
		frostAoeTickFaded = 0, -- Time of the last faded tick

	----- /Hoarfrost (FROST) -----


	----- Weapon Swap mechanic ( Shock ) -----

		-- Shock animation started on a player
		voltaicCurrentIds = {103895, 103896},

		-- Big shock aoe on a player (lasts 10 seconds)
		voltaicOverloadIds = {87346} ,

		shockStarted = false,
		shockCount = 0,  -- Voltaic Overload counter
		shockAlpha = 1,  -- Voltaic Overload counter opacity
		swapped = false, -- Whether a player swapped his weapons after getting Voltaic Overload debuff

	----- /Weapon Swap mechanic ( Shock ) -----



	----- Crushing Darkness -----
		beamId = 105161,
		CrushingDarknessId = 105172,
		CrushingDarknessTipId = 102,
		CrushingDarknessTimer = 0,
		CrushingDarkness_CSA_Priority = 2,
	----- /Crushing Darkness -----



	----- Shadow Splash Cast (Interrupt) -----
		ShadowSplashCastId = 105123,
	----- /Shadow Splash Cast (Interrupt) -----

	----- Orbs Spawning -----
		OrbSpawnId = 105291,
		OrbSpawn_CSA_Priority = 2,
	----- /Orbs Spawning -----

	----- Baneful Mark on execute -----
		BanefulMarkOnExecuteId = 107196,
		BanefulMarkTimer = 0,
		BanefulMark_CSA_Priority = 1,
	----- Baneful Mark on execute -----

}


LUNIT = LibStub:GetLibrary("LibUnits")
LibPI = LibStub:GetLibrary("LibPositionIndicator")
local CSA = CENTER_SCREEN_ANNOUNCE

function CRHelper.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads - but we only care about when our own addon loads.
	if addonName ~= CRHelper.name then return end

	EVENT_MANAGER:UnregisterForEvent(CRHelper.name, EVENT_ADD_ON_LOADED);
	CRHelper.Init()

end

function CRHelper.Init()

	-- Gets configs from savedVariables, if file doesn't exist then also creates it
	CRHelper.savedVariables = ZO_SavedVars:New("CRHelperSavedVariables", CRHelper.varVersion , nil, CRHelper.defaultSettings)

	-- Create Indicator control to make it accessible in menu
	LibPI:CreateTexture()

	-- Builds a Settings menu on addon settings tab
	CRHelper:buildMenu(CRHelper.savedVariables)

	-- Sets window position
	CRHelper:RestorePosition()

	-- Set Label Colors
	CRHelper:RestoreColors()

	EVENT_MANAGER:RegisterForEvent( CRHelper.name, EVENT_PLAYER_ACTIVATED, CRHelper.PlayerActivated );

end


function CRHelper.PlayerActivated( eventCode, initial )
	if ( GetZoneId(GetUnitZoneIndex("player")) == CRHelper.trialZoneId ) then
		if ( not CRHelper.active ) then

			d("Inside Cloudrest, CRHelper is now enabled!")

			if ( GetSetting(SETTING_TYPE_COMBAT, SETTING_TYPE_ACTIVE_COMBAT_TIP) ~= ACT_SETTING_ALWAYS ) then
				SetSetting( SETTING_TYPE_COMBAT , SETTING_TYPE_ACTIVE_COMBAT_TIP , tostring(ACT_SETTING_ALWAYS))
				ApplySettings()
				RefreshSettings()
			end

			--SetSetting(*[SettingSystemType|#SettingSystemType]* _system_, *integer* _settingId_, *string* _value_, *[SetOptions|#SetOptions]* _setOptions_)

			--CRHelper.StartOnScreenNotifications()

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
			EVENT_MANAGER:AddFilterForEvent("ShadowSplashCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.ShadowSplashCastId)

			-- Register for when orbs spawn
			EVENT_MANAGER:RegisterForEvent("OrbSpawn", EVENT_COMBAT_EVENT, CRHelper.OrbSpawn )
			EVENT_MANAGER:AddFilterForEvent("OrbSpawn", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.OrbSpawnId )

			-- Register for when portal cooldown starts
			--EVENT_MANAGER:RegisterForEvent("StartSRealmCD", EVENT_COMBAT_EVENT, CRHelper.startSRealmCoolDown )
			--EVENT_MANAGER:AddFilterForEvent("StartSRealmCD", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID , CRHelper.Start_SRealm_CD )

			-- Register for BossReset
			EVENT_MANAGER:RegisterForEvent("BossReset", EVENT_COMBAT_EVENT, CRHelper.ResetPortalTimer )
			EVENT_MANAGER:AddFilterForEvent("BossReset", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.BossReset )

			-- Register for Crushing Darkness
			EVENT_MANAGER:RegisterForEvent("CrushingDarkness", EVENT_COMBAT_EVENT, CRHelper.CrushingDarkness )
			EVENT_MANAGER:AddFilterForEvent("CrushingDarkness", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.CrushingDarknessId )

			EVENT_MANAGER:RegisterForEvent("PortalCD", EVENT_COMBAT_EVENT, CRHelper.PortalCoolDownStart )
			EVENT_MANAGER:AddFilterForEvent("PortalCD", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.PortalPhaseEndId )

			-- Register for when portal closes
			EVENT_MANAGER:RegisterForEvent("portalEnd", EVENT_COMBAT_EVENT, CRHelper.PortalPhaseEnd )
			EVENT_MANAGER:AddFilterForEvent("portalEnd", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.PortalEnd )

			-- Register for Baneful Mark on execute
			EVENT_MANAGER:RegisterForEvent("BanefulMarkOnExecute", EVENT_COMBAT_EVENT, CRHelper.BanefulMarkOnExecute )
			EVENT_MANAGER:AddFilterForEvent("BanefulMarkOnExecute", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.BanefulMarkOnExecuteId )

			EVENT_MANAGER:RegisterForEvent("inCombat", EVENT_PLAYER_COMBAT_STATE, CRHelper.PlayerCombatState )

			-- Register for any combat Tip
			EVENT_MANAGER:RegisterForEvent("combatTip", EVENT_DISPLAY_ACTIVE_COMBAT_TIP, CRHelper.combatTip )

		end
	else
		if ( CRHelper.active ) then

			d("Outside Cloudrest, CRHelper is now disabled!")

			CRHelper.active = false
			CRHelper.StopMonitoringFight()
			LibPI:EndUpdate()

			-- UnRegister to all subscribed Events

			EVENT_MANAGER:UnregisterForEvent("CloudrestWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
			EVENT_MANAGER:UnregisterForEvent("ShadowSplashCast", EVENT_COMBAT_EVENT)
			--EVENT_MANAGER:UnregisterForEvent("StartSRealmCD", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("BossReset", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("RoaringFlare", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("HoarfrostSynergy", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("PortalCD", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("CrushingDarkness", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("BanefulMarkOnExecute", EVENT_COMBAT_EVENT)

			EVENT_MANAGER:UnregisterForEvent("inCombat", EVENT_PLAYER_COMBAT_STATE )

			EVENT_MANAGER:UnregisterForEvent("combatTip", EVENT_DISPLAY_ACTIVE_COMBAT_TIP )

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

---- testing cave
local t = {}

function CRHelper.test( v )

	
	--local messageParams = CSA:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.MESSAGE_BROADCAST)
	--local messageParams = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
	--messageParams:SetText( "|c98FB98 Portal UP |r - Group " .. CRHelper.currentPortalGroup )
    --messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
	--messageParams:SetIconData("/esoui/art/buttons/large_rightarrow_up.dds")--, "EsoUI/Art/Achievements/achievements_iconBG.dds")
	--messageParams:MarkSuppressIconFrame()
	--CSA:AddMessageWithParams(messageParams)


	zo_callLater(function()

		local messageParams = CSA:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
		messageParams:SetText( "|c98FB98 Portal UP |r - Group " .. CRHelper.currentPortalGroup )
		messageParams:SetPriority(CRHelper.PortalSpawn_CSA_Priority)
		messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COLLECTIBLES_UPDATED)
		CSA:AddMessageWithParams(messageParams)
	
		local messageParams2 = CSA:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
		messageParams2:SetText( "|cff5d00 Crushing Darkness is on you! |r")
		messageParams2:SetPriority(CRHelper.CrushingDarkness_CSA_Priority)
		CSA:AddMessageWithParams(messageParams2)
	
		local messageParams3 = CSA:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
		messageParams3:SetText( "|cffd700 Orbs are UP! |r" )
		messageParams3:SetPriority(CRHelper.OrbSpawn_CSA_Priority)
		CSA:AddMessageWithParams(messageParams3)
	
	end , 1000)


	if ( v == 0 ) then
		CRHelper.portalTimer = 45
		CRHelper.CrushingDarknessTimer = 28
		CRHelper.BanefulMarkTimer = 22
		CRHelperFrame:SetHidden(false)
		CRHelperFrame_PortalTimer:SetHidden(false)
		CRHelperFrame_CrushingDarknessTimer:SetHidden(false)
		CRHelperFrame_BanefulMarkTimer:SetHidden(false)
		CRHelper.PortalTimerUpdate()
		CRHelper.CrushingDarknessTimerUpdate()
		CRHelper.BanefulMarkTimerUpdate()
	elseif ( v == 1 ) then
		CRHelper.CrushingDarknessTimer = 28
		CRHelperFrame:SetHidden(false)
		CRHelperFrame_CrushingDarknessTimer:SetHidden(false)
		CRHelper.CrushingDarknessTimerUpdate()
	elseif ( v == 2 ) then
		CRHelper.portalTimer = 45
		CRHelperFrame:SetHidden(false)
		CRHelper.PortalTimerUpdate()
		CRHelperFrame_PortalTimer:SetHidden(false)
	elseif ( v == 3 ) then
		CRHelper.BanefulMarkTimer = 22
		CRHelperFrame:SetHidden(false)
		CRHelper.BanefulMarkTimerUpdate()
		CRHelperFrame_BanefulMarkTimer:SetHidden(false)
	end

	if ( CRHelper.savedVariables.positionIndicatorEnabled ) then
		LibPI:PostitionIndicatorShow()
	end

	CRHelper.EnableShockTimer(0, 10)

	--[[]
	for i=1 , 9 , 1 do
		t[i] = {}
		for j=1 , 100 , 1 do
			if(t[i][j] == nil) then
				if (GetSetting(i, j) == nil ) then return end
				t[i][j] = GetSetting(i, j)
			elseif ( t[i][j] ~= GetSetting(i, j) and GetSetting(i, j) ~= nil ) then
				if (t[i][j] == nil ) then return end
				d(i .. " - " .. j .. " -> " .. t[i][j] )
				t[i][j] = GetSetting(i, j)
			end
		end
	end
	]]
end

-------------------
-- Create Labels for notifications
-------------------
--[[
function CRHelper.StartOnScreenNotifications()

	CRHelper.UI:TopLevelWindow("CRHelperUI", GuiRoot, {GuiRoot:GetWidth(),GuiRoot:GetHeight()}, {CENTER,CENTER,0,0}, false)
	--Reference the CRHelperUI layer as a scene fragment
	CRHelper.UI.fragment = ZO_HUDFadeSceneFragment:New(CRHelperUI)
	local onScreen = CRHelper.UI:Control( "CRH_OnScreen" , CRHelperUI , {800,32*1.5*7} , {CENTER,CENTER,0,-200} , false )
	onScreen.backdrop = CRHelper.UI:Backdrop( "CRH_OnScreen_BG", onScreen, "inherit", {CENTER,CENTER,0,0}, {0,0,0,0.7}, {0,0,0,1}, nil, true)

	onScreen.label_PortalSpawn = CRHelper.UI:Label(	"CRH_OnScreen_L_PortalSpawn" , onScreen , "inherit", {CENTER,CENTER,0,0} , "$(CRH_MEDIUM_FONT)|$(KB_36)|soft-shadow-thin" , nil , { 1 , 1 } , nil , true )
	onScreen.label_CrushingDarkness = CRHelper.UI:Label( "CRH_OnScreen_L_CrushingDarkness" , onScreen , "inherit", {CENTER,CENTER,0,100} , "$(CRH_MEDIUM_FONT)|$(KB_36)|soft-shadow-thin" , nil , { 1 , 1 } , nil , true )

	onScreen.label_OrbsSpawn = CRHelper.UI:Label( "CRH_OnScreen_L_OrbsSpawn" , onScreen , "inherit", {CENTER,CENTER,0,50} , "$(CRH_MEDIUM_FONT)|$(KB_36)|soft-shadow-thin" , nil , { 1 , 1 } , nil , true )

	onScreen:SetDrawTier(DT_HIGH)
	onScreen.backdrop:SetEdgeTexture("",16,4,4)

end
]]

-------------------
-- Handles important combat tips during Z'Maja boss fight
-------------------
function CRHelper.combatTip( eventCode , activeCombatTipId )

	local name, tipText, _icon = GetActiveCombatTipInfo(activeCombatTipId)

	if( CRHelper.PortalSpawnTipId == activeCombatTipId and CRHelper.savedVariables.trackPortalSpawn ) then

		CRHelper.stopPortalTimer = true
		CRHelperFrame:SetHidden(true)

		local messageParams = CSA:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
		messageParams:SetText( "|c98FB98 Portal UP |r - Group " .. CRHelper.currentPortalGroup )
		messageParams:SetPriority(CRHelper.PortalSpawn_CSA_Priority)
		CSA:AddMessageWithParams(messageParams)

		if ( CRHelper.currentPortalGroup == 1 ) then
			CRHelper.currentPortalGroup = 2
		elseif ( CRHelper.currentPortalGroup == 2 ) then
			CRHelper.currentPortalGroup = 1
		end

		return

	elseif ( CRHelper.CrushingDarknessTipId == activeCombatTipId and CRHelper.savedVariables.trackCrushingDarkness ) then
 
		local messageParams = CSA:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
		messageParams:SetText( "|cff5d00 Crushing Darkness is on you! |r")
		messageParams:SetPriority(CRHelper.CrushingDarkness_CSA_Priority)
		CSA:AddMessageWithParams(messageParams)

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
	CRHelper.stopTimer = false
end

function CRHelper.StopMonitoringFight( )
	CRHelper.monitoringFight = false

	CRHelperFrame:SetHidden(true)
	CRHelper.stopTimer = true

end

-------------------
-- Starts a Cooldown timer for Crushing Darkness
-------------------
function CRHelper.CrushingDarkness(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	
	if ( not CRHelper.savedVariables.trackCrushingDarknessTimer ) then return end

	if ( result == ACTION_RESULT_EFFECT_GAINED ) then
		
		CRHelper.CrushingDarknessTimer = 28
		CRHelperFrame:SetHidden(false)
		CRHelperFrame_CrushingDarknessTimer:SetHidden(false)
		CRHelper.CrushingDarknessTimerUpdate()

	end

end

function CRHelper.BanefulMarkOnExecute(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	
	if ( not CRHelper.savedVariables.trackBanefulMarkTimer ) then return end

	if ( result == ACTION_RESULT_BEGIN ) then
		
		local messageParams = CSA:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
		messageParams:SetText( "|c17D892 Baneful Mark INC! |r" )
		messageParams:SetPriority(CRHelper.BanefulMark_CSA_Priority)
		CSA:AddMessageWithParams(messageParams)


		CRHelper.BanefulMarkTimer = 22
		CRHelperFrame:SetHidden(false)
		CRHelperFrame_BanefulMarkTimer:SetHidden(false)
		CRHelper.BanefulMarkTimerUpdate()

	end

end

-------------------
-- Fires a notification when orbs are going to spawn
-------------------
function CRHelper.OrbSpawn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( not CRHelper.savedVariables.trackOrbSpawn ) then return end

	if ( result == ACTION_RESULT_EFFECT_GAINED ) then

		local messageParams = CSA:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
		messageParams:SetText( "|cffd700 Orbs are UP! |r" )
		messageParams:SetPriority(CRHelper.OrbSpawn_CSA_Priority)
		CSA:AddMessageWithParams(messageParams)

	end

end
--------------------

-------------------
-- Shows a timer for next portal phase
-------------------
function CRHelper.PortalCoolDownStart(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( not CRHelper.savedVariables.trackPortalTimer ) then return end

	if ( result == ACTION_RESULT_EFFECT_FADED ) then

		CRHelper.portalTimer = 45
		CRHelper.stopPortalTimer = false
		CRHelperFrame:SetHidden(false)
		CRHelperFrame_PortalTimer:SetHidden(false)
		CRHelper.PortalTimerUpdate()

	end

end
--------------------

-- This function will be called when engaging Main Boss
function CRHelper.startSRealmCoolDown(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( not CRHelper.savedVariables.trackPortalTimer ) then return end

	if ( result == ACTION_RESULT_EFFECT_GAINED ) then

		CRHelper.stopPortalTimer = true
		CRHelperFrame:SetHidden(true)

	end

end

-- This function is called on every wipe when fighting main boss in Cloudrest
function CRHelper.ResetPortalTimer(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( result == ACTION_RESULT_EFFECT_GAINED ) then
		-- Sets starting group that goes to portal
		CRHelper.currentPortalGroup = 1;
	end

end

function CRHelper.PortalPhaseEnd(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	-- Will fix interrupt message of shadow realm boss from displaying after portal closes
	CRInterrupt:SetHidden(true)
end

-------------------
-- Updates the timer for next portal phase
-------------------
function CRHelper.PortalTimerUpdate( ... )

	if ( CRHelper.savedVariables.trackPortalTimer ) then

		CRHelper.portalTimer = CRHelper.portalTimer - 1
		if ( CRHelper.portalTimer >= 0 ) then
			CRHelperFrame_PortalTimer:SetText(string.format("Portal ( |c98FB98Group " .. CRHelper.currentPortalGroup .. "|r )|t32:32:esoui/art/buttons/large_rightarrow_up.dds|t|c19db1c%d|r", CRHelper.portalTimer ))
		elseif( CRHelper.portalTimer < 0 and CRHelper.portalTimer >= -20 ) then
			CRHelperFrame_PortalTimer:SetText("Portal ( |c98FB98Group " .. CRHelper.currentPortalGroup .. "|r )|t32:32:esoui/art/buttons/large_rightarrow_up.dds|t|cff4c4cAny Moment|r")
		else
			EVENT_MANAGER:UnregisterForUpdate("PortalTimerUpdate")
			CRHelperFrame_PortalTimer:SetHidden(true)
			return
		end
		
		EVENT_MANAGER:UnregisterForUpdate("PortalTimerUpdate")
		EVENT_MANAGER:RegisterForUpdate("PortalTimerUpdate", 1000, CRHelper.PortalTimerUpdate )

	end

end

-------------------
-- Updates the timer for next Crushing Darkness
-------------------
function CRHelper.CrushingDarknessTimerUpdate( ... )

	if ( CRHelper.savedVariables.trackCrushingDarknessTimer ) then

		CRHelper.CrushingDarknessTimer = CRHelper.CrushingDarknessTimer -1

		if ( CRHelper.CrushingDarknessTimer >= 0 ) then
			CRHelperFrame_CrushingDarknessTimer:SetText(string.format("Tether|t32:32:esoui/art/buttons/large_rightarrow_up.dds|t|c19db1c%d|r", CRHelper.CrushingDarknessTimer ))
		elseif ( CRHelper.CrushingDarknessTimer < 0 and CRHelper.CrushingDarknessTimer >= -20 ) then
			CRHelperFrame_CrushingDarknessTimer:SetText("Tether|t32:32:esoui/art/buttons/large_rightarrow_up.dds|t|cff4c4cAny Moment|r")
		else
			EVENT_MANAGER:UnregisterForUpdate("CrushingDarknessTimerUpdate")
			CRHelperFrame_CrushingDarknessTimer:SetHidden(true)
			return
		end

		EVENT_MANAGER:UnregisterForUpdate("CrushingDarknessTimerUpdate")
		EVENT_MANAGER:RegisterForUpdate("CrushingDarknessTimerUpdate", 1000, CRHelper.CrushingDarknessTimerUpdate )

	end

end

-------------------
-- Updates the timer for next Baneful Mark ( only on execute )
-------------------
function CRHelper.BanefulMarkTimerUpdate( ... )

	if ( CRHelper.savedVariables.trackBanefulMarkTimer ) then

		CRHelper.BanefulMarkTimer = CRHelper.BanefulMarkTimer -1

		if ( CRHelper.BanefulMarkTimer >= 0 ) then
			CRHelperFrame_BanefulMarkTimer:SetText(string.format("Baneful Mark|t32:32:esoui/art/buttons/large_rightarrow_up.dds|t|c19db1c%d|r", CRHelper.BanefulMarkTimer ))
		elseif ( CRHelper.BanefulMarkTimer < 0 and CRHelper.BanefulMarkTimer >= -20 ) then
			CRHelperFrame_BanefulMarkTimer:SetText("Baneful Mark|t32:32:esoui/art/buttons/large_rightarrow_up.dds|t|cff4c4cAny Moment|r")
		else
			EVENT_MANAGER:UnregisterForUpdate("BanefulMarkTimerUpdate")
			CRHelperFrame_BanefulMarkTimer:SetHidden(true)
			return
		end

		EVENT_MANAGER:UnregisterForUpdate("BanefulMarkTimerUpdate")
		EVENT_MANAGER:RegisterForUpdate("BanefulMarkTimerUpdate", 1000, CRHelper.BanefulMarkTimerUpdate )

	end

end

----- ROARING FLARE (FIRE) ------

function CRHelper:RegisterRoaringFlare()

	EVENT_MANAGER:RegisterForEvent("RoaringFlare", EVENT_COMBAT_EVENT, self.RoaringFlare)
	EVENT_MANAGER:AddFilterForEvent("RoaringFlare", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.roaringFlareId)

	-- Starts a Position Indicator that will allow everyone to know where the player is.
	LibPI:HandleUpdate()

end

-- Returns one name or concatinates two names into one string sorting them by unit id
function CRHelper.FormatRoaringFlareMessage()

	if (CRHelper.fireTargetUnit1 > 0 and CRHelper.fireTargetUnit2 > 0) then
	
		if (CRHelper.fireTargetUnit1 > CRHelper.fireTargetUnit2) then

			return zo_strformat(CRHelper.roaringFlareMessage2, LUNIT:GetNameForUnitId(CRHelper.fireTargetUnit1), LUNIT:GetNameForUnitId(CRHelper.fireTargetUnit2), CRHelper.fireCount)

		else

			return zo_strformat(CRHelper.roaringFlareMessage2, LUNIT:GetNameForUnitId(CRHelper.fireTargetUnit2), LUNIT:GetNameForUnitId(CRHelper.fireTargetUnit1), CRHelper.fireCount)

		end

	elseif (CRHelper.fireTargetUnit1 > 0 and CRHelper.fireTargetUnit2 == 0) then

		return zo_strformat(CRHelper.roaringFlareMessage, LUNIT:GetNameForUnitId(CRHelper.fireTargetUnit1), CRHelper.fireCount)

	elseif (CRHelper.fireTargetUnit1 == 0 and CRHelper.fireTargetUnit2 > 0) then -- shouldn't happen, but whatever

		return zo_strformat(CRHelper.roaringFlareMessage, LUNIT:GetNameForUnitId(CRHelper.fireTargetUnit2), CRHelper.fireCount)
	
	else
	
		return ""

	end

end

function CRHelper.RoaringFlare(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( not CRHelper.savedVariables.trackRoaringFlare ) then return end

	if (result == ACTION_RESULT_BEGIN) then

		-- second player gets fire (should only happen on execute)
		if (CRHelper.fireStarted) then
			
			CRHelper.fireTargetUnit2 = targetUnitId
			CRHelper.FireControlShow(CRHelper.FormatRoaringFlareMessage())

		-- first player gets fire
		else
	
			CRHelper.fireStarted = true
			CRHelper.fireTargetUnit1 = targetUnitId
			CRHelper.fireUnitTag = LUNIT:GetUnitTagForUnitId(targetUnitId) -- get tag of target
			CRHelper.fireTargetName = LUNIT:GetNameForUnitId(targetUnitId) -- get name of target
			CRHelper.fireCount = CRHelper.roaringFlareDuration -- countdown

			if (targetType ~= COMBAT_UNIT_TYPE_PLAYER and CRHelper.savedVariables.positionIndicatorEnabled) then
				LibPI:PostitionIndicatorShow()
			end

			EVENT_MANAGER:UnregisterForUpdate("FireTimer")
			EVENT_MANAGER:RegisterForUpdate("FireTimer", 1000, CRHelper.FireTimerTick)

			CRHelper.FireControlShow(CRHelper.FormatRoaringFlareMessage())
			PlaySound(SOUNDS.DUEL_START)

		end

	elseif (result == ACTION_RESULT_EFFECT_FADED) then

		CRHelper.fireStarted = false
		CRHelper.fireTargetUnit1 = 0
		CRHelper.fireTargetUnit2 = 0
		CRHelper.FireTimerStopAndHide()

	end

	CRHelper.fireStarted = true
end

function CRHelper.FireTimerTick()

	CRHelper.fireCount = CRHelper.fireCount - 1

	if (CRHelper.fireCount < 0) then
		CRHelper.FireTimerStopAndHide()
	else
		CRFire_Label:SetText(CRHelper.FormatRoaringFlareMessage())
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
	LibPI:PostitionIndicatorHide()

end

----- /ROARING FLARE (FIRE) ------


----- HOARFROST (ICE) -----

function CRHelper:RegisterHoarfrost()

	-- FROST INC
	EVENT_MANAGER:RegisterForEvent("HoarfrostCast", EVENT_COMBAT_EVENT, self.HoarfrostCast)
	EVENT_MANAGER:AddFilterForEvent("HoarfrostCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.hoarfrostCastId)

	-- COUNTDOWN
	EVENT_MANAGER:RegisterForEvent("Hoarfrost", EVENT_COMBAT_EVENT, self.Hoarfrost)
	EVENT_MANAGER:AddFilterForEvent("Hoarfrost", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.hoarfrostId)

	-- SYNERGY AVAILABLE
	EVENT_MANAGER:RegisterForEvent("HoarfrostSynergy", EVENT_COMBAT_EVENT, self.HoarfrostSynergy)
	EVENT_MANAGER:AddFilterForEvent("HoarfrostSynergy", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.hoarfrostSynergyId)
	
	-- AOE
	EVENT_MANAGER:RegisterForEvent("HoarfrostAoe", EVENT_COMBAT_EVENT, self.HoarfrostAoe)
	EVENT_MANAGER:AddFilterForEvent("HoarfrostAoe", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.hoarfrostAoeId)

end

function CRHelper.HoarfrostCast(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not CRHelper.savedVariables.trackHoarfrost or targetType ~= COMBAT_UNIT_TYPE_PLAYER) then return end

	if (result == ACTION_RESULT_BEGIN) then

		CRHelper.FrostControlShow("FROST INC")
		PlaySound(SOUNDS.NEW_MAIL)

	-- Need additional check here because this event can be fired after Hoarfrost effect gained (thus will hide the timer)
	elseif (not CRHelper.frostStarted and result == ACTION_RESULT_EFFECT_FADED) then

		CRHelper.FrostControlHide()

	end

end

function CRHelper.Hoarfrost(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not CRHelper.savedVariables.trackHoarfrost or targetType ~= COMBAT_UNIT_TYPE_PLAYER) then return end

	if (result == ACTION_RESULT_EFFECT_GAINED) then

		CRHelper.frostStarted = true
		CRHelper.frostCount = CRHelper.hoarfrostDuration

		EVENT_MANAGER:UnregisterForUpdate("FrostTimer")
		EVENT_MANAGER:RegisterForUpdate("FrostTimer", 1000, CRHelper.FrostTimerTick)

		CRHelper.FrostControlShow(zo_strformat(CRHelper.hoarfrostMessage, CRHelper.frostCount))
		PlaySound(SOUNDS.JUSTICE_NOW_KOS)

	elseif (result == ACTION_RESULT_EFFECT_FADED) then

		CRHelper.frostStarted = false
		CRHelper.FrostTimerStopAndHide()

	end

end

function CRHelper.HoarfrostSynergy(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not CRHelper.savedVariables.trackHoarfrost or targetType ~= COMBAT_UNIT_TYPE_PLAYER) then return end

	if (result == ACTION_RESULT_EFFECT_GAINED_DURATION) then

		-- Stop countdown
		CRHelper.FrostTimerStopAndHide()

		CRHelper.frostSynergy = true
		CRHelper.FrostControlShow("DROP NOW!")
		PlaySound(SOUNDS.DUEL_START)

		-- after 5s don't wait for event and hide the message
		-- to prevent an issue when the message stays inside shadow realm, because people inside it don't recieve some events from people outside
		--[[ not needed atm, because we only track frost synergy on ourselves
		zo_callLater(
			function()
				if (CRHelper.frostSynergy) then
					CRHelper.frostSynergy = false
					CRHelper.FrostControlHide()
				end
			end,
			5000
		)
		]]

	elseif (result == ACTION_RESULT_EFFECT_FADED) then

		CRHelper.frostSynergy = false
		CRHelper.FrostControlHide()

	end

end

function CRHelper.HoarfrostAoe(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not CRHelper.savedVariables.trackHoarfrost) then return end

	local t = GetFrameTimeSeconds()

	-- if a player doesn't have hoarfrost on him, but there is an aoe to pick up, then spam him with notifications
	if (not CRHelper.frostStarted) then

		if (result == ACTION_RESULT_EFFECT_GAINED) then
		
			-- while frost aoe is active, trigger notification every 1.5s
			if (not CRHelper.frostAoeActive) then

				EVENT_MANAGER:UnregisterForUpdate("HoarfrostAoeTick")
				EVENT_MANAGER:RegisterForUpdate("HoarfrostAoeTick", 1500, CRHelper.HoarfrostAoeTick)

				CRFrost_Label:SetText("PICK UP FROST!")
				CRHelper.FadeInControl(CRFrost, 800)

				PlaySound(SOUNDS.DEATH_RECAP_ATTACK_SHOWN)

			end

			CRHelper.frostAoeActive = true
			CRHelper.frostAoeTickGained = t

		elseif (result == ACTION_RESULT_EFFECT_FADED) then

			CRHelper.frostAoeTickFaded = t

		end

	end

end

function CRHelper.HoarfrostAoeTick()

	local t = GetFrameTimeSeconds()

	-- if another frost tick occured recently, then keep the message, otherwise stop the notification
	if (t - CRHelper.frostAoeTickGained < 1) then

		-- don't show it to a player who picked up another frost
		if (not CRHelper.frostStarted) then

			CRFrost_Label:SetText("PICK UP FROST!")
			CRHelper.FadeInControl(CRFrost, 800)
			
			PlaySound(SOUNDS.DEATH_RECAP_ATTACK_SHOWN)

		end

	else

		EVENT_MANAGER:UnregisterForUpdate("HoarfrostAoeTick")
		CRHelper.frostAoeActive = false

		-- don't hide control if player has frost debuff
		if (not CRHelper.frostStarted) then
			CRHelper.FrostControlHide()
		end

	end

end

function CRHelper.FrostTimerTick()

	CRHelper.frostCount = CRHelper.frostCount - 1

	if (CRHelper.frostCount < 0) then
		CRHelper.FrostTimerStopAndHide()
	else
		CRHelper.FrostControlShow(zo_strformat(CRHelper.hoarfrostMessage, CRHelper.frostCount))
		PlaySound(SOUNDS.COUNTDOWN_TICK)
	end

end

function CRHelper.FrostTimerStopAndHide()

	EVENT_MANAGER:UnregisterForUpdate("FrostTimer")
	CRHelper.frostCount = 0
	CRHelper.FrostControlHide()

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

	if (not CRHelper.savedVariables.trackVoltaicOverload) then return end

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

	if (not CRHelper.savedVariables.trackVoltaicOverload) then return end

	-- If it's not on yourself, then just ignore it
	if (unitTag ~= "player") then return end

	if (changeType == EFFECT_RESULT_FADED) then

		CRHelper.shockStarted = false
		CRHelper.ShockTimerStop()
		CRShock_Label:SetText(string.format("|c98FB98%s|r", "CAN SWAP"))
		CRHelper.FadeOutControl(CRShock, 1000)

    elseif (changeType == EFFECT_RESULT_GAINED) or (changeType == EFFECT_RESULT_UPDATED) then
		CRHelper.shockStarted = true
		CRHelper.swapped = false
		CRHelper.EnableShockTimer(beginTime, endTime)
    end

end

function CRHelper.WeaponSwap()

	if (CRHelper.shockStarted and not CRHelper.swapped) then
		CRHelper.swapped = true
		CRHelper.ShockControlShow("NO SWAP: " .. string.format("%01d", CRHelper.shockCount))
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

	if (CRHelper.shockCount >=0) then
		CRHelper.ShockControlShow(CRHelper.swapped and "NO SWAP: " .. string.format("%01d", CRHelper.shockCount) or "SWAP NOW!")
		PlaySound(SOUNDS.COUNTDOWN_TICK)
	end

end

function CRHelper.ShockTimerStop()

	EVENT_MANAGER:UnregisterForUpdate("ShockTimer")
	CRHelper.shockCount = 0

end

function CRHelper.ShockTimerStopAndHide()

	CRHelper.ShockTimerStop()
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
		control:SetAlpha(1)
    end)
    timeline:PlayFromStart()

end

-- Fade in animation for any custom control
function CRHelper.FadeInControl(control, duration)

    local animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, control)
 
	control:SetAlpha(0)
	control:SetHidden(false)
 
    animation:SetAlphaValues(0, 1)
    animation:SetDuration(duration or 1000)
 
    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
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

function CRHelper:OnFrameMoveStop()
	CRHelper.savedVariables.frameLeft = CRHelperFrame:GetLeft()
	CRHelper.savedVariables.frameTop = CRHelperFrame:GetTop()
end

function CRHelper:OnLabelMove( label )
	CRHelper.savedVariables[label .. "Top"] = _G[label]:GetLeft()
	CRHelper.savedVariables[label .. "Top"] = _G[label]:GetTop()
end

-- Gets the saved colors and applies them
function CRHelper:RestoreColors()

	CRFire_Label:SetColor(unpack(CRHelper.savedVariables.RoaringFlareColor))
	CRShock_Label:SetColor(unpack(CRHelper.savedVariables.VoltaicOverloadColor))
	CRFrost_Label:SetColor(unpack(CRHelper.savedVariables.HoarfrostColor))

end

-- Gets the saved positions and applies them
function CRHelper:RestorePosition()
	local shockLeft = self.savedVariables.shockLeft
	local shockTop = self.savedVariables.shockTop

	local fireLeft = self.savedVariables.fireLeft
	local fireTop = self.savedVariables.fireTop

	local frostLeft = self.savedVariables.frostLeft
	local frostTop = self.savedVariables.frostTop

	local interruptLeft = self.savedVariables.interruptLeft
	local interruptTop	= self.savedVariables.interruptTop

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

	CRHelperFrame:SetHidden(false)
	CRHelperFrame_PortalTimer:SetText("Timers")
	CRHelperFrame_PortalTimer:SetHidden(false)

end

function CRHelper:lockUI()

	CRHelper.FireControlHide()
	CRHelper.FrostControlHide()
	CRHelper.ShockControlHide()

	CRInterrupt:SetHidden(true)
	CRInterrupt_Warning:SetText("")

	CRHelperFrame:SetHidden(true)
	CRHelperFrame_PortalTimer:SetText("")
	CRHelperFrame_PortalTimer:SetHidden(true)

end

-- SLASH CUSTOM COMMANDS
SLASH_COMMANDS["/cr"] = function ( command )

	if ( command == 'unlock' ) then
		
		-- Show dummy text so user can move the window
		CRHelper:unlockUI()

		return
	end

	if ( command == 'lock' ) then

		CRHelper.lockUI()

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
		CRHelper.savedVariables.frameLeft = nil
		CRHelper.savedVariables.frameTop = nil
		return
	end

end

EVENT_MANAGER:RegisterForEvent(CRHelper.name, EVENT_ADD_ON_LOADED, CRHelper.OnAddOnLoaded)
