var/global/antag_add_finished // Used in antag type voting.
var/global/list/additional_antag_types = list()

/datum/game_mode
	var/name = "invalid"
	var/round_description = "How did you even vote this in?"
	var/extended_round_description = "This roundtype should not be spawned, let alone votable. Someone contact a developer and tell them the game's broken again."
	var/config_tag = null
	var/votable = 1
	var/probability = 0

	var/required_players = 0                 // Minimum players for round to start if voted in.
	var/newscaster_announcements = null
	var/end_on_antag_death = 0               // Round will end when all antagonists are dead.
	var/ert_disabled = 0                     // ERT cannot be called.
	var/deny_respawn = 0	                 // Disable respawn during this round.

	var/list/disabled_jobs = list()           // Mostly used for Malf.  This check is performed in job_controller so it doesn't spawn a regular AI.

	var/require_all_templates = 0            // Will only start if all templates are checked and can spawn.

	var/waittime_l = 60 SECONDS				 // Lower bound on time before start of shift report
	var/waittime_h = 180 SECONDS		     // Upper bounds on time before start of shift report

	//Format: list(start_animation = duration, hit_animation, miss_animation). null means animation is skipped.
	var/cinematic_icon_states = list(
		"intro_nuke" = 35,
		"summary_selfdes",
		null
	)

/datum/game_mode/New()
	..()
	// Enforce some formatting.
	// This will probably break something.
	name = capitalize(lowertext(name))
	config_tag = lowertext(config_tag)

/datum/game_mode/Topic(href, href_list[])
	if(!check_rights(R_ADMIN))
		href_exploit(usr.ckey, href)
		return
	if(href_list["toggle"])
		switch(href_list["toggle"])
			if("respawn")
				deny_respawn = !deny_respawn
		message_admins("Admin [key_name_admin(usr)] toggled game mode option '[href_list["toggle"]]'.")

	// I am very sure there's a better way to do this, but I'm not sure what it might be. ~Z
	spawn(1)
		for(var/datum/admins/admin in world)
			if(usr.client == admin.owner)
				admin.show_game_mode(usr)
				return

// isStartRequirementsSatisfied()
// Checks to see if the game can be setup and ran with the current number of players or whatnot.
// Returns 0 if the mode can start and a message explaining the reason why it can't otherwise.
/datum/game_mode/proc/isStartRequirementsSatisfied(totalPlayers)
	if(totalPlayers < required_players)
		log_debug("Not enough players, [src.required_players] players needed.")
		return FALSE

	return TRUE

/datum/game_mode/proc/pre_setup()
	return

///post_setup()
/datum/game_mode/proc/post_setup()
	spawn (ROUNDSTART_LOGOUT_REPORT_TIME)
		display_roundstart_logout_report()

	spawn (rand(waittime_l, waittime_h))
		GLOB.using_map.send_welcome()

	return 1

/datum/game_mode/proc/fail_setup()
	return

/datum/game_mode/proc/check_finished()
	return 0

/datum/game_mode/proc/cleanup()	//This is called when the round has ended but not the game, if any cleanup would be necessary in that case.
	return

/datum/game_mode/proc/special_report()
	return

/datum/game_mode/proc/check_win() //universal trigger to be called at mob death, nuke explosion, etc. To be called from everywhere.
	return 0

/datum/game_mode/proc/num_players()
	. = 0
	for(var/mob/new_player/P in GLOB.player_list)
		if(P.client && P.ready)
			. ++

/datum/game_mode/proc/check_antagonists_topic(href, href_list[])
	return 0

/datum/game_mode/proc/print_roundend()
	return

// Manipulates the end-game cinematic in conjunction with GLOB.cinematic
/datum/game_mode/proc/nuke_act(atom/movable/screen/cinematic_screen, station_missed = 0)
	if(!cinematic_icon_states)
		return
	if(station_missed < 2)
		var/intro = cinematic_icon_states[1]
		if(intro)
			flick(intro,cinematic_screen)
			sleep(cinematic_icon_states[intro])
		var/end = cinematic_icon_states[3]
		var/to_flick = "station_intact_fade_red"
		if(!station_missed)
			end = cinematic_icon_states[2]
			to_flick = "station_explode_fade_red"
			for(var/mob/living/M in GLOB.living_mob_list_)
				if(is_station_turf(get_turf(M)))
					M.death()//No mercy
		if(end)
			flick(to_flick,cinematic_screen)
			cinematic_screen.icon_state = end

	else
		sleep(50)
	sound_to(world, sound('sound/effects/explosions/explosion23.ogg'))

//////////////////////////
//Reports player logouts//
//////////////////////////
/proc/display_roundstart_logout_report()
	var/msg = "<span class='notice'><b>Roundstart logout report</b>\n\n"
	for(var/mob/living/L in SSmobs.mob_list)

		if(L.ckey)
			var/found = 0
			for(var/client/C in GLOB.clients)
				if(C.ckey == L.ckey)
					found = 1
					break
			if(!found)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"

		if(L.ckey && L.client)
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))	//Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				continue //AFK client
			if(L.stat)
				if(L.stat == UNCONSCIOUS)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dying)\n"
					continue //Unconscious
				if(L.is_ooc_dead())
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dead)\n"
					continue //Dead

			continue //Happy connected client
		for(var/mob/observer/ghost/D in SSmobs.mob_list)
			var/mob/living/original_mob = D.mind?.original_mob?.resolve()
			if(D.mind && ((istype(original_mob) && original_mob == L) || D.mind.current == L))
				if(L.is_ooc_dead())
					msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
					continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Adminghosted</b></font>)\n"
						continue //Lolwhat
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Ghosted</b></font>)\n"
						continue //Ghosted while alive

	msg += "</span>" // close the span from right at the top

	for(var/mob/M in SSmobs.mob_list)
		if(M.client && M.client.holder)
			to_chat(M, msg)

/mob/verb/check_round_info()
	set name = "Check Round Info"
	set category = "OOC"

	GLOB.using_map.map_info(src)

	if(!SSticker.mode)
		to_chat(usr, "Something is terribly wrong; there is no gametype.")
		return

	if(SSticker.master_mode != "secret")
		to_chat(usr, "<b>The roundtype is [capitalize(SSticker.mode.name)]</b>")
		if(SSticker.mode.round_description)
			to_chat(usr, "<i>[SSticker.mode.round_description]</i>")
		if(SSticker.mode.extended_round_description)
			to_chat(usr, "[SSticker.mode.extended_round_description]")
	else
		to_chat(usr, "<i>Shhhh</i>. It's a secret.")
	return
