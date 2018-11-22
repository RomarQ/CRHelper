CRHelper = {
	name = "CRHelper",
	version	= "2.6.1",
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
		voltaicOverloadScreenGlow = true,
		voltaicOverloadScreenGlowColor = {1, 0.3, 1},
		voltaicOverloadScreenGlowSize = 0.15,
		voltaicOverloadExtra = false,

		trackBanefulBarb = true,
		trackCorpulence = true,
		trackNocturnalsFavor = true,
		trackRazorthorn = true,
		trackMaliciousStrike = true,

		trackCrushingDarkness = true,
		trackCrushingDarknessTimer = true,
		trackShadowSplashCast = true,
		trackPortalSpawn = true,
		trackPortalTimer = true,
		trackOrbSpawn = true,
		trackBanefulMarkTimer = true,
		trackMalevolentCore = true,
		trackOlorimeSpear = true,

		positionIndicatorEnabled = true,
		positionIndicatorTexture = 2,
		positionIndicatorColor = { 1, 0, 0, 1 },
		positionIndicatorAlpha = 1,
		positionIndicatorScale = 1.20

	},

	-- Core flags
		active = false,	-- true when inside Cloudrest
		monitoringFight = false, -- true when inCombat against Z'Maja
		trackCombatEvents = false, -- when enabled, all combat events are posted into chat

	----- Portal Phase (Shadow Realm) -----

		BossReset = 107478,
		SRealm_CD_Start = 105890, -- Fired when Z'Maja is engaged
		PortalSpawn = 103946,
		PortalSpawnTipId = 100,
		SRealm_Win = 104792, -- Fired when Shadow Realm is closed
		--
		portalTimer = 0,
		stopPortalTimer = true,
		--
		currentPortalGroup = 1,
		PortalSpawn_CSA_Priority = 1,

	----- /Portal Phase (Shadow Realm) -----

		nocturnalsFavorCount = 0,
		corpulenceCount = 0,

	----- ROARING FLARE (FIRE) -----

		roaringFlareId 	= 103531, -- primary target
		roaringFlareId2 = 110431, -- secondary target
		roaringFlareDuration = 6, -- number of seconds until the explosion
		roaringFlareMessage = "<<1>> : |cFF4500<<2>>|r", -- name: <<1>> countdown: <<2>>
		roaringFlareMessage2 = "<<1>> |t64:64:esoui/art/buttons/large_leftarrow_up.dds|t |cFF4500<<3>>|r |t64:64:esoui/art/buttons/large_rightarrow_up.dds|t <<2>>", -- name1: <<1>> name2: <<2>> countdown: <<3>>
		roaringFlareRadius = 0.0035, -- used by LibPositionIndicator to determine if a player is within fire aoe radius

		fireTargetUnit1 = 0, -- unit id of the primary target
		fireTargetUnit2 = 0, -- unit id of the secondary target (only on execute)
		fireCount = 0, -- current countdown value

	----- /ROARING FLARE (FIRE) -----


	----- Hoarfrost (FROST) -----

		hoarfrostIds = {103695, 110516},
		hoarfrostCastIds = {105151, 110466},
		hoarfrostSynergyIds = {103697, 110525},
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
		-- OLD: {103895, 103896, 110427},
		voltaicCurrentIds = {103555}, -- +103554?

		-- Big shock aoe on a player (lasts 10 seconds)
		voltaicOverloadIds = {87346},

		shockStarted = false,
		shockCount = 0,  -- Voltaic Overload counter
		shockAlpha = 1,  -- Voltaic Overload counter opacity
		swapped = false, -- Whether a player swapped his weapons after getting Voltaic Overload debuff

	----- /Weapon Swap mechanic ( Shock ) -----

	----- Crushing Darkness -----
		CrushingDarknessId = 105239, -- 105172 maybe will be needed
		CrushingDarknessTipId = 102,
		CrushingDarknessTimer = 0,
		CrushingDarkness_CSA_Priority = 2,
	----- /Crushing Darkness -----

	----- Shadow Splash Cast (Interrupt) -----
		ShadowSplashCastId = 105123,
		shadowSplashDuration = 3.0,
		shadowSplashCount = 0,
	----- /Shadow Splash Cast (Interrupt) -----

	----- Orbs Spawning -----
		OrbSpawnId = 105291,
		OrbSpawn_CSA_Priority = 2,
	----- /Orbs Spawning -----

	----- Baneful Mark on execute -----
		BanefulMarkOnExecuteId = 107196,
		BanefulMarkTimer = 0,
		BanefulMark_CSA_Priority = 1,
	----- /Baneful Mark on execute -----

	----- Malevolent Core -----
		MalevolentCoreSpawn = 103980,
		MalevolentCoreCounter = 0,
	----- /Malevolent Core -----

	----- Olorime Spear -----
		OlorimeSpear = 104018,
		OlorimeSpearCounter = 0,
	----- /Malevolent Core -----
}

local CR = CRHelper

LUNIT = LibStub:GetLibrary("LibUnits")
LibPI = LibStub:GetLibrary("LibPositionIndicator")
LibGlow = LibStub:GetLibrary("LibScreenGlow")

local CSA = CENTER_SCREEN_ANNOUNCE

local combatStartedFrameTime = 0

local clipboardWindow = WINDOW_MANAGER:CreateTopLevelWindow("ClipboardWindow")
clipboardWindow:SetMouseEnabled(false)
clipboardWindow:SetDimensions(50, 50)
clipboardWindow:SetTopmost(true)

local clipboard = WINDOW_MANAGER:CreateControl(nil, clipboardWindow, CT_TEXTURE)
clipboard:SetPixelRoundingEnabled(false)
clipboard:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 0, 0)
clipboard:SetDimensions(50, 50)
clipboard:SetColor(1, 0, 1)
clipboard:SetHidden(true)

