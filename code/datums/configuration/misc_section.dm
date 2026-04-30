/datum/configuration_section/misc
	name = "misc"

	var/ooc_allowed
	var/looc_allowed
	var/dead_ooc_allowed
	var/aooc_allowed
	var/dsay_allowed
	var/emojis_allowed
	var/abandon_allowed
	var/respawn_delay
	var/starlight
	var/kick_inactive
	var/load_jobs_from_txt
	var/no_click_cooldown

/datum/configuration_section/misc/load_data(list/data)
	CONFIG_LOAD_BOOL(ooc_allowed, data["ooc_allowed"])
	CONFIG_LOAD_BOOL(looc_allowed, data["looc_allowed"])
	CONFIG_LOAD_BOOL(dead_ooc_allowed, data["dead_ooc_allowed"])
	CONFIG_LOAD_BOOL(aooc_allowed, data["aooc_allowed"])
	CONFIG_LOAD_BOOL(dsay_allowed, data["dsay_allowed"])
	CONFIG_LOAD_BOOL(emojis_allowed, data["emojis_allowed"])
	CONFIG_LOAD_BOOL(abandon_allowed, data["abandon_allowed"])
	CONFIG_LOAD_NUM(respawn_delay, data["respawn_delay"])
	CONFIG_LOAD_NUM(starlight, data["starlight"])
	CONFIG_LOAD_NUM(kick_inactive, data["kick_inactive"])
	CONFIG_LOAD_BOOL(load_jobs_from_txt, data["load_jobs_from_txt"])
	CONFIG_LOAD_BOOL(no_click_cooldown, data["no_click_cooldown"])
