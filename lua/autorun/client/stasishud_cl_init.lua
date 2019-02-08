hook.Add("HUDShouldDraw", "StasisHUDHideDarkRPHUD", function( name )
	if name == "DarkRP_EntityDisplay" or name == "DarkRP_HUD" then
		return false
	end
end)

local hl2hud = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
}

hook.Add("HUDShouldDraw", "hl2hud", function ( name )
	if hl2hud[name] then
		return false
	end
end)

hook.Add("HUDDrawTargetID", "hl2targ", function ( ply )
	return false
end)

--[[--------------------------------------------------
	Fonts
----------------------------------------------------]]
surface.CreateFont("StasisHUDFont",{
	font = "Space Mono",
	extended = false,
	size = 24,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("StasisHUDWeaponTitleFont",{
	font = "Space Mono",
	extended = false,
	size = 24,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("StasisHUDWeaponSelectorFont",{
	font = "Space Mono",
	extended = false,
	size = 20,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("StasisHUDWeaponFont",{
	font = "Space Mono",
	extended = false,
	size = 28,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("StasisHUDAmmoFont",{
	font = "Space Mono",
	extended = false,
	size = 32,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("StasisHUDAmmoReservedFont",{
	font = "Space Mono",
	extended = false,
	size = 20,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("StasisHUDXPFont",{
	font = "Space Mono",
	extended = false,
	size = 16,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("StasisHUDPlayerFont",{
	font = "Space Mono",
	extended = false,
	size = 42,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

--[[--------------------------------------------------
	Icons
----------------------------------------------------]]
healthIcon = Material("health.png")
batteryIcon = Material("battery.png")