-- this lua was done by Arc!! thank you Arc!!

local function get_room_at_location(shipManager, location, includeWalls)
    return Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, includeWalls)
end

local function vter(cvec)
    local i = -1
    local n = cvec:size()
    return function()
        i = i + 1
        if i < n then return cvec[i] end
    end
end

local systemIdName = "dd_corruptor"
local corruptor_durations = {8, 13, 16, 17}
corruptor_durations[0] = 0

local roomAnimString = "effects/ddsoulplague_corruptor_room_effect"
local roomAnimLength = 8
local roomAnim = {}
for i = 1, roomAnimLength do
    --print("i:"..tostring(i).." anim:"..roomAnimString..tostring(i)..".png")
    roomAnim[i] = Hyperspace.Resources:CreateImagePrimitiveString( (roomAnimString..tostring(i)..".png") , -16, -16, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false)
end

--Handles tooltips and mousever descriptions per level
local function get_level_description_corruptor(systemId, level, tooltip)
    if systemId == Hyperspace.ShipSystem.NameToSystemId(systemIdName) then
        return string.format("%is infection, %is per spawn", corruptor_durations[level], 8 - level)
    end
end

script.on_internal_event(Defines.InternalEvents.GET_LEVEL_DESCRIPTION, get_level_description_corruptor)

--Utility function to check if the SystemBox instance is for our customs system
local function is_corruptor(systemBox)
    local systemName = Hyperspace.ShipSystem.SystemIdToName(systemBox.pSystem.iSystemType)
    return systemName == systemIdName and systemBox.bPlayerUI and systemBox.pSystem.iHackEffect == 0
end

--Utility function to check if the SystemBox instance is for our customs system
local function is_corruptor_enemy(systemBox)
    local systemName = Hyperspace.ShipSystem.SystemIdToName(systemBox.pSystem.iSystemType)
    return systemName == systemIdName and not systemBox.bPlayerUI
end
 
--Offsets of the button
local corruptorButtonOffset_x = 37
local corruptorButtonOffset_y = -50

local systemActive = false

--Handles initialization of custom system box
local function corruptor_construct_system_box(systemBox)
    if is_corruptor(systemBox) then
        systemBox.extend.xOffset = 54

        local activateButton1 = Hyperspace.Button()
        activateButton1:OnInit("systemUI/button_"..systemIdName.."1", Hyperspace.Point(corruptorButtonOffset_x, corruptorButtonOffset_y))
        activateButton1.hitbox.x = 10
        activateButton1.hitbox.y = 47
        activateButton1.hitbox.w = 20
        activateButton1.hitbox.h = 19
        systemBox.table.activateButton1 = activateButton1
        local activateButton2 = Hyperspace.Button()
        activateButton2:OnInit("systemUI/button_"..systemIdName.."2", Hyperspace.Point(corruptorButtonOffset_x, corruptorButtonOffset_y))
        activateButton2.hitbox.x = 10
        activateButton2.hitbox.y = 35
        activateButton2.hitbox.w = 20
        activateButton2.hitbox.h = 31
        systemBox.table.activateButton2 = activateButton2
        local activateButton3 = Hyperspace.Button()
        activateButton3:OnInit("systemUI/button_"..systemIdName.."3", Hyperspace.Point(corruptorButtonOffset_x, corruptorButtonOffset_y))
        activateButton3.hitbox.x = 10
        activateButton3.hitbox.y = 23
        activateButton3.hitbox.w = 20
        activateButton3.hitbox.h = 43
        systemBox.table.activateButton3 = activateButton3
        local activateButton4 = Hyperspace.Button()
        activateButton4:OnInit("systemUI/button_"..systemIdName.."4", Hyperspace.Point(corruptorButtonOffset_x, corruptorButtonOffset_y))
        activateButton4.hitbox.x = 10
        activateButton4.hitbox.y = 11
        activateButton4.hitbox.w = 20
        activateButton4.hitbox.h = 55
        systemBox.table.activateButton4 = activateButton4

        systemBox.pSystem.bBoostable = false -- make the system unmannable
    elseif is_corruptor_enemy(systemBox) then
        systemBox.pSystem.bBoostable = false
    end
