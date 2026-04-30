/datum/configuration_section/ghost
	name = "ghost"

	var/ghost_interaction
	var/ghosts_can_possess_animals

/datum/configuration_section/ghost/load_data(list/data)
	CONFIG_LOAD_BOOL(ghost_interaction, data["ghost_interaction"])
	CONFIG_LOAD_BOOL(ghosts_can_possess_animals, data["ghosts_can_possess_animals"])
