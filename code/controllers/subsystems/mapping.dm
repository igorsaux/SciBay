SUBSYSTEM_DEF(mapping)
	name = "Mapping"
	init_order = SS_INIT_MAPPING
	flags = SS_NO_FIRE

/datum/controller/subsystem/mapping/Initialize(timeofday)
	lateload_map_zlevels()
	return ..()

/datum/controller/subsystem/mapping/proc/lateload_map_zlevels()
	GLOB.using_map.perform_map_generation(TRUE)
