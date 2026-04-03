/datum/map/proc/preferences_key()
	// Must be a filename-safe string. In future if map paths get funky, do some sanitization here.
	return "default"

// Procs for loading legacy savefile preferences
/datum/map/proc/character_save_path(slot)
	//return "/[path]/character[slot]"
	return "/exodus/character[slot]"

/datum/map/proc/character_load_path(savefile/S, slot)
	var/original_cd = S.cd
	S.cd = "/"
	// . = private_use_legacy_saves(S, slot) ? "/character[slot]" : "/exodus/character[slot]"
	S.cd = original_cd // Attempting to make this call as side-effect free as possible
