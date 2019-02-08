--[[--------------------------------------------------
	Globals
----------------------------------------------------]]
local _g = {}

_g.color = {}
_g.color.background = Color(0, 0, 0, 200)
_g.color.black 		= Color(33, 33, 33, 255)
_g.color.orange 	= Color(255, 122, 0, 255)
_g.color.red 		= Color(244, 67, 54, 255)
_g.color.white 		= Color(255, 255, 255, 255)

_g.color.activeWeapon = Color(33, 33, 33, 255)
_g.color.armor 		= Color(253, 254, 254, 200)
_g.color.hpBar 		= Color(244, 67, 54, 255)
_g.color.hpBG 		= Color(0, 0, 0, 200)
_g.color.weapon		= Color(0, 0, 0, 100)
_g.color.weaponHeader = Color(0, 0, 0, 225)
_g.color.selectingWeapon = Color(0, 0, 0, 225)

_g.align = {}
_g.align.top = TEXT_ALIGN_TOP
_g.align.center = TEXT_ALIGN_CENTER
_g.align.bottom = TEXT_ALIGN_BOTTOM
_g.align.left = TEXT_ALIGN_LEFT
_g.align.right = TEXT_ALIGN_RIGHT

_g.barWidth = ScrW() * 0.20
_g.barHeight = ScrH() * 0.04

_g.offset = 30
_g.spacer = 5
_g.borderRadius = 4

_g.bottomLeft = {}
_g.bottomLeft.x = _g.offset
_g.bottomLeft.y = ScrH() - _g.offset
_g.bottomRight = {}
_g.bottomRight.x = ScrW() - _g.offset
_g.bottomRight.y = ScrH() - _g.offset

_g.hitMaxWarnCol = false
_g.barMoveSpeed = 1
_g.colorChangeSpeed = 1
_g.colorFlashSpeed = 1

--[[--------------------------------------------------
	Health & Armor
----------------------------------------------------]]
local function StasisHUDHealth( ply )
	-- Health
	local hpIcon = {}
	hpIcon.w = _g.barHeight
	hpIcon.h = _g.barHeight
	hpIcon.posX = _g.bottomLeft.x - hpIcon.w / 2
	hpIcon.posY = _g.bottomLeft.y - hpIcon.h
	hpIcon.color = _g.color.white
	
	local hpBG = {}
	hpBG.w = _g.barWidth
	hpBG.h = _g.barHeight * 0.75
	hpBG.posX = hpIcon.posX + hpIcon.w / 2
	hpBG.posY = hpIcon.posY + hpIcon.h / 2 - hpBG.h / 2
	hpBG.color = _g.color.hpBG

	local hpBar = {}
	hpBar.w = hpBG.w
	hpBar.h = hpBG.h - _g.borderRadius * 2
	hpBar.posX = hpBG.posX
	hpBar.posY = hpBG.posY + _g.borderRadius
	hpBar.color = _g.color.hpBar

	local hpText = {}
	hpText.posX = hpIcon.posX + hpIcon.w + _g.spacer
	hpText.posY = hpBar.posY + hpBar.h / 2 - 2
	hpText.color = _g.color.white
	
	-- Armor
	local armorBar = {}
	armorBar.w = hpBG.w
	armorBar.h = hpBG.h
	armorBar.posX = hpBar.posX
	armorBar.posY = hpBG.posY
	armorBar.color = _g.color.armor
	
	
	-- HP Calc
	local hp = ply:Health()
	local hpMax = ply:GetMaxHealth()
	local hpMult = hp / hpMax
	if hpMult < 0 then hpMult = 0 end
	if hpMult > 1 then hpMult = 1 end
	local hpPercent = math.Round(hpMult * 100)
	
	if hpMult <= stasishud.hpWarningNum then
		if !hitMaxWarnCol and hpBG.color.r < 100 then
			hpBG.color.r = hpBG.color.r + _g.colorFlashSpeed
		end
		
		if hpBG.color.r >= 100 then
			hitMaxWarnCol = true
		end
		
		if hitMaxWarnCol and hpBG.color.r > 0 then
			hpBG.color.r = hpBG.color.r - _g.colorFlashSpeed
		end
		
		if hpBG.color.r <= 0 then
			hitMaxWarnCol = false
		end
	elseif hp > stasishud.hpWarningNum then
		if hpBG.color.r > 0 then
			hpBG.color.r = hpBG.color.r - _g.colorChangeSpeed
		end
	end
	
	-- Armor Calc
	local armor = ply:Armor()
	local armorMax = 255
	local armorMult = armor / armorMax
	
	-- Bars
	draw.RoundedBox(_g.borderRadius, hpBG.posX, hpBG.posY, hpBG.w, hpBG.h, hpBG.color)
	draw.RoundedBox(_g.borderRadius, armorBar.posX, armorBar.posY, armorBar.w * armorMult, armorBar.h, armorBar.color)
	draw.RoundedBox(0, hpBar.posX, hpBar.posY, hpBar.w * hpMult, hpBar.h, hpBar.color)

	-- HP Icon
	surface.SetMaterial(healthIcon)
	surface.SetDrawColor(hpIcon.color)
	surface.DrawTexturedRect(hpIcon.posX, hpIcon.posY, hpIcon.w, hpIcon.h)
	
	-- HP Text
	draw.SimpleText(hpPercent .. "%", "StasisHUDFont", hpText.posX, hpText.posY, hpText.color, _g.align.left, _g.align.center)
