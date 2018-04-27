
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
        name = CRHelper.name,
        displayName = 'Cloudrest Helper',
        author = "@Andy.s & @RoMarQ",
        version = "v"..CRHelper.version,
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
			tooltip = "Allows for positioning of UI",
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
			end
		},
		{
			type = "checkbox",
			name = "Hoarfrost",
			tooltip = "Frost Mechanic",
            default = settings.trackHoarfrost,
			getFunc = function() return CRHelper.savedVariables.trackHoarfrost end,
			setFunc = function(value)
				CRHelper.savedVariables.trackHoarfrost = value or false
			end
		},
		{
			type = "checkbox",
			name = "Voltaic Overload",
			tooltip = "Weapon Swap Mechanic",
            default = settings.trackVoltaicOverload,
			getFunc = function() return CRHelper.savedVariables.trackVoltaicOverload end,
			setFunc = function(value)
				CRHelper.savedVariables.trackVoltaicOverload = value or false
			end
		},
		{
			type = "checkbox",
			name = "Laser Beam",
			tooltip = "Beam that comes from main boss head",
            default = settings.trackLaserBeam,
			getFunc = function() return CRHelper.savedVariables.trackLaserBeam end,
			setFunc = function(value)
				CRHelper.savedVariables.trackLaserBeam = value or false
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
			name = "Portal Timer (Not Working properly)",
            default = settings.trackPortalTimer,
			getFunc = function() return CRHelper.savedVariables.trackPortalTimer end,
			setFunc = function(value)
				CRHelper.savedVariables.trackPortalTimer = value or false
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
			width = "half"
		},
		{
			type = "dropdown",
			name = "Arrow Texture",
			choices = {"Round Arrow" , "Arrow"},
			choicesValues = {1, 2},
			getFunc = function() return CRHelper.savedVariables.positionIndicatorTexture end,
			setFunc = function(value)
				SetSavedVars("positionIndicatorTexture", value)
				LibPI:ApplyStyle()
			end,
			width = "half",
			default = settings.positionIndicatorTexture,
		},
		{
			type = "slider",
			name = "Arrow Scale",
			min = 0,
			max = 2,
			step = 0.1,
			decimals = 1,
			clampInput = true,
			getFunc = function() return CRHelper.savedVariables.positionIndicatorScale end,
			setFunc = function(value)
				SetSavedVars("positionIndicatorScale", value)
				LibPI:ApplyStyle()
			end,
			default = settings.positionIndicatorScale,
			width = "half",
		},
	}

    LAM:RegisterOptionControls(CRHelper.name.."Options", options)

end