/datum/game_mode/var/process_count = 0

//This can be overriden in case a game mode needs to do stuff when a player latejoins
/datum/game_mode/proc/handle_latejoin(mob/living/carbon/human/character)
	return 0