end

script.on_internal_event(Defines.InternalEvents.CONSTRUCT_SYSTEM_BOX, corruptor_construct_system_box)

--Handles mouse movement
local function corruptor_mouse_move(systemBox, x, y)
    if is_corruptor(systemBox) then
        local activateButton1 = systemBox.table.activateButton1
        local activateButton2 = systemBox.table.activateButton2
        local activateButton3 = systemBox.table.activateButton3
        local activateButton4 = systemBox.table.activateButton4
        activateButton1:MouseMove(x - corruptorButtonOffset_x, y - corruptorButtonOffset_y, false)
        activateButton2:MouseMove(x - corruptorButtonOffset_x, y - corruptorButtonOffset_y, false)
        activateButton3:MouseMove(x - corruptorButtonOffset_x, y - corruptorButtonOffset_y, false)
        activateButton4:MouseMove(x - corruptorButtonOffset_x, y - corruptorButtonOffset_y, false)
    end
    return Defines.Chain.CONTINUE
end
script.on_internal_event(Defines.InternalEvents.SYSTEM_BOX_MOUSE_MOVE, corruptor_mouse_move)

local corruptor_targetting = false
local corruptor_targetRoom = nil
local corruptor_targetShip = nil
local cursorImage = Hyperspace.Resources:CreateImagePrimitiveString("mouse/pointer_"..systemIdName..".png", 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false)
local corruptorSpawnTimerMax = 8
local corruptorSpawnTimer = 0
local corruptorDuration = 0
local corruptor_targetRoomTemp = nil
local corruptor_targetShipTemp = nil

local puffAnimations = {}
puffAnimations[0] = {anim = nil, target_x = -1, target_y = -1, target_ship = -1}
puffAnimations[1] = {anim = nil, target_x = -1, target_y = -1, target_ship = -1}

local function corruptor_explosion(owner, ship, target)
    local spaceManager = Hyperspace.App.world.space
    local targetLoc = Hyperspace.ships(ship):GetRoomCenter(target)
    puffAnimations[owner].target_x = targetLoc.x
    puffAnimations[owner].target_y = targetLoc.y
    puffAnimations[owner].target_ship = ship
    puffAnimations[owner].anim = Hyperspace.Animations:GetAnimation("bomb_ddsoulplague_puffcloud")
    puffAnimations[owner].anim.position.x = -puffAnimations[owner].anim.info.frameWidth/2
    puffAnimations[owner].anim.position.y = -puffAnimations[owner].anim.info.frameHeight/2
    puffAnimations[owner].anim.tracker.loop = false
    puffAnimations[owner].anim:Start(false)
end

local soulPlagueCrew = {}
for crew in vter(Hyperspace.Blueprints:GetBlueprintList("LIST_DDSOULPLAGUE_ALIGNED")) do
    soulPlagueCrew[crew] = true
end

local function corruptor_spawn(roomId, shipId, originId, amount, player)
    local shipManager = Hyperspace.ships(shipId)
    local originShip = Hyperspace.ships(originId)
	if originShip then
		if originShip:HasAugmentation("DD_INTERNAL_AUGMENT1") > 0 then
			for crew in vter(shipManager.vCrewList) do
				if crew.iRoomId == roomId and soulPlagueCrew[crew.type] then
					crew:ApplyDamage(8)
				end
			end
		end
		if originShip:HasAugmentation("DD_INTERNAL_AUGMENT2") > 0 then
			for crew in vter(shipManager.vCrewList) do
				if crew.iRoomId == roomId and not soulPlagueCrew[crew.type] then
					crew.fStunTime = 2
				end
			end
		end
	end
    local crewId = "ddsoulplague_corruptor_tide_enemy"
    if player then
        crewId = "ddsoulplague_corruptor_tide"
    end
    local intruder = false
    if shipId ~= originId then
        intruder = true
    end
    local crew = shipManager:AddCrewMemberFromString("Tide", crewId, intruder, roomId, true, true)
    crew.extend.deathTimer = Hyperspace.TimerHelper(false)
    crew.extend.deathTimer:Start(45)
    Hyperspace.Sounds:PlaySoundMix("ddsoulplaguecorruptorflood", -1, false)
    corruptor_explosion(originId, shipId, roomId)
