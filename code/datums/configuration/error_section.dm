/datum/configuration_section/error
	name = "error"

	var/cooldown
	var/limit
	var/silence_time
	var/msg_delay

/datum/configuration_section/error/load_data(list/data)
	CONFIG_LOAD_NUM(cooldown, data["cooldown"])
	CONFIG_LOAD_NUM(limit, data["limit"])
	CONFIG_LOAD_NUM(silence_time, data["silence_time"])
	CONFIG_LOAD_NUM(msg_delay, data["msg_delay"])
