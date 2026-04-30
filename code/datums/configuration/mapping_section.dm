/datum/configuration_section/mapping
	name = "mapping"

	var/list/allowed_maps

/datum/configuration_section/mapping/load_data(list/data)
	CONFIG_LOAD_LIST(allowed_maps, data["allowed_maps"])
