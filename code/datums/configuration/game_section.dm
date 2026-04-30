/datum/configuration_section/game
	name = "game"

	var/default_view
	var/default_view_wide

	var/continuous_rounds
	var/enter_allowed
	var/jobs_have_minimal_access

	var/disable_ooc_at_roundstart
	var/disable_looc_at_roundstart
	var/use_recursive_explosions
	var/guest_jobban
	var/guests_allowed
	var/pregame_timeleft
	var/restart_timeout

/datum/configuration_section/game/load_data(list/data)
	CONFIG_LOAD_STR(default_view, data["default_view"])
	CONFIG_LOAD_STR(default_view_wide, data["default_view_wide"])

	CONFIG_LOAD_BOOL(continuous_rounds, data["continuous_rounds"])
	CONFIG_LOAD_BOOL(enter_allowed, data["enter_allowed"])
	CONFIG_LOAD_BOOL(jobs_have_minimal_access, data["jobs_have_minimal_access"])

	CONFIG_LOAD_BOOL(disable_ooc_at_roundstart, data["disable_ooc_at_roundstart"])
	CONFIG_LOAD_BOOL(disable_looc_at_roundstart, data["disable_looc_at_roundstart"])
	CONFIG_LOAD_BOOL(use_recursive_explosions, data["use_recursive_explosions"])
	CONFIG_LOAD_BOOL(guest_jobban, data["guest_jobban"])
	CONFIG_LOAD_BOOL(guests_allowed, data["guests_allowed"])
	CONFIG_LOAD_NUM(pregame_timeleft, data["pregame_timeleft"])
	CONFIG_LOAD_NUM(restart_timeout, data["restart_timeout"])
