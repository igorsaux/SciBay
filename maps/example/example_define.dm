
/datum/map/example
	name = "Example"
	full_name = "The Example"
	path = "example"
	station_short = "Ex"
	dock_name     = "NAS Crescent"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "Nanotrasen"
	company_short = "NT"
	system_name   = "Nyx"

	map_levels = list(
		new /datum/space_level/example_1,
		new /datum/space_level/example_2,
		new /datum/space_level/example_3,
		new /datum/space_level/example_4
	)

	post_round_safe_areas = list (
		/area/centcom,
		/area/shuttle/escape/centcom,
	)

	allowed_spawns = list("Arrivals Shuttle")