end

--Handles click events 
local function corruptor_click(systemBox, shift)
    if is_corruptor(systemBox) then
        local combatControl = Hyperspace.App.gui.combatControl
        local activateButton1 = systemBox.table.activateButton1
        local activateButton2 = systemBox.table.activateButton2
        local activateButton3 = systemBox.table.activateButton3
        local activateButton4 = systemBox.table.activateButton4

        if (activateButton1.bHover and activateButton1.bActive) or
            (activateButton2.bHover and activateButton2.bActive) or
            (activateButton3.bHover and activateButton3.bActive) or
            (activateButton4.bHover and activateButton4.bActive) then
            corruptor_targetting = true --Indicate that we are now targetting the system
        elseif Hyperspace.Global.GetInstance():GetCApp().world.bStartedGame and corruptor_targetting == true then 
            corruptor_targetting = false 
            if combatControl.selectedSelfRoom < 0 and combatControl.selectedRoom < 0 then return end
            if combatControl.selectedSelfRoom >= 0 then
                corruptor_targetRoomTemp = combatControl.selectedSelfRoom
                corruptor_targetShipTemp = 0
            elseif combatControl.selectedRoom >= 0 then
                corruptor_targetRoomTemp = combatControl.selectedRoom
                corruptor_targetShipTemp = 1
            end
        end
    end
    return Defines.Chain.CONTINUE
end
script.on_internal_event(Defines.InternalEvents.SYSTEM_BOX_MOUSE_CLICK, corruptor_click)

--handle rendering while targetting the system
script.on_render_event(Defines.RenderEvents.MOUSE_CONTROL, function() end, function() 
    if corruptor_targetting == true then
        local mousePos = Hyperspace.Mouse.position 

        Graphics.CSurface.GL_PushMatrix()
        Graphics.CSurface.GL_Translate(mousePos.x,mousePos.y,0) -- render mouse icon for corruptor system
        Graphics.CSurface.GL_RenderPrimitive(cursorImage)
        Graphics.CSurface.GL_PopMatrix()
    end
end)

local placedImage = Hyperspace.Resources:CreateImagePrimitiveString("icons/"..systemIdName.."_placed.png", -20, -20, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false)

script.on_render_event(Defines.RenderEvents.SHIP_SPARKS, function(ship)
    local combatControl = Hyperspace.App.gui.combatControl
    if ship.iShipId == 0 and corruptor_targetting then
        for room in vter(ship.vRoomList) do
            if room.iRoomId == combatControl.selectedSelfRoom then
                Graphics.CSurface.GL_RenderPrimitive(room.highlightPrimitive) -- highlight the room
                Graphics.CSurface.GL_RenderPrimitive(room.highlightPrimitive2)
            end
        end
    elseif ship.iShipId == 1 and corruptor_targetting then
        for room in vter(ship.vRoomList) do
            if room.iRoomId == combatControl.selectedRoom then
                Graphics.CSurface.GL_RenderPrimitive(room.highlightPrimitive) -- highlight the room
                Graphics.CSurface.GL_RenderPrimitive(room.highlightPrimitive2)
            end
        end
    end
end, function() end)

script.on_render_event(Defines.RenderEvents.SHIP, function() end, function(ship)
    if corruptor_targetRoomTemp and ship.iShipId == corruptor_targetShipTemp then
        local location = ship:GetRoomCenter(corruptor_targetRoomTemp)
        Graphics.CSurface.GL_PushMatrix()
        Graphics.CSurface.GL_Translate(location.x, location.y, 0)
        Graphics.CSurface.GL_RenderPrimitive(placedImage)
        Graphics.CSurface.GL_PopMatrix()
    end
end)


