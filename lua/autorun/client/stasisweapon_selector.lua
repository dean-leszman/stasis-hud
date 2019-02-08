--[[--------------------------------------------------
	Globals
----------------------------------------------------]]
local _g = {}

_g.color = {}
_g.color.activeWeapon	= Color(33, 33, 33, 225)
_g.color.armor 		= Color(253, 254, 254, 200)
_g.color.background = Color(0, 0, 0, 200)
_g.color.black 		= Color(0, 0, 0, 255)
_g.color.white 		= Color(255, 255, 255, 255)
_g.color.weapon		= Color(0, 0, 0, 100)
_g.color.weaponHeader = Color(0, 0, 0, 225)
_g.color.selectingWeapon = Color(0, 0, 0, 225)

_g.align = {}
_g.align.top = TEXT_ALIGN_TOP
_g.align.center = TEXT_ALIGN_CENTER
_g.align.bottom = TEXT_ALIGN_BOTTOM
_g.align.left = TEXT_ALIGN_LEFT
_g.align.right = TEXT_ALIGN_RIGHT

_g.barWidth = ScrW() * 0.1
_g.barHeight = ScrH() * 0.03

_g.offset = 30
_g.spacer = 5
_g.borderRadius = 4


--[[ Config ]]--

local MAX_SLOTS = 5
local CACHE_TIME = 1
--local MOVE_SOUND = "Player.WeaponSelectionMoveSlot"
local MOVE_SOUND = "gmodadminsuite/btn_heavy.ogg"
--local SELECT_SOUND = "Player.WeaponSelected"
local SELECT_SOUND = "gmodadminsuite/btn_light.ogg"

--[[ Instance variables ]]--

local iCurSlot = 0 -- Currently selected slot. 0 = no selection
local iCurPos = 1 -- Current position in that slot
local flNextPrecache = 0 -- Time until next precache
local flSelectTime = 0 -- Time the weapon selection changed slot/visibility states. Can be used to close the weapon selector after a certain amount of idle time
local iWeaponCount = 0 -- Total number of weapons on the player

-- Weapon cache; table of tables. tCache[Slot + 1] contains a table containing that slot's weapons. Table's length is tCacheLength[Slot + 1]
local tCache = {}

-- Weapon cache length. tCacheLength[Slot + 1] will contain the number of weapons that slot has
local tCacheLength = {}

--[[ Weapon switcher ]]--
local function DrawWeaponHUD()
    local ply = LocalPlayer()
	if ply:Alive() == false then return end
	
	local weaponHeader = {}
	weaponHeader.width = _g.barWidth
	weaponHeader.height = _g.barHeight
	weaponHeader.posX = ScrW() / 2 - (2.5 * weaponHeader.width + 2.5 * _g.spacer)
	weaponHeader.posY = _g.spacer
	
	-- Draw here!
	for i = 1, #tCache do
		-- Slot headers
		local headerText = ""
		if (i == 1) then headerText = "PRIMARY" end
		if (i == 2) then headerText = "SECONDARY" end
		if (i == 3) then headerText = "HEAVY" end
		if (i == 4) then headerText = "MELEE" end
		if (i == 5) then headerText = "EQUIPMENT" end
		
		draw.RoundedBox(_g.borderRadius, weaponHeader.posX, weaponHeader.posY, weaponHeader.width, weaponHeader.height, _g.color.weaponHeader) -- Weapon headers
		draw.SimpleTextOutlined(headerText, "StasisHUDWeaponTitleFont", weaponHeader.posX + weaponHeader.width / 2, weaponHeader.posY + weaponHeader.height / 2 - 2, _g.color.white, _g.align.center, _g.align.center, 1, _g.color.black)
		
		--Weapon
		local weaponSlotPosY = weaponHeader.posY
		local weaponSlotColor
		local weaponSlotTextColor = _g.color.white
		local activeWeapon = ply:GetActiveWeapon()
		local drawOutline = false
		
		if (!IsValid(activeWeapon)) then
	        input.SelectWeapon(ply:GetWeapon("weapon_holster"))
        end
		
		PrintTable(ply:GetWeapons())
		for k, v in pairs(tCache[i]) do
			local weaponName = tCache[i][k]:GetPrintName()
			
			weaponSlotPosY = weaponSlotPosY + weaponHeader.height + _g.spacer
			
			if (iCurSlot == i and iCurPos == k) then
				weaponSlotColor = _g.color.activeWeapon
				weaponSlotTextColor = _g.color.white
				drawOutline = true
				
				draw.RoundedBox(_g.borderRadius, weaponHeader.posX + 2, weaponSlotPosY + 2, weaponHeader.width - 2 * 2, weaponHeader.height - 2 * 2, _g.color.white)
				draw.RoundedBox(_g.borderRadius, weaponHeader.posX + 2 * 2, weaponSlotPosY + 2 * 2, weaponHeader.width - 2 * 4, weaponHeader.height - 2 * 4, _g.color.black)
			else
				weaponSlotColor = _g.color.weapon
				weaponSlotTextColor = Color(255, 255, 255, 150)
			end
			
			draw.RoundedBox(_g.borderRadius, weaponHeader.posX, weaponSlotPosY, weaponHeader.width, weaponHeader.height, weaponSlotColor)
			
			weaponName = string.upper(weaponName)
			if #weaponName > 16 then
		        weaponName = string.sub(weaponName, 0, 14) .. ".."
		    end
			
			if (drawOutline) then
				draw.SimpleTextOutlined(weaponName, "StasisHUDWeaponSelectorFont", weaponHeader.posX + weaponHeader.width / 2, weaponSlotPosY + weaponHeader.height / 2, weaponSlotTextColor, _g.align.center, _g.align.center, 1, _g.color.black)
			else
				draw.SimpleText(weaponName, "StasisHUDWeaponSelectorFont", weaponHeader.posX + weaponHeader.width / 2, weaponSlotPosY + weaponHeader.height / 2, weaponSlotTextColor, _g.align.center, _g.align.center)
			end
			
			drawOutline = false
		end
		
		weaponHeader.posX = weaponHeader.posX + weaponHeader.width + _g.spacer * 3
	end