-- unit ids of cores and number of them
local malevolentCoreIds = {}
local malevolentCoreNum = 0

-- local variables for timers
local heavyAttackList = {}
local voltaicCurrentEnd = 0
local voltaicOverloadEnd = 0

-- timelines
local animationTimelines = {}

function CRHelper.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads - but we only care about when our own addon loads.
	if addonName ~= CRHelper.name then return end

	EVENT_MANAGER:UnregisterForEvent(CRHelper.name, EVENT_ADD_ON_LOADED)
	CRHelper.Init()

end

function CRHelper.Init()

	-- Gets configs from savedVariables, if file doesn't exist then also creates it
	CRHelper.savedVariables = ZO_SavedVars:New("CRHelperSavedVariables", CRHelper.varVersion , nil, CRHelper.defaultSettings)

	-- Create Indicator control to make it accessible in menu
	LibPI:CreateTexture()
	
	-- Initialize screen glow
	LibGlow:SetGlowSize(CRHelper.savedVariables.voltaicOverloadScreenGlowSize)
	LibGlow:SetGlowColor(unpack(CRHelper.savedVariables.voltaicOverloadScreenGlowColor))

	-- Builds a Settings menu on addon settings tab
	CRHelper:buildMenu(CRHelper.savedVariables)

	-- Sets window position
	CRHelper:RestorePosition()

	-- Set Label Colors
	CRHelper:RestoreColors()

	EVENT_MANAGER:RegisterForEvent( CRHelper.name, EVENT_PLAYER_ACTIVATED, CRHelper.PlayerActivated );

end