--handle cancelling targetting by right clicking
script.on_internal_event(Defines.InternalEvents.ON_MOUSE_R_BUTTON_DOWN, function(x,y) 
    if corruptor_targetting == true then
        corruptor_targetting = false
    end
    return Defines.Chain.CONTINUE
end)

--Utility function to see if the system is ready for use
local function corruptor_ready(shipSystem)
   return not shipSystem:GetLocked() and shipSystem:Functioning()
end
--Initializes primitive for UI elements
local buttonBase = {}
local buttonCharging = {}
script.on_init(function()
    buttonBase[1] = Hyperspace.Resources:CreateImagePrimitiveString("systemUI/button_cloaking1_base.png", corruptorButtonOffset_x, corruptorButtonOffset_y, 0, Graphics.GL_Color(1, 1, 1, 1), 1, false)
    buttonBase[2] = Hyperspace.Resources:CreateImagePrimitiveString("systemUI/button_cloaking2_base.png", corruptorButtonOffset_x, corruptorButtonOffset_y, 0, Graphics.GL_Color(1, 1, 1, 1), 1, false)
    buttonBase[3] = Hyperspace.Resources:CreateImagePrimitiveString("systemUI/button_cloaking3_base.png", corruptorButtonOffset_x, corruptorButtonOffset_y, 0, Graphics.GL_Color(1, 1, 1, 1), 1, false)
    buttonBase[4] = Hyperspace.Resources:CreateImagePrimitiveString("systemUI/button_cloaking4_base.png", corruptorButtonOffset_x, corruptorButtonOffset_y, 0, Graphics.GL_Color(1, 1, 1, 1), 1, false)

    buttonCharging[1] = Hyperspace.Resources:CreateImagePrimitiveString("systemUI/button_cloaking1_charging_on.png", corruptorButtonOffset_x, corruptorButtonOffset_y, 0, Graphics.GL_Color(1, 1, 1, 1), 1, false)
    buttonCharging[2] = Hyperspace.Resources:CreateImagePrimitiveString("systemUI/button_cloaking2_charging_on.png", corruptorButtonOffset_x, corruptorButtonOffset_y, 0, Graphics.GL_Color(1, 1, 1, 1), 1, false)
    buttonCharging[3] = Hyperspace.Resources:CreateImagePrimitiveString("systemUI/button_cloaking3_charging_on.png", corruptorButtonOffset_x, corruptorButtonOffset_y, 0, Graphics.GL_Color(1, 1, 1, 1), 1, false)
    buttonCharging[4] = Hyperspace.Resources:CreateImagePrimitiveString("systemUI/button_cloaking4_charging_on.png", corruptorButtonOffset_x, corruptorButtonOffset_y, 0, Graphics.GL_Color(1, 1, 1, 1), 1, false)
end)

--Handles custom rendering
local function corruptor_render(systemBox, ignoreStatus)
    if is_corruptor(systemBox) then
        local activateButtonTable = {}
        activateButtonTable[1] = systemBox.table.activateButton1
        activateButtonTable[2] = systemBox.table.activateButton2
        activateButtonTable[3] = systemBox.table.activateButton3
        activateButtonTable[4] = systemBox.table.activateButton4
        activateButtonTable[1].bActive = false
        activateButtonTable[2].bActive = false
        activateButtonTable[3].bActive = false
        activateButtonTable[4].bActive = false
        local effectivePower = systemBox.pSystem:GetEffectivePower()
        if effectivePower == 0 then effectivePower = 1 end

        local activateButton = activateButtonTable[effectivePower]
        activateButton.bActive = corruptor_ready(systemBox.pSystem) and not corruptor_targetting and not corruptor_targetRoom
        if activateButton.bHover then
            Hyperspace.Mouse.tooltip = "Infects the target room and causes it to spawn Soulplague Tides over time.\nHotkey:N/A"
        end
        Graphics.CSurface.GL_RenderPrimitive(buttonBase[effectivePower])
        if corruptor_targetRoom then
            local height = math.ceil((corruptorDuration/corruptor_durations[effectivePower]) * (2 + 3 * effectivePower)) * 4
            Graphics.CSurface.GL_SetStencilMode(1,1,1)
            Graphics.CSurface.GL_DrawRect(corruptorButtonOffset_x + 10, 
                corruptorButtonOffset_y + (67 - (2 + 3 * effectivePower) * 4) + ((2 + 3 * effectivePower) * 4 - height), 
                20, 
                height, 
                Graphics.GL_Color(1, 1, 1, 1))
            Graphics.CSurface.GL_SetStencilMode(2,1,1)
            Graphics.CSurface.GL_RenderPrimitive(buttonCharging[effectivePower])
            Graphics.CSurface.GL_SetStencilMode(0,1,1)
        else
            activateButton:OnRender()
        end
    end