end


--[[--------------------------------------------------
	Player Info
----------------------------------------------------]]
local function StasisHUDPlayer( ply )
	local playerBG = {}
	playerBG.w = _g.barWidth
	playerBG.h = _g.barHeight * 1.5
	playerBG.posX = _g.bottomLeft.x
	playerBG.posY = _g.bottomLeft.y - _g.barHeight - _g.spacer * 2 - playerBG.h
	playerBG.color = _g.color.background
	
	local playerSpacer = {}
	playerSpacer.w = playerBG.w - _g.offset * 10
	playerSpacer.h = _g.spacer / 4
	playerSpacer.posX = playerBG.posX + playerBG.w / 2 - playerSpacer.w / 2
	playerSpacer.posY = playerBG.posY + playerBG.h / 2
	playerSpacer.color = _g.color.white
	
	local playerText = {}
	playerText.posX = playerBG.posX + playerBG.w / 2
	playerText.posY = playerBG.posY + playerBG.h / 4
	playerText.color = _g.color.white
	
	local name = string.upper(ply:Nick() or "")
	local job = string.upper(ply:getDarkRPVar("job") or "")
	
	draw.RoundedBox(_g.borderRadius, playerBG.posX, playerBG.posY, playerBG.w, playerBG.h, playerBG.color)
	draw.SimpleText(name, "StasisHUDFont", playerText.posX, playerText.posY, playerText.color, _g.align.center, _g.align.center)
	draw.RoundedBox(playerSpacer.h, playerSpacer.posX, playerSpacer.posY, playerSpacer.w, playerSpacer.h, playerSpacer.color)
	draw.SimpleText(job, "StasisHUDFont", playerText.posX, playerText.posY + playerBG.h / 2, playerText.color, _g.align.center, _g.align.center)
end


