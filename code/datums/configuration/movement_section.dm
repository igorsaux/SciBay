/datum/configuration_section/movement
	name = "movement"

	var/run_speed
	var/walk_speed
	var/human_delay
	var/diagonal_movement_disabled

/datum/configuration_section/movement/load_data(list/data)
	CONFIG_LOAD_NUM(run_speed, data["run_speed"])
	CONFIG_LOAD_NUM(walk_speed, data["walk_speed"])
	CONFIG_LOAD_NUM(human_delay, data["human_delay"])
	CONFIG_LOAD_NUM(diagonal_movement_disabled, data["diagonal_movement_disabled"])