end
script.on_render_event(Defines.RenderEvents.SYSTEM_BOX, 
function(systemBox, ignoreStatus) 
    return Defines.Chain.CONTINUE
end, corruptor_render)

local corruptor_targetRoomEnemy = nil
local corruptorSpawnTimerMaxEnemy = 8
local corruptorSpawnTimerEnemy = 0
local corruptorDurationEnemy = 0


script.on_render_event(Defines.RenderEvents.SHIP, function() end, function(ship)
    for i = 0, 1 do
        if puffAnimations[i].anim and puffAnimations[i].target_ship == ship.iShipId then
            Graphics.CSurface.GL_PushMatrix()
            Graphics.CSurface.GL_Translate(puffAnimations[i].target_x, puffAnimations[i].target_y)
            puffAnimations[i].anim:OnRender(1, Graphics.GL_Color(1, 1, 1, 1), false)
            Graphics.CSurface.GL_PopMatrix()
        end
    end
end)


-- handle enemies using the system
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    if puffAnimations[shipManager.iShipId].anim then
        local puff = puffAnimations[shipManager.iShipId]
        puff.anim:Update()
        if puff.anim:Done() then
            puff.anim = nil
        end
    end

    if shipManager.iShipId == 0 then
        local corruptorSystem = nil
        for system in vter(shipManager.vSystemList) do
            local systemName = Hyperspace.ShipSystem.SystemIdToName(system.iSystemType)
            if systemName == systemIdName then
                corruptorSystem = system
                local ft = corruptorSystem.flashTracker
                --print("FLASHTRACKER: time:"..ft.time.." loop:"..tostring(ft.loop).." current_time:"..ft.current_time.." running:"..tostring(ft.running).." reverse:"..tostring(ft.reverse).." done:"..tostring(ft.done).." loopDelay:"..ft.loopDelay.." currentDelay:"..ft.currentDelay)
            end
        end
        if not corruptorSystem then return end

        if corruptor_targetRoomTemp and corruptor_ready(corruptorSystem) then
            local effectivePower = corruptorSystem:GetEffectivePower()
            corruptorSpawnTimerMax = 8 - effectivePower
            corruptorSpawnTimer = corruptorSpawnTimerMax
            corruptor_targetRoom = corruptor_targetRoomTemp
            corruptor_targetShip = corruptor_targetShipTemp
            corruptorDuration = corruptor_durations[effectivePower]
            corruptor_spawn(corruptor_targetRoom, corruptor_targetShip, corruptorSystem._shipObj.iShipId, 1, true)
            corruptor_targetRoomTemp = nil
            corruptor_targetShipTemp = nil
            --corruptor_explosion(corruptorSystem._shipObj.iShipId, corruptor_targetShip, corruptor_targetRoom)
        end

        if corruptor_targetRoom and corruptor_ready(corruptorSystem) then
            corruptorSpawnTimer = corruptorSpawnTimer - Hyperspace.FPS.SpeedFactor/16
            if corruptorSpawnTimer <= 0 then
                corruptorSpawnTimer = corruptorSpawnTimerMax
                corruptor_spawn(corruptor_targetRoom, corruptor_targetShip, corruptorSystem._shipObj.iShipId, 1, true)
            end
            corruptorDuration = corruptorDuration - Hyperspace.FPS.SpeedFactor/16
            if corruptorDuration <= 0 then
                corruptorDuration = 0
                corruptor_targetRoom = nil
                corruptor_targetShip = nil
                corruptorSystem:LockSystem(4)
            end
        elseif corruptor_targetRoom then 
            corruptor_targetRoom = nil
            corruptor_targetShip = nil
            corruptorSystem:LockSystem(corruptorSystem.iLockCount + 4)
        end
    else
        local corruptorSystem = nil
        for system in vter(shipManager.vSystemList) do
            local systemName = Hyperspace.ShipSystem.SystemIdToName(system.iSystemType)
            if systemName == systemIdName then
                corruptorSystem = system
            end
        end
        if corruptorSystem then
            if corruptor_ready(corruptorSystem) and not corruptor_targetRoomEnemy then
                local effectivePower = corruptorSystem:GetEffectivePower()
                corruptorSpawnTimerMaxEnemy = 8 - effectivePower
                corruptorSpawnTimerEnemy = corruptorSpawnTimerMax
                corruptor_targetRoomEnemy = get_room_at_location(Hyperspace.ships.player, Hyperspace.ships.player:GetRandomRoomCenter(), false)
                corruptorDurationEnemy = corruptor_durations[effectivePower]
                corruptor_spawn(corruptor_targetRoomEnemy, 0, corruptorSystem._shipObj.iShipId, 1, false)
                --corruptor_explosion(corruptorSystem._shipObj.iShipId, corruptor_targetShipEnemy, corruptor_targetRoomEnemy)
            elseif corruptor_ready(corruptorSystem) and corruptor_targetRoomEnemy then
                corruptorSpawnTimerEnemy = corruptorSpawnTimerEnemy - Hyperspace.FPS.SpeedFactor/16
                if corruptorSpawnTimerEnemy <= 0 then
                    corruptorSpawnTimerEnemy = corruptorSpawnTimerMaxEnemy
                    corruptor_spawn(corruptor_targetRoomEnemy, 0, corruptorSystem._shipObj.iShipId, 1, false)
                end
                corruptorDurationEnemy = corruptorDurationEnemy - Hyperspace.FPS.SpeedFactor/16
                if corruptorDurationEnemy <= 0 then
                    corruptorDurationEnemy = 0
                    corruptor_targetRoomEnemy = nil
                    corruptorSystem:LockSystem(4)
                end
            elseif corruptor_targetRoomEnemy then
                corruptor_targetRoomEnemy = nil
                corruptorSystem:LockSystem(corruptorSystem.iLockCount + 4)
            end
        end        
    end