--[[--------------------------------------------------
	Weapon & Ammo
----------------------------------------------------]]
local function StasisHUDWeapon( ply )
	local weaponBG = {}
	weaponBG.w = _g.barWidth
	weaponBG.h = _g.barHeight * 1.5
	weaponBG.posX = _g.bottomRight.x - weaponBG.w
	weaponBG.posY = _g.bottomRight.y - weaponBG.h - _g.barHeight * 0.75 - _g.spacer * 4
	weaponBG.color = _g.color.background
	
	local ammoIcon = {}
	ammoIcon.w = _g.barHeight
	ammoIcon.h = _g.barHeight
	ammoIcon.posX = weaponBG.posX + _g.spacer
	ammoIcon.posY = weaponBG.posY + ammoIcon.h / 4
	ammoIcon.color = _g.color.white
	
	local ammoText = {}
	ammoText.posX = ammoIcon.posX + ammoIcon.w + _g.spacer
	ammoText.posY = ammoIcon.posY + ammoIcon.h / 3
	ammoText.color = _g.color.white
	
	local weaponText = {}
	weaponText.posX = weaponBG.posX + weaponBG.w - _g.spacer * 2
	weaponText.posY = weaponBG.posY + weaponBG.h / 2
	weaponText.align = _g.align.right
	
	-- Weapon BG
	draw.RoundedBox(_g.borderRadius, weaponBG.posX, weaponBG.posY, weaponBG.w, weaponBG.h, weaponBG.color)
	
	-- Ammo Calc
	local playerWeapon = ply:GetActiveWeapon()

	if playerWeapon and IsValid(playerWeapon) then
		local mag = playerWeapon:Clip1()
		local magMax = playerWeapon:GetMaxClip1()
		local reserved = ply:GetAmmoCount(playerWeapon:GetPrimaryAmmoType())
		
		if mag > 99 then
			mag = 99
		end
		
		if magMax > 99 then
			magMax = 99
		end
		
		if mag <= 0 and reserved <= 0 then
			ammoText.color = _g.color.red
		end
		
		local ammoTxt = ""
		if mag ~= -1 then
			ammoTxt = mag
		end
		
		if magMax ~= -1 then
			ammoTxt = ammoTxt  .. "/" .. magMax
		end

		if mag == -1 and magMax == -1 and reserved then
			ammoTxt = reserved
			reserved = ""
			ammoText.posY = weaponBG.posY + weaponBG.h / 2
		end
		
		if ammoTxt == 0 and reserved == "" then 
		    weaponText.posX = weaponBG.posX + weaponBG.w / 2
		    weaponText.align = _g.align.center
	    else
	        
    		-- Ammo Icon
    	    surface.SetMaterial(batteryIcon)
    	    surface.SetDrawColor(ammoIcon.color)
    	    surface.DrawTexturedRect(ammoIcon.posX, ammoIcon.posY, ammoIcon.w, ammoIcon.h)
    	    
    		draw.SimpleTextOutlined(ammoTxt, "StasisHUDAmmoFont", ammoText.posX, ammoText.posY, ammoText.color, _g.align.left, _g.align.center, 1, _g.color.background)
    		draw.SimpleTextOutlined(reserved, "StasisHUDAmmoReservedFont", ammoText.posX, ammoText.posY + 20, ammoText.color, _g.align.left, _g.align.center, 1, _g.color.background)
		end
		
		local weaponTxt = playerWeapon:GetPrintName()
		
		if weaponTxt or language.GetPhrase(playerWeapon) then
			if string.len(weaponTxt) > 19 then
				weaponTxt = string.sub(weaponTxt, 1, 16) .. "..."
			end
			
		end
		draw.SimpleText(string.upper(weaponTxt), "StasisHUDWeaponFont", weaponText.posX, weaponText.posY, weaponText.color, weaponText.align, _g.align.center)
	end
end