end

--[[ Implementation ]]--

-- Initialize tables with slot number
for i = 1, MAX_SLOTS do
	tCache[i] = {}
	tCacheLength[i] = 0
end

local pairs = pairs
local tonumber = tonumber
local RealTime = RealTime
local hook_Add = hook.Add
local LocalPlayer = LocalPlayer
local string_lower = string.lower
local input_SelectWeapon = input.SelectWeapon

-- Hide the default weapon selection
hook_Add("HUDShouldDraw", "GS_WeaponSelector", function(sName)
	if (sName == "CHudWeaponSelection") then
		return false
	end
end)

local function PrecacheWeps()
	-- Reset all table values
	for i = 1, MAX_SLOTS do
		for j = 1, tCacheLength[i] do
			tCache[i][j] = nil
		end

		tCacheLength[i] = 0
	end

	-- Update the cache time
	flNextPrecache = RealTime() + CACHE_TIME
	iWeaponCount = 0

	-- Discontinuous table
	for _, pWeapon in pairs(LocalPlayer():GetWeapons()) do
		iWeaponCount = iWeaponCount + 1

		-- Weapon slots start internally at "0"
		-- Here, we will start at "1" to match the slot binds
		local iSlot = pWeapon:GetSlot() + 1

		if (iSlot <= MAX_SLOTS) then
			-- Cache number of weapons in each slot
			local iLen = tCacheLength[iSlot] + 1
			tCacheLength[iSlot] = iLen
			tCache[iSlot][iLen] = pWeapon
		end
	end

	-- Make sure we're not pointing out of bounds
	if (iCurSlot ~= 0) then
		local iLen = tCacheLength[iCurSlot]

		if (iLen < iCurPos) then
			if (iLen == 0) then
				iCurSlot = 0
			else
				iCurPos = iLen
			end
		end
	end
end

local cl_drawhud = GetConVar("cl_drawhud")

hook_Add("HUDPaint", "GS_WeaponSelector", function()
	if (iCurSlot == 0 or not cl_drawhud:GetBool()) then
		return
	end

	local pPlayer = LocalPlayer()

	-- Don't draw in vehicles unless weapons are allowed to be used
	-- Or while dead!
	if (pPlayer:IsValid() and pPlayer:Alive() and (not pPlayer:InVehicle() or pPlayer:GetAllowWeaponsInVehicle())) then
		if (flNextPrecache <= RealTime()) then
			PrecacheWeps()
		end

		DrawWeaponHUD()
	else
		iCurSlot = 0
	end
end)

