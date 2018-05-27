function CRHelper.buildMenu( savedVars )
	local LAM = LibStub('LibAddonMenu-2.0')
	local LibPI = LibStub:GetLibrary("LibPositionIndicator")
	local settings = savedVars
	
	local function SetSavedVars(control, value)
		settings[control] = value
		CRHelper.savedVariables[control] = value
	end

    local panelInfo = {
        type = 'panel',
        name = 'Immersive Fishing',
        displayName = 'Immersive Fishing',
        author = "@andy.s & @RoMarQ",
        version = CRHelper.version,
        registerForRefresh = true
    }

    LAM:RegisterAddonPanel(CRHelper.name.."Options", panelInfo)

    local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = "UI Locked",
			tooltip = "Allows to reposition notifications",
			getFunc = function() return true end,
			setFunc = function(value)
				if not value then
					CRHelper.unlockUI()
				else
					CRHelper.lockUI()
				end
			end
		},
		{
			type = "header",
			name = "General Options"
		},
		{
			type = "checkbox",
			name = "Roaring Flare",
			tooltip = "Fire Explosion",
            default = settings.trackRoaringFlare,
			getFunc = function() return CRHelper.savedVariables.trackRoaringFlare end,
			setFunc = function(value)
				CRHelper.savedVariables.trackRoaringFlare = value or false
			end,
			width = "half",
		},
		{
			type = "colorpicker",
			default = ZO_ColorDef:New(unpack(CRHelper.savedVariables.RoaringFlareColor)),
			getFunc = function() return unpack(CRHelper.savedVariables.RoaringFlareColor) end,
			setFunc = function(r, g, b)
				SetSavedVars("RoaringFlareColor", {r, g, b})
				CRFire_Label:SetColor(unpack(CRHelper.savedVariables.RoaringFlareColor))
			end,
			width = "half",
			disabled = function() return not CRHelper.savedVariables.trackRoaringFlare end,
		},
		{
			type = "checkbox",
			name = "Hoarfrost",
			tooltip = "Frost Mechanic",
            default = settings.trackHoarfrost,
			getFunc = function() return CRHelper.savedVariables.trackHoarfrost end,
			setFunc = function(value)
				CRHelper.savedVariables.trackHoarfrost = value or false
			end,
			width = 'half',
		},
		{
			type = "colorpicker",
			default = ZO_ColorDef:New(unpack(CRHelper.savedVariables.HoarfrostColor)),
			getFunc = function() return unpack(CRHelper.savedVariables.HoarfrostColor) end,
			setFunc = function(r, g, b)
				SetSavedVars("HoarfrostColor", {r, g, b})
				CRFrost_Label:SetColor(unpack(CRHelper.savedVariables.HoarfrostColor))
			end,
			width = "half",
			disabled = function() return not CRHelper.savedVariables.trackHoarfrost end,
		},
		{
			type = "checkbox",
			name = "Voltaic Overload",
			tooltip = "Weapon Swap Mechanic",
            default = settings.trackVoltaicOverload,
			getFunc = function() return CRHelper.savedVariables.trackVoltaicOverload end,
			setFunc = function(value)
				CRHelper.savedVariables.trackVoltaicOverload = value or false
			end,
			width = "half",
		},
		{
			type = "colorpicker",
			default = ZO_ColorDef:New(unpack(CRHelper.savedVariables.VoltaicOverloadColor)),
			getFunc = function() return unpack(CRHelper.savedVariables.VoltaicOverloadColor) end,
			setFunc = function(r, g, b)
				SetSavedVars("VoltaicOverloadColor", {r, g, b})
				CRShock_Label:SetColor(unpack(CRHelper.savedVariables.VoltaicOverloadColor))
			end,
			width = "half",
			disabled = function() return not CRHelper.savedVariables.trackVoltaicOverload end,
		},
		{
			type = "checkbox",
			name = "Crushing Darkness",
			tooltip = "Beam that comes from main boss head",
            default = settings.trackCrushingDarkness,
			getFunc = function() return CRHelper.savedVariables.trackCrushingDarkness end,
			setFunc = function(value)
				CRHelper.savedVariables.trackCrushingDarkness = value or false
			end
		},
		{
			type = "checkbox",
			name = "Shadow Splash Cast",
			tooltip = "Tells you when to interrupt main boss",
            default = settings.trackShadowSplashCast,
			getFunc = function() return CRHelper.savedVariables.trackShadowSplashCast end,
			setFunc = function(value)
				CRHelper.savedVariables.trackShadowSplashCast = value or false
			end
		},
		{
			type = "checkbox",
			name = "Portal Spawn",
            default = settings.trackPortalSpawn,
			getFunc = function() return CRHelper.savedVariables.trackPortalSpawn end,
			setFunc = function(value)
				CRHelper.savedVariables.trackPortalSpawn = value or false
			end
		},
		{
			type = "checkbox",
			name = "Orbs Spawn",
            default = settings.trackOrbSpawn,
			getFunc = function() return CRHelper.savedVariables.trackOrbSpawn end,
			setFunc = function(value)
				CRHelper.savedVariables.trackOrbSpawn = value or false
			end
		},
		{
			type = "header",
			name = "Central Alerts"
		},
		{
			type = "description",
			text = "|cFF0000Important alerts in the middle of the screen. Disable at your own risk.|r"
		},
		{
			type = "checkbox",
			name = "Baneful Barb",
			tooltip = "Debuff from a spider",
            default = settings.trackBanefulBarb,
			getFunc = function() return CRHelper.savedVariables.trackBanefulBarb end,
			setFunc = function(value)
				CRHelper.savedVariables.trackBanefulBarb = value
			end
		},
		{
			type = "checkbox",
			name = "Corpulence",
			tooltip = "Heavy Attack by a spider",
            default = settings.trackCorpulence,
			getFunc = function() return CRHelper.savedVariables.trackCorpulence end,
			setFunc = function(value)
				CRHelper.savedVariables.trackCorpulence = value
			end
		},
		{
			type = "checkbox",
			name = "Nocturnals Favor",
			tooltip = "Pokeball",
            default = settings.trackNocturnalsFavor,
			getFunc = function() return CRHelper.savedVariables.trackNocturnalsFavor end,
			setFunc = function(value)
				CRHelper.savedVariables.trackNocturnalsFavor = value
			end
		},
		{
			type = "checkbox",
			name = "Razorthorn",
			tooltip = "Root from a tentacle",
            default = settings.trackRazorthorn,
			getFunc = function() return CRHelper.savedVariables.trackRazorthorn end,
			setFunc = function(value)
				CRHelper.savedVariables.trackRazorthorn = value
			end
		},
		{
			type = "header",
			name = "Timers"
		},
		{
			type = "checkbox",
			name = "Portal",
            default = settings.trackPortalTimer,
			getFunc = function() return CRHelper.savedVariables.trackPortalTimer end,
			setFunc = function(value)
				CRHelper.savedVariables.trackPortalTimer = value
			end
		},
		{
			type = "checkbox",
			name = "Crushing Darkness",
            default = settings.trackCrushingDarknessTimer,
			getFunc = function() return CRHelper.savedVariables.trackCrushingDarknessTimer end,
			setFunc = function(value)
				CRHelper.savedVariables.trackCrushingDarknessTimer = value
			end
		},
		{
			type = "checkbox",
			name = "Baneful Mark (on execute)",
            default = settings.trackBanefulMarkTimer,
			getFunc = function() return CRHelper.savedVariables.trackBanefulMarkTimer end,
			setFunc = function(value)
				CRHelper.savedVariables.trackBanefulMarkTimer = value
			end
		},
		{
			type = "header",
			name = "Roaring Flare Options"
		},
		{
			type = "checkbox",
			name = "Display Target Direction",
            default = settings.positionIndicatorEnabled,
			getFunc = function() return CRHelper.savedVariables.positionIndicatorEnabled end,
			setFunc = function(value)
				CRHelper.savedVariables.positionIndicatorEnabled = value
			end
		},
		{
			type = "colorpicker",
			name = "Arrow Color",
			default = ZO_ColorDef:New(unpack(CRHelper.savedVariables.positionIndicatorColor)),
			getFunc = function() return unpack(CRHelper.savedVariables.positionIndicatorColor) end,
			setFunc = function(r, g, b)
				SetSavedVars("positionIndicatorColor", {r, g, b})
				LibPI:ApplyStyle()
			end,
			width = "full",
			disabled = function() return not CRHelper.savedVariables.positionIndicatorEnabled end,
		},
		{
			type = "dropdown",
			name = "Arrow Texture",
			choices = {"Round Arrow" , "Arrow"},
			choicesValues = {1, 2},
			default = settings.positionIndicatorTexture,
			getFunc = function() return CRHelper.savedVariables.positionIndicatorTexture end,
			setFunc = function(value)
				SetSavedVars("positionIndicatorTexture", value)
				LibPI:ApplyStyle()
			end,
			width = "full",
			disabled = function() return not CRHelper.savedVariables.positionIndicatorEnabled end,
		},
		{
			type = "slider",
			name = "Arrow Scale",
			min = 1,
			max = 2,
			step = 0.1,
			decimals = 1,
			clampInput = true,
			default = settings.positionIndicatorScale,
			getFunc = function() return CRHelper.savedVariables.positionIndicatorScale end,
			setFunc = function(value)
				SetSavedVars("positionIndicatorScale", value)
				LibPI:ApplyStyle()
			end,
			width = "full",
			disabled = function() return not CRHelper.savedVariables.positionIndicatorEnabled end,
		},
		
		--
		-- Voltaic Overload Options
		--

		{
			type = "header",
			name = "Voltaic Overload Options"
		},
		{
			type = "checkbox",
			name = "Enable Screen Glow",
			tooltip = "Adds an additional screen effect while you have Voltaic Overload debuff and shouldn't swap weapons",
            default = settings.voltaicOverloadScreenGlow,
			getFunc = function() return CRHelper.savedVariables.voltaicOverloadScreenGlow end,
			setFunc = function(value)
				CRHelper.savedVariables.voltaicOverloadScreenGlow = value
			end
		},
		{
			type = "colorpicker",
			name = "Screen Glow Color",
			default = ZO_ColorDef:New(unpack(CRHelper.defaultSettings.voltaicOverloadScreenGlowColor)),
			getFunc = function() return unpack(CRHelper.savedVariables.voltaicOverloadScreenGlowColor) end,
			setFunc = function(r, g, b)
				SetSavedVars("voltaicOverloadScreenGlowColor", {r, g, b})
				LibGlow:SetGlowColor(r, g, b)
			end,
			width = "full",
			disabled = function() return not CRHelper.savedVariables.voltaicOverloadScreenGlowColor end,
		},
		{
			type = "slider",
			name = "Screen Glow Size",
			min = 0.1,
			max = 0.5,
			step = 0.01,
			decimals = 2,
			clampInput = true,
			default = settings.voltaicOverloadScreenGlowSize,
			getFunc = function() return CRHelper.savedVariables.voltaicOverloadScreenGlowSize end,
			setFunc = function(value)
				SetSavedVars("voltaicOverloadScreenGlowSize", value)
				LibGlow:SetGlowSize(value)
			end,
			width = "full",
			disabled = function() return not CRHelper.savedVariables.voltaicOverloadScreenGlowSize end,
		},

		{
			type = "header",
			name = "Roaring Flare Execute Setup"
		},
		{
			type = "description",
			text = "Players with fixed positions on execute should set the following roles:"
		},
		{
			type = "description",
			title = "Healer Left\n",
			text = "|t64:64:esoui/art/lfg/lfg_healer_up_64.dds|t"
		},
		{
			type = "description",
			title = "Healer Right\n",
			text = "|t64:64:esoui/art/lfg/lfg_healer_up_64.dds|t |t64:64:esoui/art/lfg/lfg_dps_up_64.dds|t"
		},
		{
			type = "description",
			title = "Tank Right\n",
			text = "|t64:64:esoui/art/lfg/lfg_tank_up_64.dds|t |t64:64:esoui/art/lfg/lfg_dps_up_64.dds|t"
		},
		{
			type = "description",
			title = "Tank Left\n",
			text = "|t64:64:esoui/art/lfg/lfg_tank_up_64.dds|t |t64:64:esoui/art/lfg/lfg_healer_up_64.dds|t"
		}
	}

    LAM:RegisterOptionControls(CRHelper.name.."Options", options)

end