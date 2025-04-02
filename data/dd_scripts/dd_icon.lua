if not mods.icons then
    mods.icons = {}
end

mods.icons["DD"] = {
    image = Hyperspace.Resources:CreateImagePrimitiveString("addons/dd_on.png", 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false),
    imageHover = Hyperspace.Resources:CreateImagePrimitiveString("addons/dd_select2.png", 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false),
    event = "ADDON_DD",
    hover = false,
    hoverText = "DARKEST DESIRE\nThus was it done.\nClick to see more info."
}

if not mods.iconsUninstalled then
    mods.iconsUninstalled = {}
end

--------------------
----DO NOT TOUCH----
---- THE BELOW  ----
--------------------

if not mods.iconsHooked then
    mods.iconsHooked = true
    --Render code goes here
    script.on_render_event(Defines.RenderEvents.MOUSE_CONTROL, function()
        if Hyperspace.Global.GetInstance():GetCApp().world.bStartedGame then
            local renderedAddons = {}
            local iconCounter = 1
            for addon, iconTable in pairs(mods.icons) do
                --print(addon)
                renderedAddons[addon] = true
                local xOffset = 115 + (iconCounter * 24)
                local yOffset = 7
                local mousePos = Hyperspace.Mouse.position
                --print(tostring(math.abs(mousePos.x - xOffset)).." POS "..tostring(math.abs(mousePos.y - yOffset)))
                if math.abs(mousePos.x - xOffset-12) < 12 and math.abs(mousePos.y - yOffset-7) < 7 then 
                    iconTable.hover = true 
                    Hyperspace.Mouse.tooltip = iconTable.hoverText
                else 
                    iconTable.hover = false 
                end
                Graphics.CSurface.GL_PushMatrix()
                Graphics.CSurface.GL_Translate(xOffset,yOffset,0)
                if iconTable.hover then
                    Graphics.CSurface.GL_RenderPrimitive(iconTable.imageHover)
                else
                    Graphics.CSurface.GL_RenderPrimitive(iconTable.image)
                end
                Graphics.CSurface.GL_PopMatrix()
                iconCounter = iconCounter + 1
            end


            for addon, iconTable in pairs(mods.iconsUninstalled) do
                if not renderedAddons[addon] then
                    local xOffset = 115 + (iconCounter * 24)
                    local yOffset = 7
                    local mousePos = Hyperspace.Mouse.position
                    --print(tostring(math.abs(mousePos.x - xOffset)).." POS "..tostring(math.abs(mousePos.y - yOffset)))
                    if math.abs(mousePos.x - xOffset-12) < 12 and math.abs(mousePos.y - yOffset-7) < 7 then 
                        iconTable.hover = true 
                        Hyperspace.Mouse.tooltip = iconTable.hoverText
                    else 
                        iconTable.hover = false 
                    end
                    Graphics.CSurface.GL_PushMatrix()
                    Graphics.CSurface.GL_Translate(xOffset,yOffset,0)
                    if iconTable.hover then
                        Graphics.CSurface.GL_RenderPrimitive(iconTable.imageHover)
                    else
                        Graphics.CSurface.GL_RenderPrimitive(iconTable.image)
                    end
                    Graphics.CSurface.GL_PopMatrix()
                    iconCounter = iconCounter + 1
                end
            end
        end
    end, function() end)

    script.on_internal_event(Defines.InternalEvents.ON_MOUSE_L_BUTTON_DOWN, function(x, y)
        local cmdGui = Hyperspace.Global.GetInstance():GetCApp().gui
        if Hyperspace.Global.GetInstance():GetCApp().world.bStartedGame and not (Hyperspace.ships.player.bJumping or cmdGui.event_pause or cmdGui.menu_pause or cmdGui.bPaused or cmdGui.bAutoPaused or cmdGui.touch_pause) then
            local mousePos = Hyperspace.Mouse.position
            for addon, iconTable in pairs(mods.icons) do
                if iconTable.hover then
                    local worldManager = Hyperspace.Global.GetInstance():GetCApp().world
                    Hyperspace.CustomEventsParser.GetInstance():LoadEvent(worldManager, iconTable.event,false,-1)
                end
            end
            for addon, iconTable in pairs(mods.iconsUninstalled) do
                if iconTable.hover then
                    local worldManager = Hyperspace.Global.GetInstance():GetCApp().world
                    Hyperspace.CustomEventsParser.GetInstance():LoadEvent(worldManager, iconTable.event,false,-1)
                end
            end
        end
    end)
end