function CRHelper.PlayerActivated(eventCode, initial)

	if (GetZoneId(GetUnitZoneIndex("player")) == CRHelper.trialZoneId) then
	
		if (not CRHelper.active) then

			--d("Inside Cloudrest, CRHelper is now enabled!")

			--SetSetting(*[SettingSystemType|#SettingSystemType]* _system_, *integer* _settingId_, *string* _value_, *[SetOptions|#SetOptions]* _setOptions_)
			if ( GetSetting(SETTING_TYPE_COMBAT, SETTING_TYPE_ACTIVE_COMBAT_TIP) ~= ACT_SETTING_ALWAYS ) then
				SetSetting( SETTING_TYPE_COMBAT , SETTING_TYPE_ACTIVE_COMBAT_TIP , tostring(ACT_SETTING_ALWAYS))
				ApplySettings()
				RefreshSettings()
			end

			CRHelper.active = true
			CRHelper.StopMonitoringFight()

			CRHelper:RegisterRoaringFlare()
			CRHelper:RegisterHoarfrost()
			CRHelper:RegisterVoltaicCurrent()

			EVENT_MANAGER:RegisterForEvent("CloudrestWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, CRHelper.WeaponSwap )
			EVENT_MANAGER:AddFilterForEvent("CloudrestWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER )
			
			-- Baneful Mark cast from a spider
			EVENT_MANAGER:RegisterForEvent("BanefulBarb", EVENT_COMBAT_EVENT, CRHelper.BanefulBarb)
			EVENT_MANAGER:AddFilterForEvent("BanefulBarb", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 105975)

			-- Spider's Heavy Attack
			EVENT_MANAGER:RegisterForEvent("Corpulence", EVENT_COMBAT_EVENT, CRHelper.Corpulence)
			EVENT_MANAGER:AddFilterForEvent("Corpulence", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 105968)

			-- Siroria's Heavy Attack
			EVENT_MANAGER:RegisterForEvent("ScaldingSunder", EVENT_COMBAT_EVENT, CRHelper.ShadeHeavyAttack)
			EVENT_MANAGER:AddFilterForEvent("ScaldingSunder", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 104755)

			-- Relequen's Heavy Attack
			EVENT_MANAGER:RegisterForEvent("ShockingSmash", EVENT_COMBAT_EVENT, CRHelper.ShadeHeavyAttack)
			EVENT_MANAGER:AddFilterForEvent("ShockingSmash", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 105780)
			
			-- Galenwe's Heavy Attack
			EVENT_MANAGER:RegisterForEvent("RavagingBlow", EVENT_COMBAT_EVENT, CRHelper.ShadeHeavyAttack)
			EVENT_MANAGER:AddFilterForEvent("RavagingBlow", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 106375)

			-- Main Boss pokeball
			EVENT_MANAGER:RegisterForEvent("NocturnalsFavor", EVENT_COMBAT_EVENT, CRHelper.NocturnalsFavor)
			EVENT_MANAGER:AddFilterForEvent("NocturnalsFavor", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 104535)
			
			-- Tentacle Root
			EVENT_MANAGER:RegisterForEvent("Razorthorn", EVENT_COMBAT_EVENT, CRHelper.Razorthorn)
			EVENT_MANAGER:AddFilterForEvent("Razorthorn", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 106656)

			-- Orb Projectile
			EVENT_MANAGER:RegisterForEvent("MaliciousStrike", EVENT_COMBAT_EVENT, CR.MaliciousStrike)
			EVENT_MANAGER:AddFilterForEvent("MaliciousStrike", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 110242)
			
			-- Main Boss Interrupt Mechanic
			EVENT_MANAGER:RegisterForEvent("ShadowSplashCast", EVENT_COMBAT_EVENT, CRHelper.ShadowSplashCast)
			EVENT_MANAGER:AddFilterForEvent("ShadowSplashCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.ShadowSplashCastId)

			-- Register for when orbs spawn
			EVENT_MANAGER:RegisterForEvent("OrbSpawn", EVENT_COMBAT_EVENT, CRHelper.OrbSpawn )
			EVENT_MANAGER:AddFilterForEvent("OrbSpawn", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.OrbSpawnId )

			-- Register for when portal opens
			EVENT_MANAGER:RegisterForEvent("SRealm_Open", EVENT_COMBAT_EVENT, CRHelper.SRealmOpen )
			EVENT_MANAGER:AddFilterForEvent("SRealm_Open", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID , CRHelper.PortalSpawn )

			-- Register for when portal closes
			EVENT_MANAGER:RegisterForEvent("SRealm_Close", EVENT_COMBAT_EVENT, CRHelper.SRealmCoolDownUpdate )
			EVENT_MANAGER:AddFilterForEvent("SRealm_Close", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.SRealm_Win )

			-- Register for Shadow Realm CoolDown ( Should only happen at start of the fight )
			EVENT_MANAGER:RegisterForEvent("SRealm_CD", EVENT_COMBAT_EVENT, CRHelper.SRealmCoolDownUpdate )
			EVENT_MANAGER:AddFilterForEvent("SRealm_CD", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID , CRHelper.SRealm_CD_Start )			

			-- Register for BossReset
			EVENT_MANAGER:RegisterForEvent("BossReset", EVENT_COMBAT_EVENT, CRHelper.ResetPortalTimer )
			EVENT_MANAGER:AddFilterForEvent("BossReset", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.BossReset )

			-- Register for Crushing Darkness
			EVENT_MANAGER:RegisterForEvent("CrushingDarkness", EVENT_COMBAT_EVENT, CRHelper.CrushingDarkness )
			EVENT_MANAGER:AddFilterForEvent("CrushingDarkness", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.CrushingDarknessId )

			-- Register for when Malevolent Core Hit player
			--EVENT_MANAGER:RegisterForEvent("MalevolentCoreSpawn", EVENT_COMBAT_EVENT, CRHelper.MalevolentCoreGrant )
			--EVENT_MANAGER:AddFilterForEvent("MalevolentCoreSpawn", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.MalevolentCoreSpawn )
			EVENT_MANAGER:RegisterForEvent("MalevolentCoreHit", EVENT_COMBAT_EVENT, CR.MalevolentCoreHit)
			EVENT_MANAGER:AddFilterForEvent("MalevolentCoreHit", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 123456789)

			-- Register for when Olorime Spear Granted
			EVENT_MANAGER:RegisterForEvent("OlorimeSpear_Grant", EVENT_COMBAT_EVENT, CRHelper.OlorimeSpearGrant )
			EVENT_MANAGER:AddFilterForEvent("OlorimeSpear_Grant", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.OlorimeSpear)

			-- Register for Baneful Mark on execute
			EVENT_MANAGER:RegisterForEvent("BanefulMarkOnExecute", EVENT_COMBAT_EVENT, CRHelper.BanefulMarkOnExecute )
			EVENT_MANAGER:AddFilterForEvent("BanefulMarkOnExecute", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, CRHelper.BanefulMarkOnExecuteId )

			EVENT_MANAGER:RegisterForEvent("inCombat", EVENT_PLAYER_COMBAT_STATE, CRHelper.PlayerCombatState )

			-- Register for any combat tip
			EVENT_MANAGER:RegisterForEvent("combatTip", EVENT_DISPLAY_ACTIVE_COMBAT_TIP, CRHelper.combatTip )

		end

	else

		if (CRHelper.active) then

			--d("Outside Cloudrest, CRHelper is now disabled!")

			CRHelper.active = false
			CRHelper.StopMonitoringFight()
			LibPI:EndUpdate()

			-- UnRegister to all subscribed Events

			CRHelper:UnregisterRoaringFlare()
			CRHelper:UnregisterHoarfrost()
			CRHelper:UnregisterVoltaicCurrent()

			EVENT_MANAGER:UnregisterForEvent("CloudrestWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
			EVENT_MANAGER:UnregisterForEvent("BanefulBarb", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("Corpulence", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("ScaldingSunder", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("ShockingSmash", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("RavagingBlow", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("NocturnalsFavor", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("Razorthorn", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("MaliciousStrike", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("ShadowSplashCast", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("SRealm_Open", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("SRealm_Close", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("SRealm_CD", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("BossReset", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("CrushingDarkness", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("BanefulMarkOnExecute", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("MalevolentCoreSpawn", EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent("OlorimeSpear_Grant", EVENT_COMBAT_EVENT)

			EVENT_MANAGER:UnregisterForEvent("inCombat", EVENT_PLAYER_COMBAT_STATE )

			EVENT_MANAGER:UnregisterForEvent("combatTip", EVENT_DISPLAY_ACTIVE_COMBAT_TIP )

			EVENT_MANAGER:UnregisterForUpdate(CRHelper.name)

		end
	end
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

local function StopControlAnimation(control)

	local controlName = control:GetName()
	if animationTimelines[controlName] and animationTimelines[controlName]:IsPlaying() then animationTimelines[controlName]:Stop() end

end

local function SlideInControl(control)

	local controlName = control:GetName()
    local animation, timeline = CreateSimpleAnimation(ANIMATION_TRANSLATE, control)
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()
	control:SetHidden(false)

	animation:SetTranslateOffsets(offsetX - 250, offsetY, offsetX, offsetY)
    animation:SetDuration(200)

    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    timeline:PlayFromStart()

end

local function BounceControl(control)

	StopControlAnimation(control)

	local controlName = control:GetName()	
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()
    local timeline = ANIMATION_MANAGER:CreateTimeline()

    local translate1 = timeline:InsertAnimation(ANIMATION_TRANSLATE, control)
    translate1:SetTranslateOffsets(offsetX - 8, offsetY, offsetX + 8, offsetY)
    translate1:SetDuration(200)

	local translate2 = timeline:InsertAnimation(ANIMATION_TRANSLATE, control, 200)
    translate2:SetTranslateOffsets(offsetX + 8, offsetY, offsetX - 8, offsetY)
    translate2:SetDuration(200)

	timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP)
	timeline:SetPlaybackLoopCount(1000)
	timeline:PlayFromStart()

	animationTimelines[controlName] = timeline
	
end

local function FormatHeavyAttackList()

	local countdownList = {}
	local countdownListFormatted = {}
	local t = GetGameTimeMilliseconds()

	for _, value in ipairs(heavyAttackList) do
		if value[1] > t then
			table.insert(countdownList, {value[1] - t, value[2]})
		end
	end

	if #countdownList > 0 then
		table.sort(countdownList, function(a, b) return a[1] < b[1] end)
		for _, value in ipairs(countdownList) do
			--local strformat = value > 1000 and "|cFFFFFF%0.1f|r" or "|cFF0000%0.1f|r"
			local strformat = "|c" .. value[2] .. "%0.1f|r"
			table.insert(countdownListFormatted, string.format(strformat, value[1] / 1000))
		end
		return table.concat(countdownListFormatted, " / ")
	else
		return nil
	end

end

-------------------
-- Handles important combat tips during Z'Maja boss fight
-------------------
function CRHelper.combatTip(eventCode , activeCombatTipId)

	local name, tipText, _icon = GetActiveCombatTipInfo(activeCombatTipId)

	if( CRHelper.PortalSpawnTipId == activeCombatTipId and CRHelper.savedVariables.trackPortalSpawn ) then

		CRHelper.stopPortalTimer = true
		CRHelperFrame_PortalTimer:SetHidden(true)

		local messageParams = CSA:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
		messageParams:SetText( "|c98FB98 Portal UP |r - Group " .. CRHelper.currentPortalGroup )
		messageParams:SetPriority(CRHelper.PortalSpawn_CSA_Priority)
		CSA:AddMessageWithParams(messageParams)

		if ( CRHelper.currentPortalGroup == 1 ) then
			CRHelper.currentPortalGroup = 2
		else
			CRHelper.currentPortalGroup = 1
		end

	end

end

function CRHelper.PlayerCombatState( )
	if ( IsUnitInCombat("player") ) then -- and string.find(string.lower(GetUnitName("boss1")), "z'maja") ) then
		CRHelper.StartMonitoringFight()
	else
		-- Avoid false positives of combat end, often caused by combat rezzes
		zo_callLater(function() if (not IsUnitInCombat("player")) then CRHelper.StopMonitoringFight() end end, 3000)
	end
end

function CRHelper.StartMonitoringFight( )
	CRHelper.monitoringFight = true
	CRHelper.stopTimer = false
	
	combatStartedFrameTime = GetFrameTimeSeconds()
end

function CRHelper.StopMonitoringFight()

	CRHelper.monitoringFight = false
	CR.stopTimer = true
	combatStartedFrameTime = 0

	EVENT_MANAGER:UnregisterForUpdate("CRVoltaicOverloadTimer") -- crutch (if the fight ends while voltaic overload is active, then this timer will continue showing it anyway)

	CR.HideControls()

end

function CR.HideControls()

	CR.FireControlHide()
	CR.FrostControlHide()
	CR.ShockControlHide()

	CRInterrupt:SetHidden(true)
	CRInterrupt_Warning:SetText("")

	CRHelperFrame:SetHidden(true)
	CRHelperFrame_PortalTimer:SetText("")
	CRHelperFrame_PortalTimer:SetHidden(true)

	LibGlow:HideGlow()

	clipboard:SetHidden(true)

end

-- Baneful Mark cast by a spider
function CRHelper.BanefulBarb(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not CRHelper.savedVariables.trackBanefulBarb or targetType ~= COMBAT_UNIT_TYPE_PLAYER) then return end

	if (result == ACTION_RESULT_BEGIN) then

		CRReticle_Label:SetText("|cFF0000MARK|r")
		CRReticle:SetHidden(false)
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		zo_callLater(function() CRReticle:SetHidden(true) end , 1500)

	end

end

-- Spider's heavy attack
function CR.Corpulence(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not CRHelper.savedVariables.trackCorpulence or targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end

	if result == ACTION_RESULT_BEGIN then

		table.insert(heavyAttackList, {GetGameTimeMilliseconds() + hitValue - 200, "FF0000"})

		CR.HeavyAttackTimer()
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		EVENT_MANAGER:UnregisterForUpdate("CRHeavyAttackTimer")
		EVENT_MANAGER:RegisterForUpdate("CRHeavyAttackTimer", 100, CR.HeavyAttackTimer)

	end

end

-- Main Boss Pokeball
function CRHelper.NocturnalsFavor(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not CRHelper.savedVariables.trackNocturnalsFavor or targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end
	
	if result == ACTION_RESULT_BEGIN then

		table.insert(heavyAttackList, {GetGameTimeMilliseconds() + hitValue, "FF1493"})

		CR.HeavyAttackTimer()
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		EVENT_MANAGER:UnregisterForUpdate("CRHeavyAttackTimer")
		EVENT_MANAGER:RegisterForUpdate("CRHeavyAttackTimer", 100, CR.HeavyAttackTimer)

	end

end

-- Root by Tentacle
function CRHelper.Razorthorn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not CRHelper.savedVariables.trackRazorthorn or targetType ~= COMBAT_UNIT_TYPE_PLAYER) then return end

	if (result == ACTION_RESULT_EFFECT_GAINED) then

		CRReticle_Label:SetText("|cFF0000ROOTED|r")
		CRReticle:SetHidden(false)
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

	elseif (result == ACTION_RESULT_EFFECT_FADED) then

		CRReticle:SetHidden(true)

	end

end

-- Orb projectile
function CR.MaliciousStrike(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not CRHelper.savedVariables.trackMaliciousStrike or targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end

	if result == ACTION_RESULT_EFFECT_GAINED and hitValue > 1 then

		CRReticle_Label:SetText("|cFF0000BLOCK|r")
		CRReticle:SetHidden(false)
		PlaySound(SOUNDS.TELVAR_MULTIPLIERUP)

		zo_callLater(function() CRReticle:SetHidden(true) end, hitValue + 100)

	end

end

-- Shade's Heavy Attack
function CR.ShadeHeavyAttack(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not CR.savedVariables.trackCorpulence or targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end

	if result == ACTION_RESULT_BEGIN then

		local color = "FFFFFF"
		if string.find(sourceName, 'Relequen') then color = "FFFF00"
		elseif string.find(sourceName, 'Siroria') then color = "FF6600"
		elseif string.find(sourceName, 'Galenwe') then color = "00FFFF" end

		table.insert(heavyAttackList, {GetGameTimeMilliseconds() + hitValue, color})

		CR.HeavyAttackTimer()
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

		EVENT_MANAGER:UnregisterForUpdate("CRHeavyAttackTimer")
		EVENT_MANAGER:RegisterForUpdate("CRHeavyAttackTimer", 100, CR.HeavyAttackTimer)

	end

end

function CR.HeavyAttackTimer()

	local text = FormatHeavyAttackList()

	if not text or text == "" then
		EVENT_MANAGER:UnregisterForUpdate("CRHeavyAttackTimer")
		CRReticle:SetHidden(true)
	else
		CRReticle_Label:SetText(string.format('HA: %s', text))
		CRReticle:SetHidden(false)
	end

end

-------------------
-- Notifies about crushing darkness and starts a Cooldown timer for Crushing Darkness
-------------------
function CRHelper.CrushingDarkness(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	
	if ( result ~= ACTION_RESULT_EFFECT_GAINED ) then return end
	
	if ( targetType == COMBAT_UNIT_TYPE_PLAYER and CRHelper.savedVariables.trackCrushingDarkness) then

		local messageParams = CSA:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
		messageParams:SetText( "|cff5d00 Crushing Darkness is on you! |r")
		messageParams:SetPriority(CRHelper.CrushingDarkness_CSA_Priority)
		CSA:AddMessageWithParams(messageParams)

	end

	if ( not CRHelper.savedVariables.trackCrushingDarknessTimer ) then return end

	CRHelper.CrushingDarknessTimer = 28
	CRHelperFrame:SetHidden(false)
	CRHelperFrame_CrushingDarknessTimer:SetHidden(false)
	CRHelper.CrushingDarknessTimerUpdate()

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
-------------------

-------------------
-- Fires a notification when orbs are going to spawn
-------------------
function CR.MalevolentCoreHit(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not CR.savedVariables.trackMalevolentCore then return end

	if sourceUnitId > 0 and result == ACTION_RESULT_EFFECT_GAINED then

		if not malevolentCoreIds[sourceUnitId] then
			malevolentCoreIds[sourceUnitId] = true
			malevolentCoreNum = malevolentCoreNum + 1
		end

		CRHelperFrame:SetHidden(false)
		CRHelperFrame_MalevolentCoreCounter:SetText("|t32:32:esoui/art/compass/compass_bg_murderball_purple.dds|t|t32:32:esoui/art/buttons/large_rightarrow_up.dds|t".. malevolentCoreNum)
		CRHelperFrame_MalevolentCoreCounter:SetHidden(false)

	end

end
-------------------

-------------------
-- Fires a notification when orbs are going to spawn
-------------------
function CRHelper.OlorimeSpearGrant(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( not CRHelper.savedVariables.trackOlorimeSpear ) then return end

	if ( result == ACTION_RESULT_EFFECT_FADED ) then

		CRHelper.OlorimeSpearCounter = CRHelper.OlorimeSpearCounter + 1
		CRHelperFrame:SetHidden(false)
		CRHelperFrame_OlorimeSpearCounter:SetText("|t32:32:esoui/art/tutorial/progression_tabicon_solspear_up.dds|t|t32:32:esoui/art/buttons/large_rightarrow_up.dds|t".. CRHelper.OlorimeSpearCounter )
		CRHelperFrame_OlorimeSpearCounter:SetHidden(false)

	end

end
-------------------
-------------------
-- This function will be called when portal opens
-------------------
function CRHelper.SRealmOpen(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	-- Restart Counters after shadow realm opens
	CRHelperFrame_MalevolentCoreCounter:SetHidden(true)
	CRHelperFrame_OlorimeSpearCounter:SetHidden(true)

	CR.OlorimeSpearCounter = 0
	malevolentCoreIds = {}
	malevolentCoreNum = 0

	if not CR.savedVariables.trackPortalTimer then return end

	if result == ACTION_RESULT_EFFECT_GAINED then
		CR.stopPortalTimer = true
		CRHelperFrame_PortalTimer:SetHidden(true)
	end

end

-------------------
-- Updates and shows a timer for next portal phase
-------------------
function CRHelper.SRealmCoolDownUpdate(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	
	-- Will fix interrupt message of shadow realm boss from displaying after portal closes
	CRInterrupt:SetHidden(true)

	-- Hide Counters when Shadow Realm is closed
	CRHelperFrame_MalevolentCoreCounter:SetHidden(true)
	CRHelperFrame_OlorimeSpearCounter:SetHidden(true)
	CRHelper.MalevolentCoreCounter = 0
	CRHelper.OlorimeSpearCounter = 0

	if ( not CRHelper.savedVariables.trackPortalTimer ) then return end

	if ( result == ACTION_RESULT_EFFECT_FADED ) then

		CRHelper.portalTimer = 46
		CRHelper.stopPortalTimer = false
		CRHelperFrame:SetHidden(false)
		CRHelperFrame_PortalTimer:SetHidden(false)
		CRHelper.PortalTimerUpdate()

	end

end

-- This function is called on every wipe when fighting main boss in Cloudrest
function CRHelper.ResetPortalTimer(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( result == ACTION_RESULT_EFFECT_GAINED ) then
		-- Sets starting group that goes to portal
		CRHelper.currentPortalGroup = 1;
		CRHelperFrame:SetHidden(true)
	end

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

	-- Primary target
	EVENT_MANAGER:RegisterForEvent("RoaringFlare", EVENT_COMBAT_EVENT, self.RoaringFlare)
	EVENT_MANAGER:AddFilterForEvent("RoaringFlare", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.roaringFlareId)

	-- Secondary target (only on execute)
	EVENT_MANAGER:RegisterForEvent("RoaringFlare2", EVENT_COMBAT_EVENT, self.RoaringFlare2)
	EVENT_MANAGER:AddFilterForEvent("RoaringFlare2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.roaringFlareId2)

	-- Initializes the arrow that will allow everyone to know where the Roaring Flare target is
	LibPI:HandleUpdate()

end

function CRHelper:UnregisterRoaringFlare()

	EVENT_MANAGER:UnregisterForEvent("RoaringFlare", EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent("RoaringFlare2", EVENT_COMBAT_EVENT)

end

-- Formats and returns one name or concatinates two names into one string
function CRHelper.FormatRoaringFlareMessage()

	local tag1 = LUNIT:GetUnitTagForUnitId(CRHelper.fireTargetUnit1)
	local tag2 = LUNIT:GetUnitTagForUnitId(CRHelper.fireTargetUnit2)

	local player1IsHealer = GetGroupMemberSelectedRole( tag1 ) == 4
	local player2IsHealer = GetGroupMemberSelectedRole( tag2 ) == 4

	local name1 = AreUnitsEqual('player', tag1) and '|cFFFFFFYOU|r' or GetUnitName( tag1 )
	local name2 = AreUnitsEqual('player', tag2) and '|cFFFFFFYOU|r' or GetUnitName( tag2 )

	-- 2 players with roaring flare
	if (CRHelper.fireTargetUnit1 > 0 and CRHelper.fireTargetUnit2 > 0) then
		
		if player1IsHealer or player2IsHealer then

			local groupSize = GetGroupSize()
			local healers = {}

			for i = 0, groupSize, 1 do
				local unit = GetGroupUnitTagByIndex(i)
				if GetGroupMemberSelectedRole( unit ) == 4 then
					table.insert(healers, unit)
				end
			end

			if table.getn(healers) > 1 then
				if GetUnitName(healers[1]) > GetUnitName(healers[2]) then
					local aux = healers[1]
					healers[1] = healers[2]
					healers[2] = aux
				end
			end

			if player1IsHealer and tag1 ~= healers[1] then
				local aux = name1
				name1 = name2
				name2 = aux
			elseif player2IsHealer and tag2 ~= healers[2] then
				local aux = name1
				name1 = name2
				name2 = aux
			end

		end

		return zo_strformat(CRHelper.roaringFlareMessage2, name1, name2, CRHelper.fireCount)
	-- 1 player with roaring flare
	elseif (CRHelper.fireTargetUnit1 > 0 and CRHelper.fireTargetUnit2 == 0) then
		return zo_strformat(CRHelper.roaringFlareMessage, name1, CRHelper.fireCount)
	-- 1 player with secondary roaring flare (probably can happen if main target dies)
	elseif (CRHelper.fireTargetUnit1 == 0 and CRHelper.fireTargetUnit2 > 0) then
		return zo_strformat(CRHelper.roaringFlareMessage, name2, CRHelper.fireCount)
	else
		return ""
	end

end

-- Main function to handle Roaring Flare event
function CRHelper.RoaringFlare(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not CRHelper.savedVariables.trackRoaringFlare) then return end

	if (result == ACTION_RESULT_BEGIN) then
	
		CRHelper.fireTargetUnit1 = targetUnitId
		CRHelper.fireCount = CRHelper.roaringFlareDuration

		if (CRHelper.savedVariables.positionIndicatorEnabled and targetType ~= COMBAT_UNIT_TYPE_PLAYER) then
			LibPI:SetTargetUnitTag(LUNIT:GetUnitTagForUnitId(targetUnitId))
			LibPI:PostitionIndicatorShow()
		end

		EVENT_MANAGER:UnregisterForUpdate("FireTimer")
		EVENT_MANAGER:RegisterForUpdate("FireTimer", 1000, CRHelper.FireTimerTick)

		CRHelper.FireControlShow(CRHelper.FormatRoaringFlareMessage())
		PlaySound(SOUNDS.DUEL_START)

	elseif (result == ACTION_RESULT_EFFECT_FADED) then

		CRHelper.fireTargetUnit1 = 0

		-- if secondary target still has fire, then don't hide the timer
		-- can happen if main target dies before the explosion
		if (CRHelper.fireTargetUnit2 == 0) then
			CRHelper.FireTimerStopAndHide()
		end

	end

end

-- Handles Roaring Flare for secondary target on execute
-- We only set CRHelper.fireTargetUnit2 value here and change arrow target if needed
function CRHelper.RoaringFlare2(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not CRHelper.savedVariables.trackRoaringFlare) then return end
	
	if (result == ACTION_RESULT_BEGIN) then

		CRHelper.fireTargetUnit2 = targetUnitId	
		CRHelper.FireControlShow(CRHelper.FormatRoaringFlareMessage())

		if (CRHelper.savedVariables.positionIndicatorEnabled and targetType ~= COMBAT_UNIT_TYPE_PLAYER) then
			LibPI:SetTargetUnitTag(LUNIT:GetUnitTagForUnitId(targetUnitId))
			LibPI:PostitionIndicatorShow()
		end

	elseif (result == ACTION_RESULT_EFFECT_FADED) then

		CRHelper.fireTargetUnit2 = 0

		-- if primary target still has fire, then don't hide the timer
		-- can happen if secondary target dies before the explosion
		if (CRHelper.fireTargetUnit1 == 0) then
			CRHelper.FireTimerStopAndHide()
		end

	end

end

-- Countdown tick
function CRHelper.FireTimerTick()

	CRHelper.fireCount = CRHelper.fireCount - 1

	if (CRHelper.fireCount < 0) then
		CRHelper.fireTargetUnit1 = 0
		CRHelper.fireTargetUnit2 = 0
		CRHelper.FireTimerStopAndHide()
	else
		CRHelper.FireControlShow(CRHelper.FormatRoaringFlareMessage())
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
	for i, id in ipairs(self.hoarfrostCastIds) do
		EVENT_MANAGER:RegisterForEvent("HoarfrostCast" .. i, EVENT_COMBAT_EVENT, self.HoarfrostCast)
		EVENT_MANAGER:AddFilterForEvent("HoarfrostCast" .. i, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
	end

	-- COUNTDOWN
	for i, id in ipairs(self.hoarfrostIds) do
		EVENT_MANAGER:RegisterForEvent("Hoarfrost" .. i, EVENT_COMBAT_EVENT, self.Hoarfrost)
		EVENT_MANAGER:AddFilterForEvent("Hoarfrost" .. i, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
	end

	-- SYNERGY AVAILABLE
	for i, id in ipairs(self.hoarfrostSynergyIds) do
		EVENT_MANAGER:RegisterForEvent("HoarfrostSynergy" .. i, EVENT_COMBAT_EVENT, self.HoarfrostSynergy)
		EVENT_MANAGER:AddFilterForEvent("HoarfrostSynergy" .. i, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
	end
	
	-- AOE
	EVENT_MANAGER:RegisterForEvent("HoarfrostAoe", EVENT_COMBAT_EVENT, self.HoarfrostAoe)
	EVENT_MANAGER:AddFilterForEvent("HoarfrostAoe", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.hoarfrostAoeId)

end

function CRHelper:UnregisterHoarfrost()

	for i, id in ipairs(self.hoarfrostCastIds) do
		EVENT_MANAGER:UnregisterForEvent("HoarfrostCast" .. i, EVENT_COMBAT_EVENT)
	end
	for i, id in ipairs(self.hoarfrostIds) do
		EVENT_MANAGER:UnregisterForEvent("Hoarfrost" .. i, EVENT_COMBAT_EVENT)
	end
	for i, id in ipairs(self.hoarfrostSynergyIds) do
		EVENT_MANAGER:UnregisterForEvent("HoarfrostSynergy" .. i, EVENT_COMBAT_EVENT)
	end
	EVENT_MANAGER:UnregisterForEvent("HoarfrostAoe", EVENT_COMBAT_EVENT)

end

function CRHelper.HoarfrostCast(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not CRHelper.savedVariables.trackHoarfrost or targetType ~= COMBAT_UNIT_TYPE_PLAYER) then return end

	if (result == ACTION_RESULT_EFFECT_GAINED) then

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

	-- SHOCK INC
	for i, id in ipairs(self.voltaicCurrentIds) do
		EVENT_MANAGER:RegisterForEvent("VoltaicCurrent" .. i, EVENT_COMBAT_EVENT, self.VoltaicCurrent)
		EVENT_MANAGER:AddFilterForEvent("VoltaicCurrent" .. i, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
	end

	-- DEBUFF
	for i, id in ipairs(self.voltaicOverloadIds) do
		EVENT_MANAGER:RegisterForEvent("VoltaicOverload" .. i, EVENT_EFFECT_CHANGED, self.VoltaicOverload)
		EVENT_MANAGER:AddFilterForEvent("VoltaicOverload" .. i, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, id)
	end

end

function CRHelper:UnregisterVoltaicCurrent()

	-- SHOCK INC
	for i, id in ipairs(self.voltaicCurrentIds) do
		EVENT_MANAGER:UnregisterForEvent("VoltaicCurrent" .. i, EVENT_COMBAT_EVENT)
	end

	-- DEBUFF
	for i, id in ipairs(self.voltaicOverloadIds) do
		EVENT_MANAGER:UnregisterForEvent("VoltaicOverload" .. i, EVENT_EFFECT_CHANGED)
	end

end

function CR.VoltaicCurrent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not CR.savedVariables.trackVoltaicOverload or targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end

	if result == ACTION_RESULT_EFFECT_GAINED then

		voltaicCurrentEnd = GetGameTimeMilliseconds() + 3000
		CR.VoltaicCurrentTimer()
		PlaySound(SOUNDS.DUEL_START)
		SlideInControl(CRShock)

		EVENT_MANAGER:UnregisterForUpdate("CRVoltaicCurrentTimer")
		EVENT_MANAGER:RegisterForUpdate("CRVoltaicCurrentTimer", 100, CR.VoltaicCurrentTimer)

	end

end

function CR.VoltaicCurrentTimer()

	local t = voltaicCurrentEnd - GetGameTimeMilliseconds()

	if t < 0 then
		EVENT_MANAGER:UnregisterForUpdate("CRVoltaicCurrentTimer")
		CR.ShockControlHide()
	else
		CR.ShockControlShow(string.format('SHOCK: |cFF0000%0.1f|r', t / 1000))
	end

end

function CR.VoltaicOverload(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName,  buffType, effectType, abilityType, statusEffectType)

	if not CR.savedVariables.trackVoltaicOverload or unitTag ~= "player" then return end

	if changeType == EFFECT_RESULT_FADED then

		CR.shockStarted = false
		StopControlAnimation(CRShock)

		CRShock_Label:SetText(string.format("|c98FB98%s|r", "CAN SWAP"))
		CR.FadeOutControl(CRShock, 1000)

		LibGlow:HideGlow()

		clipboard:SetHidden(true)

    elseif changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then

		CR.shockStarted = true
		CR.swapped = false
		CR.EnableShockTimer(beginTime, endTime)

    end

end

function CR.WeaponSwap()

	if CRHelper.shockStarted and not CRHelper.swapped then

		CRHelper.swapped = true
		CRHelper.ShockControlShow("NO SWAP: " .. string.format("%01d", CRHelper.shockCount))

		if CRHelper.savedVariables.voltaicOverloadExtra then
			clipboard:SetHidden(false)
		end

		if (CRHelper.savedVariables.voltaicOverloadScreenGlow) then LibGlow:ShowGlow() end

	else

		CRHelper.swapped = false
		clipboard:SetHidden(true)

	end

end

function CR.EnableShockTimer(beginTime, endTime)

	EVENT_MANAGER:UnregisterForUpdate("CRVoltaicOverloadTimer")
	EVENT_MANAGER:UnregisterForUpdate("CRVoltaicCurrentTimer")

	voltaicOverloadEnd = endTime

	PlaySound(SOUNDS.DUEL_START)
	CR.ShockTimerTick()
	BounceControl(CRShock)

	EVENT_MANAGER:RegisterForUpdate("CRVoltaicOverloadTimer", 100, CR.ShockTimerTick)

end

function CR.ShockTimerTick()

	local t = voltaicOverloadEnd - GetFrameTimeSeconds()

	if t < 0 then
		EVENT_MANAGER:UnregisterForUpdate("CRVoltaicOverloadTimer")
	else
		CR.ShockControlShow(CR.swapped and string.format("NO SWAP: |cFF0000%0.1f|r", t) or "SWAP NOW!")
	end

end

-- Show shock control with optional text
function CR.ShockControlShow(text)

	CRShock:SetHidden(false)

	if (text ~= nil) then
		CRShock_Label:SetText(text)
	end

end

function CR.ShockControlHide()

	CRShock:SetHidden(true)

end

----- /VOLTAIC OVERLOAD (SHOCK) -----



----- SHADOW SPLASH INTERRUPT ------

-- Shows a notification when boss is casting Shadow Splash and needs to be interrupted
function CRHelper.ShadowSplashCast(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not CRHelper.savedVariables.trackShadowSplashCast then return end

	if result == ACTION_RESULT_BEGIN then

		CRHelper.shadowSplashCount = CRHelper.shadowSplashDuration

		CRInterrupt_Warning:SetText(string.format("Interrupt: |cFF0000%.1f|r", CRHelper.shadowSplashCount))
		CRInterrupt:SetHidden(false)
		PlaySound(SOUNDS.SKILL_LINE_ADDED)

		EVENT_MANAGER:UnregisterForUpdate("ShadowSplashTimer")
		EVENT_MANAGER:RegisterForUpdate("ShadowSplashTimer", 100, CRHelper.ShadowSplashTimerTick)

	elseif result == ACTION_RESULT_EFFECT_FADED then

		CRInterrupt:SetHidden(true)

	end

end

function CRHelper.ShadowSplashTimerTick()

	CRHelper.shadowSplashCount = CRHelper.shadowSplashCount - 0.1

	if CRHelper.shadowSplashCount < 0 then
		EVENT_MANAGER:UnregisterForUpdate("ShadowSplashTimer")
		CRHelper.shadowSplashCount = 0
	end

	CRInterrupt_Warning:SetText(string.format("Interrupt: |cFF0000%.1f|r", CRHelper.shadowSplashCount))
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

	if (frameLeft and frameTop) then
		CRHelperFrame:ClearAnchors()
		CRHelperFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, frameLeft, frameTop)
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
	CRInterrupt_Warning:SetText("Interrupt: |cFF00003|r")

	CRHelperFrame:SetHidden(false)
	CRHelperFrame_PortalTimer:SetText("Useful Timers...")
	CRHelperFrame_PortalTimer:SetHidden(false)

	if (CRHelper.savedVariables.voltaicOverloadScreenGlow) then LibGlow:ShowGlow() end

	if CRHelper.savedVariables.voltaicOverloadExtra then clipboard:SetHidden(false) end

end

function CRHelper:lockUI()

	CR.HideControls()

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

	if ( command == 'track 1' ) then
		CRHelper.trackCombatEvents = true
		d('CRHelper: started tracking combat events.')
	end

	if ( command == 'track 0' ) then
		CRHelper.trackCombatEvents = false
		d('CRHelper: stopped tracking combat events.')
	end

end

EVENT_MANAGER:RegisterForEvent(CRHelper.name, EVENT_ADD_ON_LOADED, CRHelper.OnAddOnLoaded)