end)

script.on_render_event(Defines.RenderEvents.SHIP_FLOOR, function() end, function(ship) 
    if ship.iShipId == corruptor_targetShip and corruptor_targetRoom then
        local location = ship:GetRoomCenter(corruptor_targetRoom)
        Graphics.CSurface.GL_PushMatrix()
        Graphics.CSurface.GL_Translate(location.x,location.y,0)
        local frame = 1 + math.floor(corruptorSpawnTimer/corruptorSpawnTimerMax * roomAnimLength)
        Graphics.CSurface.GL_RenderPrimitive(roomAnim[frame])
        Graphics.CSurface.GL_PopMatrix()
    end
    if ship.iShipId == 0 and corruptor_targetRoomEnemy then
        local location = ship:GetRoomCenter(corruptor_targetRoomEnemy)
        Graphics.CSurface.GL_PushMatrix()
        Graphics.CSurface.GL_Translate(location.x,location.y,0)
        local frame = 1 + math.floor(corruptorSpawnTimerEnemy/corruptorSpawnTimerMaxEnemy * roomAnimLength)
        Graphics.CSurface.GL_RenderPrimitive(roomAnim[frame])
        Graphics.CSurface.GL_PopMatrix()
    end
end)

script.on_internal_event(Defines.InternalEvents.JUMP_LEAVE, function(shipManager)
    if shipManager.iShipId == 0 and shipManager:HasSystem(Hyperspace.ShipSystem.NameToSystemId("dd_corruptor")) then
        local system = shipManager:GetSystem(Hyperspace.ShipSystem.NameToSystemId("dd_corruptor"))
        local gui = Hyperspace.App.gui
        if system:GetLocked() and (gui.upgradeButton.bActive and not gui.event_pause) then
            system:LockSystem(0)
        end
    end
end)

