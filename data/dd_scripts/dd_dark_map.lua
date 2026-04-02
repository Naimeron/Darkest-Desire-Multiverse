--The code was originally taken from the Arsenal+ mod.

local dd_varr = {
black_mask = Hyperspace.Resources:CreateImagePrimitiveString('systemUI/black_mask.png', 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false),

red_wait = Hyperspace.Resources:CreateImagePrimitiveString('systemUI/dd_red_wait.png', 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false),
red_cancel = Hyperspace.Resources:CreateImagePrimitiveString('systemUI/dd_red_cancel.png', 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false),
red_next_sector = Hyperspace.Resources:CreateImagePrimitiveString('systemUI/dd_red_next_sector.png', 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false),

color_opac_red = Graphics.GL_Color(1.0, 0.2, 0.2, 0.22),
}

local StarMapZone = {
	{sector_name='SECRET_ENLIGHTENED'},
	{sector_name='DARKONE_DOMAIN'},
	{sector_name='SECRET_DDSOULPLAGUE'},
	{sector_name='SECRET_DDANTUMBRA'},

	--[[{sector_name='SECRET_ENLIGHTENED', map_zone='map/zone_enlightenedvoid.png'},
	{sector_name='DARKONE_DOMAIN', map_zone='map/zone_enlighteneddarkgod.png'},
	{sector_name='SECRET_DDSOULPLAGUE', map_zone='map/zone_soulplagueheart.png'},
	{sector_name='SECRET_DDANTUMBRA', map_zone='map/zone_ddantumbralplane.png'},]]
	--{sector_name='', map_zone='map/.png'},
}

local playerShip = nil--Hyperspace.ships.player
local map = nil--Hyperspace.App.world.starMap
local cur_sector = nil--Hyperspace.App.world.starMap.currentSector

script.on_render_event(Defines.RenderEvents.GUI_CONTAINER, function() end, function()
	map = Hyperspace.App.world.starMap
	playerShip = Hyperspace.ships.player
	cur_sector = Hyperspace.App.world.starMap.currentSector
	
	for i = 1, #StarMapZone do
		if map and map.bOpen == true and map.bChoosingNewSector == false then
			if cur_sector and cur_sector.description.type == StarMapZone[i].sector_name then
				Graphics.CSurface.GL_PushMatrix()
				Graphics.CSurface.GL_Translate(map.currentLoc.loc.x + 368 - 1000, map.currentLoc.loc.y + 107 - 1000)
				Graphics.CSurface.GL_RenderPrimitive(dd_varr.black_mask)
				Graphics.CSurface.GL_PopMatrix()
				if Hyperspace.Mouse.tooltip ~= '' then
					Hyperspace.Mouse.tooltip = '' -- It simply blocks the appearance of tooltips on the map. All of them.
				end
				Graphics.CSurface.GL_DrawRectOutline(339, 82, 754, 536, dd_varr.color_opac_red, 2)
				if playerShip.fuel_count == 0 then
					Graphics.CSurface.GL_PushMatrix()
					Graphics.CSurface.GL_Translate(812, 565)
					Graphics.CSurface.GL_RenderPrimitive(dd_varr.red_wait)
					Graphics.CSurface.GL_PopMatrix()
				end
				if map.currentLoc.event.eventName:find('DARKONE_FINISH') ~= nil or map.currentLoc.event.eventName:find('DDCOREMASS_EXIT') ~= nil or map.currentLoc.event.eventName:find('DDANTUMBRA_EXIT') ~= nil then 
					Graphics.CSurface.GL_PushMatrix()
					Graphics.CSurface.GL_Translate(850, 91)
					Graphics.CSurface.GL_RenderPrimitive(dd_varr.red_next_sector)
					Graphics.CSurface.GL_PopMatrix()
				end
				Graphics.CSurface.GL_PushMatrix()
				Graphics.CSurface.GL_Translate(933, 620)
				Graphics.CSurface.GL_RenderPrimitive(dd_varr.red_cancel)
				Graphics.CSurface.GL_PopMatrix()
			end
		end
		
	end
end)


--This code is taken from Multiverse
local StarBackgroundEnlightened
local StarBackgroundDarkone
local StarBackgroundSoulplague
local StarBackgroundAntumbra
--for i = 1, #StarMapZone 
do
    local Enli = Hyperspace.Resources:GetImageId('map/zone_enlightenedvoid.png')
    StarBackgroundEnlightened = Graphics.CSurface.GL_CreateImagePrimitive(Enli, 0, 0, Enli.width, Enli.height, 0, Graphics.GL_Color(1, 1, 1, 1))
	
    local Darkone = Hyperspace.Resources:GetImageId('map/zone_enlighteneddarkgod.png')
    StarBackgroundDarkone = Graphics.CSurface.GL_CreateImagePrimitive(Darkone, 0, 0, Darkone.width, Darkone.height, 0, Graphics.GL_Color(1, 1, 1, 1))
	
	local Soulp = Hyperspace.Resources:GetImageId('map/zone_soulplagueheart.png')
    StarBackgroundSoulplague = Graphics.CSurface.GL_CreateImagePrimitive(Soulp, 0, 0, Soulp.width, Soulp.height, 0, Graphics.GL_Color(1, 1, 1, 1))
	
	local Antu = Hyperspace.Resources:GetImageId('map/zone_ddantumbralplane.png')
    StarBackgroundAntumbra = Graphics.CSurface.GL_CreateImagePrimitive(Antu, 0, 0, Antu.width, Antu.height, 0, Graphics.GL_Color(1, 1, 1, 1))
end

local function dark()
	cur_sector = Hyperspace.App.world.starMap.currentSector
	local starMap = Hyperspace.App.world.starMap
	--if cur_sector and cur_sector.description.type == StarMapZone[i].sector_name then
	if cur_sector and cur_sector.description.type == 'SECRET_ENLIGHTENED' then
		starMap.mapsBottom[starMap.worldLevel % 3] = StarBackgroundEnlightened
	end
	if cur_sector and cur_sector.description.type == 'DARKONE_DOMAIN' then
		starMap.mapsBottom[starMap.worldLevel % 3] = StarBackgroundDarkone
	end
	if cur_sector and cur_sector.description.type == 'SECRET_DDSOULPLAGUE' then
		starMap.mapsBottom[starMap.worldLevel % 3] = StarBackgroundSoulplague
	end
	if cur_sector and cur_sector.description.type == 'SECRET_DDANTUMBRA' then
		starMap.mapsBottom[starMap.worldLevel % 3] = StarBackgroundAntumbra
	end
end


script.on_game_event("START_ENLIGHTENED", false, dark)
script.on_game_event("START_DDCOREMASS", false, dark)
script.on_game_event("DARKONE_START", false, dark)
script.on_game_event("START_DDANTUMBRA", false, dark)
--script.on_game_event("", false, dark)
