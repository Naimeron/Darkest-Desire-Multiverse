-- this Lua was done by Chrono!! ty Chrono!!

local register_environment = mods.multiverse.register_environment

-- Register the hazard
register_environment("soulplague", "loc_environment_soulplague", "warnings/danger_ddsoulplague.png")
register_environment("soulplague_allies", "loc_environment_soulplague_allies", "warnings/danger_ddsoulplague_allies.png")

-- Check if a location is a soulplague
local function check_soulplague_state(event)
    local customEvent = Hyperspace.CustomEventsParser.GetInstance():GetCustomEvent(event.eventName)
    if not customEvent then return 0 end
    for triggeredEventId in vter(customEvent.triggeredEvents) do
        if Hyperspace.TriggeredEventDefinition.defs[triggeredEventId].event == "DDCOREMASS_EVILWAAAMASS_ASSAULT" then
            return 1
		elseif Hyperspace.TriggeredEventDefinition.defs[triggeredEventId].event == "DDCOREMASS_EXIT_NOTALLHOPEISLOST" then
            return 1
        elseif Hyperspace.TriggeredEventDefinition.defs[triggeredEventId].event == "COMBAT_CHECK_DDSOULPLAGUE_MASS_SUMMON_ASSAULT" then
            return 2
        end
    end
    return 0
end

-- Activate the hazard when an event with its triggered event happens,
-- and deactivate it when we go to a beacon that doesn't have it
script.on_internal_event(Defines.InternalEvents.PRE_CREATE_CHOICEBOX, function(event)
    local soulplagueState = check_soulplague_state(event)
    if soulplagueState > 0 then
        if soulplagueState == 1 then
            Hyperspace.playerVariables.loc_environment_soulplague = 1
        elseif soulplagueState == 2 then
            Hyperspace.playerVariables.loc_environment_soulplague_allies = 1
        end
    elseif Hyperspace.App.world.starMap.currentLoc.event.eventName == event.eventName then
        Hyperspace.playerVariables.loc_environment_soulplague = 0
        Hyperspace.playerVariables.loc_environment_soulplague_allies = 0
    end
end)

-- Reset variables on jump
script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function()
    Hyperspace.playerVariables.loc_environment_soulplague = 0
    Hyperspace.playerVariables.loc_environment_soulplague_allies = 0
end)