local systemIcons = {}
local function system_icon(name)
    local tex = Hyperspace.Resources:GetImageId("icons/s_"..name.."_overlay.png")
    return Graphics.CSurface.GL_CreateImagePrimitive(tex, 0, 0, 32, 32, 0, Graphics.GL_Color(1, 1, 1, 0.5))
end
systemIcons[Hyperspace.ShipSystem.NameToSystemId(systemIdName)] = system_icon(systemIdName)

-- Render icons
local function render_icon(sysId, ship, sysInfo)
    -- Special logic for medbay and clonebay
    local skipBackground = false
    
    -- Render logic
    if not ship:HasSystem(sysId) and sysInfo:has_key(sysId) then
        local sysRoomShape = Hyperspace.ShipGraph.GetShipInfo(ship.iShipId):GetRoomShape(sysInfo[sysId].location[0])
        local iconRenderX = sysRoomShape.x + sysRoomShape.w//2 - 16
        local iconRenderY = sysRoomShape.y + sysRoomShape.h//2 - 16
        if not skipBackground then
            local outlineSize = 2
            Graphics.CSurface.GL_DrawRect(
                sysRoomShape.x,
                sysRoomShape.y,
                sysRoomShape.w,
                sysRoomShape.h,
                Graphics.GL_Color(0, 0, 0, 0.3))
            Graphics.CSurface.GL_DrawRectOutline(
                sysRoomShape.x + outlineSize,
                sysRoomShape.y + outlineSize,
                sysRoomShape.w - 2*outlineSize,
                sysRoomShape.h - 2*outlineSize,
                Graphics.GL_Color(0.8, 0, 0, 0.5), outlineSize)
        end
        Graphics.CSurface.GL_PushMatrix()
        Graphics.CSurface.GL_Translate(iconRenderX, iconRenderY)
        Graphics.CSurface.GL_RenderPrimitive(systemIcons[sysId])
        Graphics.CSurface.GL_PopMatrix()
    end
end
script.on_render_event(Defines.RenderEvents.SHIP_SPARKS, function() end, function(ship)
    if not Hyperspace.App.world.bStartedGame then
        local shipManager = Hyperspace.ships(ship.iShipId)
        local sysInfo = shipManager.myBlueprint.systemInfo
        render_icon(Hyperspace.ShipSystem.NameToSystemId(systemIdName), shipManager, sysInfo)
    end
    return Defines.Chain.CONTINUE
end)

local huskList = {}
huskList["ddsoulplague_husk_human"] = true
huskList["ddsoulplague_husk_crystal"] = true
huskList["ddsoulplague_husk_engi"] = true
huskList["ddsoulplague_husk_zoltan"] = true
huskList["ddsoulplague_husk_orchid"] = true
huskList["ddsoulplague_husk_mantis"] = true
huskList["ddsoulplague_husk_rockman"] = true
huskList["ddsoulplague_husk_slug"] = true
huskList["ddsoulplague_husk_shell"] = true
huskList["ddsoulplague_husk_lanius"] = true
huskList["ddsoulplague_husk_deepone"] = true
huskList["ddsoulplague_husk_ghost"] = true
huskList["ddsoulplague_husk_leech"] = true
huskList["ddsoulplague_husk_obelisk"] = true

script.on_internal_event(Defines.InternalEvents.HAS_EQUIPMENT, function(shipManager, equipment, value)
    if huskList[equipment] and shipManager.iShipId == 0 then
        local count = 0
        for crewmem in vter(Hyperspace.ships.player.vCrewList) do
            if crewmem.type == equipment and crewmem.iShipId == 0 then
                count = count + 1
            end
        end
        return Defines.Chain.CONTINUE, count
    end
    return Defines.Chain.CONTINUE, value
end)