--[[--------------------------------------------------
	Compass Bar
----------------------------------------------------]]
local function StasisHUDCompassBar( ply )
	local compassBG = {}
	compassBG.w = _g.barWidth
	compassBG.h = _g.barHeight - _g.spacer * 2
	compassBG.posX = _g.bottomRight.x - compassBG.w
	compassBG.posY = _g.bottomRight.y - compassBG.h - _g.spacer
	compassBG.color = _g.color.background
	
	local compassText = {}
	compassText.color = _g.color.white
	
	draw.RoundedBox(_g.borderRadius, compassBG.posX, compassBG.posY, compassBG.w, compassBG.h, compassBG.color)
	
	local compassPosX = compassBG.posX
	local ang = ply:EyeAngles()
	ang:Normalize()

	local CompassDirections = {
		"N",
		"NE",
		"E",
		"SE",
		"S",
		"SW",
		"W",
		"NW"
	}
	
	local deg = 360 - math.ceil(ang.y - 180)

	while deg > 360 do 
		deg = deg - 360 
	end

	while deg < 0 do 
		deg = deg + 360 
	end

	compasspad = 0 - compassPosX
	compassWidth = compassBG.w
	
	local i = 1
	local directioncounter = 3

	
	compassPosX = compassPosX + math.Round(compasspad - compassWidth * 3 / 2)

	compassPosX = compassPosX + ang.y / 180 * compassWidth
	
	render.SetScissorRect(compassBG.posX, compassBG.posY, compassBG.posX + compassWidth, compassBG.posY + compassBG.h, true)
	while i <= 18 do
		local txt = CompassDirections[directioncounter]

		draw.SimpleText(txt, "StasisHUDFont", compassPosX + 1450, compassBG.posY + compassBG.h / 2, compassText.color, _g.align.center, _g.align.center)

		compassPosX = compassPosX + math.Round(compassWidth / 4)
		i = i + 1
		directioncounter = directioncounter + 1

		if directioncounter > #CompassDirections then
			directioncounter = 1
		end
	end
	render.SetScissorRect(compassBG.posX, compassBG.posY, compassBG.posX + compassWidth, compassBG.posY + compassBG.h, false)
	
	local compassMarkerTop = {
		{ x = compassBG.posX + compassBG.w / 2 - 5, y = compassBG.posY },
		{ x = compassBG.posX + compassBG.w / 2 + 5, y = compassBG.posY},
		{ x = compassBG.posX + compassBG.w / 2, y = compassBG.posY + 5}
	}
	
	local compassMarkerBottom = {
		{ x = compassBG.posX + compassBG.w / 2 - 5, y = compassBG.posY + compassBG.h },
		{ x = compassBG.posX + compassBG.w / 2, y = compassBG.posY + compassBG.h - 5},
		{ x = compassBG.posX + compassBG.w / 2 + 5, y = compassBG.posY + compassBG.h }
	}
	
	surface.SetDrawColor(_g.color.white)
	draw.NoTexture()
	surface.DrawPoly(compassMarkerTop)
	surface.DrawPoly(compassMarkerBottom)
end


--[[--------------------------------------------------
	Agenda
----------------------------------------------------]]
local function StasisHUDAgenda( ply )
	local agendaBGW = ScrW() / 3
	local agendaBGH = _g.offset + _g.spacer
	local agendaBGPosX = ScrW() / 2 - agendaBGW / 2
	local agendaBGPosY = -_g.spacer
	local agendaBGColor = _g.color.background
	
	local agendaTextPosX = ScrW() / 2
	local agendaTextPosY = agendaBGH / 2 - _g.spacer
	local agendaTextColor = _g.color.white
	
	if !stasishud.isDarkRP then
		return
	end
	
	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_Agenda")
	
	if !shouldDraw then
		return
	end
	
	local agenda = LocalPlayer():getAgendaTable()
	
	if !agenda then
		return
	end
	
	local agendaText = agendaText or DarkRP.textWrap((LocalPlayer():getDarkRPVar("agenda") or ""):gsub("//", "\n"):gsub("\\n", "\n"), "StasisHUDFont", 440)
	
	if agendaText ~= "" then
		if string.find(string.upper(agendaText), "BATTLESTATION") then
			agendaTextColor = _g.color.red
		end
		
		if string.find(string.upper(agendaText), "ALERT") then
			agendaTextColor = _g.color.orange
		end
		
		draw.RoundedBox(_g.borderRadius, agendaBGPosX, agendaBGPosY, agendaBGW, agendaBGH, agendaBGColor)
		draw.SimpleTextOutlined(agendaText, "StasisHUDFont", agendaTextPosX, agendaTextPosY, agendaTextColor, _g.align.center, _g.align.center, 1, _g.color.background)
	end
end


