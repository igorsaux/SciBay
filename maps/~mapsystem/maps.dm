GLOBAL_DATUM_INIT(using_map, /datum/map, text2path(copytext(file2text("data/use_map"),1,-1)) || /datum/map/ishita; using_map = new using_map)
GLOBAL_LIST_EMPTY(all_maps)

var/const/MAP_HAS_BRANCH = 1	//Branch system for occupations, togglable
var/const/MAP_HAS_RANK = 2		//Rank system, also togglable

/hook/startup/proc/initialise_map_list()
	for(var/type in typesof(/datum/map) - /datum/map)
		var/datum/map/M
		if(type == GLOB.using_map.type)
			M = GLOB.using_map
			M.setup_map()
		else
			M = new type

		if(!M.path)
			log_error("Map '[M]' does not have a defined path, not adding to map list!")
		else
			GLOB.all_maps[M.name] = M
	return 1


/datum/map
	var/name = "Unnamed Map"
	var/full_name = "Unnamed Map"
	var/path

	var/list/map_levels

	var/list/derelict_levels		// List for random derelicts

	var/list/usable_email_tlds = list("freemail.nt")
	var/base_floor_type = /turf/simulated/floor/plating/airless // The turf type used when generating floors between Z-levels at startup.
	var/base_floor_area                                 // Replacement area, if a base_floor_type is generated. Leave blank to skip.

	var/list/allowed_jobs          //Job datums to use.
	                               //Works a lot better so if we get to a point where three-ish maps are used
	                               //We don't have to C&P ones that are only common between two of them
	                               //That doesn't mean we have to include them with the rest of the jobs though, especially for map specific ones.
	                               //Also including them lets us override already created jobs, letting us keep the datums to a minimum mostly.
	                               //This is probably a lot longer explanation than it needs to be.

	var/station_name  = "BAD Station"
	var/station_short = "Baddy"
	var/dock_name     = "THE PirateBay"
	var/boss_name     = "Captain Roger"
	var/boss_short    = "Cap'"
	var/company_name  = "BadMan"
	var/company_short = "BM"
	var/system_name = "Uncharted System"

	var/map_admin_faxes = list()

	/// Areas where crew members are considered to have safely left the station.
	/// Defaults to all area types on the centcom levels if left empty.
	var/list/post_round_safe_areas = list()

	var/list/station_networks = list() 		// Camera networks that will show up on the console.

	var/allowed_spawns = list("Arrivals Shuttle","Gateway", "Cryogenic Storage", "Cyborg Storage")
	var/default_spawn = "Arrivals Shuttle"
	var/flags = 0

	var/lobby_music/lobby_music                     // The track that will play in the lobby screen. Handed in the /setup_map() proc.
	var/welcome_sound = 'sound/signals/start1.ogg'	// Sound played on roundstart

	var/list/loadout_blacklist	//list of types of loadout items that will not be pickable
	var/legacy_mode = FALSE // When TRUE, some things (like walls and windows) use their classical appearance and mechanics

	//Economy stuff
	var/starting_money = 75000		//Money in station account
	var/department_money = 5000		//Money in department accounts
	var/salary_modifier	= 1			//Multiplier to starting character money
	var/station_departments = list()//Gets filled automatically depending on jobs allowed

/datum/map/New()
	if(!allowed_jobs)
		allowed_jobs = subtypesof(/datum/job)

/datum/map/proc/level_has_trait(z, trait)
	return map_levels[z].has_trait(trait)

/datum/map/proc/setup_map()
	ASSERT(length(map_levels))

	var/derelicts_index = config.mapping.derelicts_amount
	while(length(derelict_levels) && derelicts_index)
		var/list/rand_derelict = pick(derelict_levels)
		derelict_levels.Remove(rand_derelict)
		map_levels.Add(rand_derelict)
		derelicts_index--

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		log_to_dd("Loading map '[L.path]' at [level]")
		maploader.load_map(L.path, 1, 1, level, FALSE, FALSE, TRUE, FALSE)

	world.update_status()

/datum/map/proc/send_welcome()
	return

/datum/map/proc/perform_map_generation(lateloading = FALSE)
	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]
		if(L.lateloading_level != lateloading)
			continue

		L.generate(level)

/datum/map/proc/get_network_access(network)
	switch(network)
		if(NETWORK_CIVILIAN_WEST)
			return access_mailsorting
		if(NETWORK_RESEARCH_OUTPOST)
			return access_research
		if(NETWORK_TELECOM)
			return access_heads
		if(NETWORK_COMMAND)
			return access_heads
		if(NETWORK_ENGINE, NETWORK_ENGINEERING_OUTPOST)
			return access_engine

// By default transition randomly to another zlevel
/datum/map/proc/get_transit_zlevel(current_z_level)
	var/list/candidates = list()

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		if(level == current_z_level)
			continue

		if(!L.has_trait(ZTRAIT_CENTCOM) && !L.has_trait(ZTRAIT_SEALED))
			candidates["[level]"] = L.travel_chance

	if(!length(candidates))
		return current_z_level

	return text2num(util_pick_weight(candidates))

/datum/map/proc/get_empty_zlevel()
	var/empty_levels = list()

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		if(L.has_trait(ZTRAIT_EMPTY))
			empty_levels += level

	return pick(empty_levels)

/datum/map/proc/map_info(client/victim)
	return
// Access check is of the type requires one. These have been carefully selected to avoid allowing the janitor to see channels he shouldn't
// This list needs to be purged but people insist on adding more cruft to the radio.
/datum/map/proc/default_internal_channels()
	return list(
		num2text(PUB_FREQ)   = list(),
		num2text(AI_FREQ)    = list(access_synth),
		num2text(ENT_FREQ)   = list(),
		num2text(ERT_FREQ)   = list(access_cent_specops),
		num2text(COMM_FREQ)  = list(access_heads),
		num2text(ENG_FREQ)   = list(access_engine_equip, access_atmospherics),
		num2text(MED_FREQ)   = list(access_medical_equip),
		num2text(MED_I_FREQ) = list(access_medical_equip),
		num2text(SEC_FREQ)   = list(access_security),
		num2text(SEC_I_FREQ) = list(access_security),
		num2text(SCI_FREQ)   = list(access_tox,access_robotics,access_xenobiology),
		num2text(SUP_FREQ)   = list(access_cargo),
		num2text(SRV_FREQ)   = list(access_janitor, access_hydroponics),
	)

/datum/map/proc/get_levels_without_trait(trait)
	var/list/result = list()

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		if(!L.has_trait(trait))
			result += level

	return result

/datum/map/proc/get_levels_with_trait(trait)
	var/list/result = list()

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		if(L.has_trait(trait))
			result += level

	return result

/datum/map/proc/get_levels_with_any_trait(...)
	var/list/result = list()

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		for(var/T in args)
			if(L.has_trait(T))
				result += level
				break

	return result

/datum/map/proc/get_levels_with_all_traits(...)
	var/list/result = list()

	for(var/level = 1; level <= length(map_levels); level++)
		var/datum/space_level/L = map_levels[level]

		var/ok = TRUE
		for(var/T in args)
			if(!L.has_trait(T))
				ok = FALSE
				break

		if(ok)
			result += level

	return result
