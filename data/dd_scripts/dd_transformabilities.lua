-- this lua was done by Silly!! thank you Silly!!!

local randomTransforms = {
    DDSPENTSOUL_TRANSFORM = "LIST_CREW_DDUNSTABLESOULS_EMPOWERED",
    DDHUMANHUSK_TRANSFORM = "LIST_DDSOULPLAGUE_HUSKS_NOHUMAN",
	DDHUMANHUSK_ENEMY_TRANSFORM = "LIST_DDSOULPLAGUE_HUSKS_NOHUMAN_ENEMY"
}

script.on_internal_event(Defines.InternalEvents.ACTIVATE_POWER, function(power)
    local list = randomTransforms[power.def.name]
    if list ~= nil then
        power.def.transformRace = Hyperspace.Blueprints:GetCrewBlueprint(list).name
    end
    return Defines.Chain.CONTINUE
end)