--[[--------------------------------------------------
	DarkRP Doors
----------------------------------------------------]]
local function StasisHUDDoors( ply )
	local trace = ply:GetEyeTrace()
	local ent = trace.Entity
	
	if stasishud.isDarkRP and ent:isKeysOwnable() then
		local distance = ent:GetPos():Distance(ply:GetPos())
		
		if distance <= 150 then
			ent:drawOwnableInfo()
		end
	end
end


--[[--------------------------------------------------
	HUD Setup
----------------------------------------------------]]
local function StasisHUDDraw( ply )
	local ply = LocalPlayer()
	
	if ply:Alive() then
		StasisHUDDoors( ply )
		StasisHUDHealth( ply )
		StasisHUDPlayer( ply )
		StasisHUDWeapon( ply )
		StasisHUDCompassBar( ply )
		StasisHUDAgenda( ply )
	end
end


--[[--------------------------------------------------
	Player Target
----------------------------------------------------]]
local function StasisHUDTargetID( ply )
	if !ply:Alive() then
		return	
	end
	
	if ply:GetRenderMode() == RENDERMODE_TRANSALPHA then
		return
	end
	
	local distance = LocalPlayer():GetPos():Distance(ply:GetPos())
	local displayAng = LocalPlayer():EyeAngles()
	local displayPos = ply:GetPos() + Vector(0, 0, 80)
	local trace = LocalPlayer():GetEyeTrace()
	
	local healthColor = Color(255, 255 * (ply:Health()/ply:GetMaxHealth()), 255 * (ply:Health()/ply:GetMaxHealth()))
	
	if ply != LocalPlayer() then
		cam.Start3D2D(displayPos, Angle(0, displayAng.y - 90, 90), 0.15)
			if distance < 500 and ply:getDarkRPVar("job") then
			    local alpha = distance / 100
			    --local color = ColorAlpha(_g.color.white, 255 / math.min(1, alpha))
			    local color = ColorAlpha(healthColor, 100 / alpha)
			    local bgColor = ColorAlpha(_g.color.background, 100 / alpha)
				if stasishud.hideJob then
					draw.SimpleTextOutlined(ply:Nick() .. " ", "StasisHUDPlayerFont", 0, 0, color, _g.align.center, _g.align.top, 1, bgColor)
					
				elseif !stasishud.stackNameAndJob then
					draw.SimpleText("|", "StasisHUDFont", 0, 0, color, _g.align.center, _g.align.top)
					draw.SimpleText(ply:Nick() .. " ", "StasisHUDPlayerFont", 0, 0, color, _g.align.right, _g.align.top)
					draw.SimpleText(" " .. ply:getDarkRPVar("job"), "StasisHUDPlayerFont", 0, 0, color, _g.align.left, _g.align.top)
				elseif stasishud.stackNameAndJob then
					draw.SimpleText(ply:Nick(), "StasisHUDPlayerFont", 0, -25, color, _g.align.center, _g.align.top)
					draw.SimpleText(ply:getDarkRPVar("job"), "StasisHUDFont", 0, 0, color, _g.align.center, _g.align.top)
				end
				
				if ply:getDarkRPVar("Arrested") and !stasishud.stackNameAndJob then
					draw.SimpleText("Arrested", "StasisHUDPlayerFont", 0, -25, color, _g.align.center, _g.align.top)
				elseif ply:getDarkRPVar("Arrested") and stasishud.stackNameAndJob then
					draw.SimpleText("Arrested", "StasisHUDPlayerFont", 0, -50, color, _g.align.center, _g.align.top)
				end
			end
		cam.End3D2D()
	end
end


--[[--------------------------------------------------
	Notification
----------------------------------------------------]]
local function StasisHUDNotify( msg )
	local txt = msg:ReadString()
	
	GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
	
	surface.PlaySound("buttons/lightswitch2.wav")
	MsgC(_g.color.white, txt, "\n")
end
usermessage.Hook("_Notify", StasisHUDNotify)


hook.Add("HUDPaint", "StasisHUDDraw", StasisHUDDraw)
hook.Add("PostPlayerDraw", "StasisHUDTargetID", StasisHUDTargetID)