hook_Add("PlayerBindPress", "GS_WeaponSelector", function(pPlayer, sBind, bPressed)
	if (not pPlayer:Alive() or pPlayer:InVehicle() and not pPlayer:GetAllowWeaponsInVehicle()) then
		return
	end

	sBind = string_lower(sBind)

	-- Close the menu
	if (sBind == "cancelselect") then
		if (bPressed) then
			iCurSlot = 0
		end

		return true
	end

	-- Move to the weapon before the current
	if (sBind == "invprev") then
		if (not bPressed) then
			return true
		end

		PrecacheWeps()

		if (iWeaponCount == 0) then
			return true
		end

		local bLoop = iCurSlot == 0

		if (bLoop) then
			local pActiveWeapon = pPlayer:GetActiveWeapon()

			if (pActiveWeapon:IsValid()) then
				local iSlot = pActiveWeapon:GetSlot() + 1
				local tSlotCache = tCache[iSlot]

				if (tSlotCache[1] ~= pActiveWeapon) then
					iCurSlot = iSlot
					iCurPos = 1

					for i = 2, tCacheLength[iSlot] do
						if (tSlotCache[i] == pActiveWeapon) then
							iCurPos = i - 1

							break
						end
					end

					flSelectTime = RealTime()
					pPlayer:EmitSound(MOVE_SOUND)

					return true
				end

				iCurSlot = iSlot
			end
		end

		if (bLoop or iCurPos == 1) then
			repeat
				if (iCurSlot <= 1) then
					iCurSlot = MAX_SLOTS
				else
					iCurSlot = iCurSlot - 1
				end
			until(tCacheLength[iCurSlot] ~= 0)

			iCurPos = tCacheLength[iCurSlot]
		else
			iCurPos = iCurPos - 1
		end

		flSelectTime = RealTime()
		pPlayer:EmitSound(MOVE_SOUND)

		return true
	end

	-- Move to the weapon after the current
	if (sBind == "invnext") then
		if (not bPressed) then
			return true
		end

		PrecacheWeps()

		-- Block the action if there aren't any weapons available
		if (iWeaponCount == 0) then
			return true
		end

		-- Lua's goto can't jump between child scopes
		local bLoop = iCurSlot == 0

		-- Weapon selection isn't currently open, move based on the active weapon's position
		if (bLoop) then
			local pActiveWeapon = pPlayer:GetActiveWeapon()

			if (pActiveWeapon:IsValid()) then
				local iSlot = pActiveWeapon:GetSlot() + 1
				local iLen = tCacheLength[iSlot]
				local tSlotCache = tCache[iSlot]

				if (tSlotCache[iLen] ~= pActiveWeapon) then
					iCurSlot = iSlot
					iCurPos = 1

					for i = 1, iLen - 1 do
						if (tSlotCache[i] == pActiveWeapon) then
							iCurPos = i + 1

							break
						end
					end

					flSelectTime = RealTime()
					pPlayer:EmitSound(MOVE_SOUND)

					return true
				end

				-- At the end of a slot, move to the next one
				iCurSlot = iSlot
			end
		end

		if (bLoop or iCurPos == tCacheLength[iCurSlot]) then
			-- Loop through the slots until one has weapons
			repeat
				if (iCurSlot == MAX_SLOTS) then
					iCurSlot = 1
				else
					iCurSlot = iCurSlot + 1
				end
			until(tCacheLength[iCurSlot] ~= 0)

			-- Start at the beginning of the new slot
			iCurPos = 1
		else
			-- Bump up the position
			iCurPos = iCurPos + 1
		end

		flSelectTime = RealTime()
		pPlayer:EmitSound(MOVE_SOUND)

		return true
	end

	-- Keys 1-6
	if (sBind:sub(1, 4) == "slot") then
		local iSlot = tonumber(sBind:sub(5))

		-- If the command is slot#, use it for the weapon HUD
		-- Otherwise, let it pass through to prevent false positives
		if (iSlot == nil) then
			return
		end

		if (not bPressed) then
			return true
		end

		PrecacheWeps()

		-- Play a sound even if there aren't any weapons in that slot for "haptic" (really auditory) feedback
		if (iWeaponCount == 0) then
			pPlayer:EmitSound(MOVE_SOUND)

			return true
		end

		-- If the slot number is in the bounds
		if (iSlot <= MAX_SLOTS) then
			-- If the slot is already open
			if (iSlot == iCurSlot) then
				-- Start back at the beginning
				if (iCurPos == tCacheLength[iCurSlot]) then
					iCurPos = 1
				-- Move one up
				else
					iCurPos = iCurPos + 1
				end
			-- If there are weapons in this slot, display them
			elseif (tCacheLength[iSlot] ~= 0) then
				iCurSlot = iSlot
				iCurPos = 1
			end

			flSelectTime = RealTime()
			pPlayer:EmitSound(MOVE_SOUND)
		end

		return true
	end

	-- If the weapon selection is currently open
	if (iCurSlot ~= 0) then
		if (sBind == "+attack") then
			-- Hide the selection
			local pWeapon = tCache[iCurSlot][iCurPos]
			iCurSlot = 0

			-- If the weapon still exists and isn't the player's active weapon
			if (pWeapon:IsValid() and pWeapon ~= pPlayer:GetActiveWeapon()) then
				input_SelectWeapon(pWeapon)
			end

			flSelectTime = RealTime()
			pPlayer:EmitSound(SELECT_SOUND)

			return true
		end

		-- Another shortcut for closing the selection
		if (sBind == "+attack2") then
			flSelectTime = RealTime()
			iCurSlot = 0

			return true
		end
	end
end)