
var/global/BSACooldown = 0
var/global/floorIsLava = 0


////////////////////////////////
/proc/message_admins(msg)
	msg = "<span class=\"log_message\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	log_adminwarn(msg)
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, msg, MESSAGE_TYPE_ADMINLOG)
/proc/message_staff(msg)
	msg = "<span class=\"log_message\"><span class=\"prefix\">STAFF LOG:</span> <span class=\"message\">[msg]</span></span>"
	log_adminwarn(msg)
	for(var/client/C in GLOB.admins)
		if(R_INVESTIGATE & C.holder.rights)
			to_chat(C, msg, MESSAGE_TYPE_ADMINLOG)
/proc/msg_admin_attack(text) //Toggleable Attack Messages
	log_attack(text)
	var/rendered = "<span class=\"log_message\"><span class=\"prefix\">ATTACK:</span> <span class=\"message\">[text]</span></span>"
	for(var/client/C in GLOB.admins)
		if(check_rights(R_INVESTIGATE, 0, C))
			var/msg = rendered
			to_chat(C, msg, MESSAGE_TYPE_ATTACKLOG)

/proc/href_exploit(suspect_ckey, href)
	var/rendered = "<span class=\"log_message\"><span class=\"prefix\">HREF EXPLOIT POSSIBLE:</span> <span class=\"message\">Suspect: '[suspect_ckey]' || Href: '[href]'</span></span><br>"
	log_href(rendered)
	for(var/client/C in GLOB.admins)
		if(check_rights(R_INVESTIGATE, 0, C))
			var/msg = rendered
			to_chat(C, msg, MESSAGE_TYPE_ADMINLOG)

/proc/admin_notice(message, rights)
	for(var/mob/M in SSmobs.mob_list)
		if(check_rights(rights, 0, M))
			to_chat(M, message, MESSAGE_TYPE_ADMINLOG)

///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(mob/M in SSmobs.mob_list)
	set category = "Admin"
	set name = "Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.")
		return
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/body = "<html><meta charset=\"utf-8\"><head><title>Options for [M.key]</title></head>"
	body += "<body>Options panel for <b>[M]</b>"
	if(M.client)
		body += " played by <b>[M.client]</b> "
		body += "\[<A href='?src=\ref[src];editrights=show'>[M.client.holder ? M.client.holder.rank : "Player"]</A>\]"

	if(istype(M, /mob/new_player))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<A href='?src=\ref[src];revive=\ref[M]'>Heal</A>\] "

	body += {"
		<br><br>\[
		<a href='?_src_=vars;Vars=\ref[M]'>VV</a> -
		<a href='?src=\ref[src];traitor=\ref[M]'>TP</a> -
		<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a> -
		<a href='?src=\ref[src];subtlemessage=\ref[M]'>SM</a> -
		[admin_jump_link(M, src)]\] <br>
		<b>Mob type:</b> [M.type]<br>
		<b>Inactivity time:</b> [M.client ? "[M.client.inactivity/600] minutes" : "Logged out"]<br/><br/>
		<A href='?src=\ref[src];boot2=\ref[M]'>Kick</A> |
		<A href='?_src_=holder;warn=[M.ckey]'>Warn</A> |
		<A href='?src=\ref[src];newban=\ref[M]'>Ban</A> |
		<A href='?src=\ref[src];jobban2=\ref[M]'>Jobban</A> |
		<A href='?src=\ref[src];hellban=\ref[M]'>Hellban</A> |
		<A href='?src=\ref[src];notes=show;mob=\ref[M]'>Notes</A>
	"}

	if(M.client)
		body += "| <A HREF='?src=\ref[src];sendtoprison=\ref[M]'>Prison</A> | "
		var/muted = M.client.prefs.muted
		body += {"<br><b>Mute: </b>
			\[<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_IC]'><font color='[(muted & MUTE_IC)?"red":"blue"]'>IC</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_OOC]'><font color='[(muted & MUTE_OOC)?"red":"blue"]'>OOC</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_AOOC]'><font color='[(muted & MUTE_AOOC)?"red":"blue"]'>AOOC</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_PRAY]'><font color='[(muted & MUTE_PRAY)?"red":"blue"]'>PRAY</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ADMINHELP]'><font color='[(muted & MUTE_ADMINHELP)?"red":"blue"]'>ADMINHELP</font></a> |
			<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_DEADCHAT]'><font color='[(muted & MUTE_DEADCHAT)?"red":"blue"]'>DEADCHAT</font></a>\]
			(<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ALL]'><font color='[(muted & MUTE_ALL)?"red":"blue"]'>toggle all</font></a>)
		"}

	body += {"<br><br>
		<A href='?src=\ref[src];jumpto=\ref[M]'><b>Jump to</b></A> |
		<A href='?src=\ref[src];getmob=\ref[M]'>Get</A> |
		<A href='?src=\ref[src];sendmob=\ref[M]'>Send To</A>
		<br><br>
		[check_rights(R_ADMIN|R_MOD,0) ? "<A href='?src=\ref[src];traitor=\ref[M]'>Traitor panel</A> | " : "" ]
		<A href='?src=\ref[src];narrateto=\ref[M]'>Narrate to</A> |
		<A href='?src=\ref[src];subtlemessage=\ref[M]'>Subtle message</A> |
		<A href='?_src_=holder;individuallog=\ref[M]'>Individual Round Logs</A>
	"}

	body += {"<br><br>
			<b>Other actions:</b>
			<br>
			<A href='?src=\ref[src];forcespeech=\ref[M]'>Forcesay</A>
			"}
	if (M.client)
		body += {" |
			<A href='?src=\ref[src];tdome1=\ref[M]'>Thunderdome 1</A> |
			<A href='?src=\ref[src];tdome2=\ref[M]'>Thunderdome 2</A> |
			<A href='?src=\ref[src];tdomeadmin=\ref[M]'>Thunderdome Admin</A> |
			<A href='?src=\ref[src];tdomeobserve=\ref[M]'>Thunderdome Observer</A> |
		"}
	// language toggles
	body += "<br><br><b>Languages:</b><br>"
	var/f = 1
	for(var/k in all_languages)
		var/datum/language/L = all_languages[k]
		if(!(L.language_flags & INNATE))
			if(!f) body += " | "
			else f = 0
			if(L in M.languages)
				body += "<a href='?src=\ref[src];toglang=\ref[M];lang=[html_encode(k)]' style='color:#006600'>[k]</a>"
			else
				body += "<a href='?src=\ref[src];toglang=\ref[M];lang=[html_encode(k)]' style='color:#ff0000'>[k]</a>"

	body += {"<br>
		</body></html>
	"}

	show_browser(usr, body, "window=adminplayeropts;size=550x515")

/datum/player_info/var/author // admin who authored the information
/datum/player_info/var/rank //rank of admin who made the notes
/datum/player_info/var/content // text content of the information
/datum/player_info/var/timestamp // Because this is bloody annoying

#define PLAYER_NOTES_ENTRIES_PER_PAGE 50
/datum/admins/proc/PlayerNotes()
	set category = "Admin"
	set name = "Player Notes"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return
	PlayerNotesPage()

/datum/admins/proc/PlayerNotesPage(filter_term)
	var/list/dat = list()
	dat += "<B>Player notes</B><HR>"
	var/savefile/S=new("data/player_notes.sav")
	var/list/note_keys
	from_file(S, note_keys)

	if(filter_term)
		for(var/t in note_keys)
			if(findtext(lowertext(t), lowertext(filter_term)))
				continue
			note_keys -= t

	dat += "<center><b>Search term:</b> <a href='?src=\ref[src];notes=set_filter'>[filter_term ? filter_term : "-----"]</a></center><hr>"

	if(!note_keys)
		dat += "No notes found."
	else
		dat += "<table>"
		note_keys = sortList(note_keys)
		for(var/t in note_keys)
			dat += "<tr><td><a href='?src=\ref[src];notes=show;ckey=[t]'>[t]</a></td></tr>"
		dat += "</table><br>"

	var/datum/browser/popup = new(usr, "player_notes", "Player Notes", 400, 400)
	popup.set_content(jointext(dat, null))
	popup.open()


/datum/admins/proc/player_has_info(key as text)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	from_file(info, infos)
	if(!infos || !infos.len) return 0
	else return 1


/datum/admins/proc/show_player_info(key as text)

	set category = "Admin"
	set name = "Show Player Info"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/list/dat = list()

	var/p_age = "unknown"
	for(var/client/C in GLOB.clients)
		if(C.ckey == key)
			p_age = C.player_age
			break
	dat += "<b>Player age: [p_age]</b><br><ul id='notes'>"

	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	from_file(info, infos)
	if(!infos)
		dat += "No information found on the given key.<br>"
	else
		var/update_file = 0
		var/i = 0
		for(var/datum/player_info/I in infos)
			i += 1
			if(!I.timestamp)
				I.timestamp = "Pre-4/3/2012"
				update_file = 1
			if(!I.rank)
				I.rank = "N/A"
				update_file = 1
			dat += "<li><font color=#7d9177>[I.content]</font> <i>by [I.author] ([I.rank])</i> on <i><font color='#8a94a3'>[I.timestamp]</i></font> "
			if(I.author == usr.key || I.author == "Adminbot" || ishost(usr))
				dat += "<A href='?src=\ref[src];remove_player_info=[key];remove_index=[i]'>Remove</A>"
			dat += "<hr></li>"
		if(update_file)
			to_file(info, infos)

	dat += "</ul><br><A href='?src=\ref[src];add_player_info=[key]'>Add Comment</A><br>"

	var/html = {"
		<html>
		<head>
			<title>Info on [key]</title>
			<script src='player_info.js'></script>
		</head>
		<body onload='selectTextField(); updateSearch()'; onkeyup='updateSearch()'>
			<div align='center'>
			<table width='100%'><tr>
				<td width='20%'>
					<div align='center'>
						<b>Search:</b>
					</div>
				</td>
				<td width='80%'>
					<input type='text'
					       id='filter'
					       name='filter_text'
					       value=''
					       style='width:100%;' />
				</td>
			</tr></table>
			<hr/>
			[jointext(dat, null)]
		</body>
		</html>
		"}

	send_rsc(usr,'code/js/player_info.js', "player_info.js")
	var/datum/browser/popup = new(usr, "adminplayerinfo", "Player Info", 480, 480)
	popup.set_content(html)
	popup.open()

/datum/admins/proc/Game()
	if(!check_rights(0))	return

	var/dat = {"
		<meta charset=\"utf-8\">
		<center><B>Game Panel</B></center><hr>\n
		<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
		"}
	if(SSticker.master_mode == "secret")
		dat += "<A href='?src=\ref[src];f_secret=1'>(Force Secret Mode)</A><br>"

	dat += {"
		<BR>
		<A href='?src=\ref[src];create_object=1'>Create Object</A><br>
		<A href='?src=\ref[src];quick_create_object=1'>Quick Create Object</A><br>
		<A href='?src=\ref[src];create_turf=1'>Create Turf</A><br>
		<A href='?src=\ref[src];create_mob=1'>Create Mob</A><br>
		<br><A href='?src=\ref[src];vsc=airflow'>Edit Airflow Settings</A><br>
		<A href='?src=\ref[src];vsc=plasma'>Edit Plasma Settings</A><br>
		<A href='?src=\ref[src];vsc=default'>Choose a default ZAS setting</A><br>
		"}

	show_browser(usr, dat, "window=admin2;size=210x280")
	return

/datum/admins/proc/Secrets(datum/admin_secret_category/active_category = null)
	if(!check_rights(0))	return

	// Print the header with category selection buttons.
	var/dat = "<B>The first rule of adminbuse is: you don't talk about the adminbuse.</B><HR>"
	for(var/datum/admin_secret_category/category in admin_secrets.categories)
		if(!category.can_view(usr))
			continue
		if(active_category == category)
			dat += "<span class='linkOn'>[category.name]</span>"
		else
			dat += "<A href='?src=\ref[src];admin_secrets_panel=\ref[category]'>[category.name]</A> "
	dat += "<HR>"

	// If a category is selected, print its description and then options
	if(istype(active_category) && active_category.can_view(usr))
		if(active_category.desc)
			dat += "<I>[active_category.desc]</I><BR>"
		for(var/datum/admin_secret_item/item in active_category.items)
			if(!item.can_view(usr))
				continue
			dat += "<A href='?src=\ref[src];admin_secrets=\ref[item]'>[item.name()]</A><BR>"
		dat += "<BR>"

	var/datum/browser/popup = new(usr, "secrets", "Secrets", 550, 500)
	popup.set_content(dat)
	popup.open()
	return

/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc="Restarts the world"
	if (!usr.client.holder)
		return

	var/list/options = list("Regular Restart", "Hard Restart (Skip MC Shutdown)", "Hardest Restart (Direct world.Reboot) \[Dangerous\]")

	var/result = tgui_input_list(usr, "Select reboot method", "World Reboot", options)
	if(!result)
		return

	var/failsafe = tgui_input_text(usr, "To confirm, type \"Server Restart\" in the box below", "WORLD REBOOT. THINK TWICE!!!")
	if(failsafe != "Server Restart")
		return

	var/init_by = "<span class='notice'>Initiated by [key_name(usr)].</span>"
	switch(result)
		if("Regular Restart")
			to_world("<span class='danger'>Restarting world!</span> [init_by]")
			log_admin("[key_name(usr)] initiated a reboot.")
			world.Reboot()
		if("Hard Restart (Skip MC Shutdown)")
			to_world("<span class='boldannounce'>Hard world restart.</span> [init_by]")
			log_admin("[key_name(usr)] initiated a hard reboot.")
			world.Reboot(reboot_hardness = REBOOT_HARD)
		if("Hardest Restart (Direct world.Reboot) \[Dangerous\]")
			to_world("<span class='boldannounce'>Hardest world restart.</span> [init_by]")
			log_admin("[key_name(usr)] initiated a hardest reboot.")
			world.Reboot(reboot_hardness = REBOOT_REALLY_HARD)

/datum/admins/proc/end_round()
	set category = "Server"
	set name = "End Round"
	set desc="Ends the round"

	if (!check_rights(R_SERVER))
		return
	if(GAME_STATE !=  RUNLEVEL_GAME)
		return
	if(alert("End the round?", "End round", "Yes", "Cancel") == "Cancel")
		return

	SSticker.force_end = TRUE

/datum/admins/proc/changemap()
	set category = "Server"
	set name = "Change map"
	if(!check_rights(R_SERVER)) return
	var/datum/map/M = GLOB.all_maps[input("Select map:","Change map",GLOB.using_map) as null|anything in GLOB.all_maps]
	if(M)
		to_world("<span class='notice'>Map has been changed to: <b>[M.name]</b></span>")
		log_and_message_admins("[key_name(usr)] changed map to [M.name]")
		fdel("data/use_map")
		text2file("[M.type]", "data/use_map")

/datum/admins/proc/announce()
	set category = "Special Verbs"
	set name = "Announce"
	set desc="Announce your desires to the world"
	if(!check_rights(0))	return

	var/message = input("Global message to send:", "Admin Announce", null, null) as message
	message = sanitize(message, 500, extra = 0)
	if(message)
		message = replacetext(message, "\n", "<br>") // required since we're putting it in a <p> tag
		to_world("<span class=notice><b>[key_name(usr)] Announces:</b><p style='text-indent: 50px'>[message]</p></span>")
		log_admin("Announce: [key_name(usr)]: [message]")

/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Globally Toggles OOC"
	set name="Toggle OOC"

	if(!check_rights(R_ADMIN))
		return

	toggle_ooc()
	log_and_message_admins("toggled OOC.")

/datum/admins/proc/toggleaooc()
	set category = "Server"
	set desc="Globally Toggles AOOC"
	set name="Toggle AOOC"

	if(!check_rights(R_ADMIN))
		return

	config.misc.aooc_allowed = !(config.misc.aooc_allowed)
	if (config.misc.aooc_allowed)
		to_world("<B>The AOOC channel has been globally enabled!</B>")
	else
		to_world("<B>The AOOC channel has been globally disabled!</B>")
	log_and_message_admins("toggled AOOC.")

/datum/admins/proc/togglelooc()
	set category = "Server"
	set desc="Globally Toggles LOOC"
	set name="Toggle LOOC"

	if(!check_rights(R_ADMIN))
		return

	toggle_looc()
	log_and_message_admins("toggled LOOC.")

/datum/admins/proc/toggledsay()
	set category = "Server"
	set desc="Globally Toggles DSAY"
	set name="Toggle DSAY"

	if(!check_rights(R_ADMIN))
		return

	config.misc.dsay_allowed = !(config.misc.dsay_allowed)
	if (config.misc.dsay_allowed)
		to_world("<B>Deadchat has been globally enabled!</B>")
	else
		to_world("<B>Deadchat has been globally disabled!</B>")
	log_and_message_admins("toggled deadchat.")

/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle Dead OOC."
	set name="Toggle Dead OOC"

	if(!check_rights(R_ADMIN))
		return

	config.misc.dead_ooc_allowed = !( config.misc.dead_ooc_allowed )
	log_admin("[key_name(usr)] toggled Dead OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.", 1)

/datum/admins/proc/togglehubvisibility()
	set category = "Server"
	set desc="Globally Toggles Hub Visibility"
	set name="Toggle Hub Visibility"

	if(!check_rights(R_ADMIN))
		return

	world.visibility = !(world.visibility)
	var/long_message = "[key_name(src)] toggled hub visibility. The server is now [world.visibility ? "visible" : "invisible"] ([world.visibility])."

	log_and_message_admins(long_message)

/datum/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(GAME_STATE < RUNLEVEL_LOBBY)
		SSticker.auto_start = !SSticker.auto_start
		message_admins(SPAN("info", "[key_name(src)] set the server start round configuration to [SSticker.auto_start ? "automatically start game as soon as possible" : "start game in normal mode (with a timer)."]"))
		to_chat(usr, SPAN_NOTICE("Unable to start the game as it is not set up. [SSticker.auto_start ? "It will automatically start game as soon as possible" : "It will start game in normal mode (with a timer)."]"))
		return 0
	if(SSticker.start_now())
		log_admin("[key_name(usr)] has started the game.")
		message_admins("<span class='info'>[key_name(usr)] has started the game.</span>")
		return 1
	else
		to_chat(usr, "<span class='warning'>Error: Start Now: Game has already started.</span>")
		return 0

/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"
	config.game.enter_allowed = !(config.game.enter_allowed)
	if (!(config.game.enter_allowed))
		to_world("<B>New players may no longer enter the game.</B>")
	else
		to_world("<B>New players may now enter the game.</B>")
	log_and_message_admins("[key_name_admin(usr)] toggled new player game entering.")
	world.update_status()

/datum/admins/proc/delay()
	set category = "Server"
	set desc="Delay the game start/end"
	set name="Delay"

	if(!check_rights(R_SERVER))	return
	if (GAME_STATE > RUNLEVEL_LOBBY)
		SSticker.delay_end = !SSticker.delay_end
		log_and_message_admins("[SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		return //alert("Round end delayed", null, null, null, null, null)
	SSticker.round_progressing = !SSticker.round_progressing
	if (!SSticker.round_progressing)
		to_world("<b>The game start has been delayed.</b>")
		log_and_message_admins("delayed the game.")
	else
		to_world("<b>The game will start soon.</b>")
		log_and_message_admins("removed the delay.")

/datum/admins/proc/adjump()
	set category = "Server"
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	config.admin.allow_admin_jump = !(config.admin.allow_admin_jump)
	log_and_message_admins("Toggled admin jumping to [config.admin.allow_admin_jump].")

/datum/admins/proc/adspawn()
	set category = "Server"
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	config.admin.allow_admin_spawning = !(config.admin.allow_admin_spawning)
	log_and_message_admins("toggled admin item spawning to [config.admin.allow_admin_spawning].")


/datum/admins/proc/ring_unready()
	set category = "Server"
	set desc = "(Pre-round only) Send an audio and text notification to all non-ready players."
	set name = "Ring Unready"

	if(!check_rights(R_SERVER))
		return

	if(GAME_STATE > RUNLEVEL_LOBBY)
		to_chat(usr, "Ring Unready is only available during the pre-round lobby.")
		return

	var/secs_to_roundstart = round(SSticker.pregame_timeleft / 10)
	var/players_rung = 0

	for(var/mob/new_player/player in GLOB.player_list)
		if(player.ready)
			continue

		to_chat(player, "<font size = '6'>READY UP! The round is starting in [secs_to_roundstart] seconds!</font>")
		sound_to(player, sound('sound/effects/adminhelp.ogg'))
		players_rung++

	to_chat(usr, "[players_rung] unready players notified.")
	log_and_message_admins("notified [players_rung] unready players.")

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/is_special_character(character) // returns 1 for special characters and 2 for heroes of gamemode
	return 0

/datum/admins/proc/spawn_atom(object as text)
	set category = "Debug"
	set desc = "(atom path) Spawn an atom"
	set name = "Spawn"

	if(!check_rights(R_SPAWN))	return

	var/list/types = typesof(/atom)
	var/list/matches = new()

	for(var/path in types)
		if(findtext("[path]", object))
			matches += path

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
		if(!chosen)
			return

	if(ispath(chosen,/turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		new chosen(usr.loc)

	log_and_message_admins("spawned [chosen] at ([usr.x],[usr.y],[usr.z])")

/datum/admins/proc/show_game_mode()
	set category = "Admin"
	set desc = "Show the current round configuration."
	set name = "Show Game Mode"

	if(!SSticker.mode)
		alert("Not before roundstart!", "Alert")
		return

	var/out = "<meta charset=\"utf-8\"><font size=3><b>Current mode: [SSticker.mode.name] (<a href='?src=\ref[SSticker.mode];debug_antag=self'>[SSticker.mode.config_tag]</a>)</b></font><br/>"
	out += "<hr>"

	if(SSticker.mode.ert_disabled)
		out += "<b>Emergency Response Teams:</b> <a href='?src=\ref[SSticker.mode];toggle=ert'>disabled</a>"
	else
		out += "<b>Emergency Response Teams:</b> <a href='?src=\ref[SSticker.mode];toggle=ert'>enabled</a>"
	out += "<br/>"

	if(SSticker.mode.deny_respawn)
		out += "<b>Respawning:</b> <a href='?src=\ref[SSticker.mode];toggle=respawn'>disallowed</a>"
	else
		out += "<b>Respawning:</b> <a href='?src=\ref[SSticker.mode];toggle=respawn'>allowed</a>"
	out += "<br/>"

	out += "<br/><br/>"

	out += "<hr>"

	show_browser(usr, out, "window=edit_mode[src]")


/datum/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmets."
	config.misc.welder_vision_allowed = !( config.misc.welder_vision_allowed )
	if (config.misc.welder_vision_allowed)
		to_world("<B>Reduced welder vision has been enabled!</B>")
	else
		to_world("<B>Reduced welder vision has been disabled!</B>")
	log_and_message_admins("toggled welder vision.")

/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle guests"
	config.game.guests_allowed = !(config.game.guests_allowed)
	if (!(config.game.guests_allowed))
		to_world("<B>Guests may no longer enter the game.</B>")
	else
		to_world("<B>Guests may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled guests game entering [config.game.guests_allowed?"":"dis"]allowed.")
	log_and_message_admins("toggled guests game entering [config.game.guests_allowed?"":"dis"]allowed.")

/client/proc/update_mob_sprite(mob/living/carbon/human/H as mob)
	set category = "Admin"
	set name = "Update Mob Sprite"
	set desc = "Should fix any mob sprite update errors."

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(istype(H))
		H.regenerate_icons()


/*
	helper proc to test if someone is a mentor or not.  Got tired of writing this same check all over the place.
*/
/proc/is_mentor(client/C)

	if(!istype(C))
		return 0
	if(!C.holder)
		return 0

	if(C.holder.rights == R_MENTOR)
		return 1
	return 0

/proc/get_options_bar(whom, detail = 2, name = 0, link = 1, highlight_special = 1, datum/ticket/ticket = null)
	if(!whom)
		return "<b>(*null*)</b>"
	var/mob/M
	var/client/C
	if(istype(whom, /client))
		C = whom
		M = C.mob
	else if(istype(whom, /mob))
		M = whom
		C = M.client
	else
		return "<b>(*not a mob*)</b>"
	switch(detail)
		if(0)
			return "<b>[key_name(C, link, name, highlight_special, ticket)]</b>"

		if(1)	//Private Messages
			return "<b>[key_name(C, link, name, highlight_special, ticket)](<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)</b>"

		if(2)	//Admins
			var/ref_mob = "\ref[M]"
			return "<b>[key_name(C, link, name, highlight_special, ticket)](<A HREF='?_src_=holder;adminmoreinfo=[ref_mob]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=[ref_mob]'>PP</A>) (<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[ref_mob]'>SM</A>) ([admin_jump_link(M)]) (<A HREF='?_src_=holder;check_antagonist=1'>CA</A>)</b>"

		if(3)	//Devs
			var/ref_mob = "\ref[M]"
			return "<b>[key_name(C, link, name, highlight_special, ticket)](<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>)([admin_jump_link(M)])</b>"

		if(4)	//Mentors
			var/ref_mob = "\ref[M]"
			return "<b>[key_name(C, link, name, highlight_special, ticket)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=[ref_mob]'>PP</A>) (<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[ref_mob]'>SM</A>) ([admin_jump_link(M)])</b>"


/proc/ishost(whom)
	if(!whom)
		return 0
	var/client/C
	var/mob/M
	if(istype(whom, /client))
		C = whom
	if(istype(whom, /mob))
		M = whom
		C = M.client
	if(R_HOST & C.holder.rights)
		return 1
	else
		return 0

//Prevents SDQL2 commands from changing admin permissions
/datum/admins/SDQL_update(const/var_name, new_value)
	return 0

//
//
//ALL DONE
//*********************************************************************************************************
//

//Returns 1 to let the dragdrop code know we are trapping this event
//Returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/observer/ghost/frommob, mob/living/tomob)
	if(!istype(frommob))
		return //Extra sanity check to make sure only observers are shoved into things

	//Same as assume-direct-control perm requirements.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_ADMIN|R_DEBUG,0))
		return 0
	if (!frommob.ckey)
		return 0
	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"
	var/ask = alert(question, "Place ghost in control of mob?", "Yes", "No")
	if (ask != "Yes")
		return 1
	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return 1
	if(tomob.client) //No need to ghostize if there is no client
		tomob.ghostize(0)
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has put [frommob.ckey] in control of [tomob.name].</span>")
	log_admin("[key_name(usr)] stuffed [frommob.ckey] into [tomob.name].")
	tomob.ckey = frommob.ckey
	qdel(frommob)
	return 1

/datum/admins/proc/paralyze_mob(mob/H as mob in GLOB.player_list)
	set category = "Admin"
	set name = "Toggle Paralyze"
	set desc = "Paralyzes a player. Or unparalyses them."

	var/msg

	if(!isliving(H))
		return

	if(check_rights(R_ADMIN))
		if (H.paralysis == 0)
			H.paralysis = 8000
			msg = "has paralyzed [key_name(H)]."
		else
			H.paralysis = 0
			msg = "has unparalyzed [key_name(H)]."
		log_and_message_admins(msg)

/datum/admins/proc/change_lobby_art()
	set name = "Change Lobby Art"
	set category = "Server"

	if(!check_rights(R_SERVER))
		return

	var/datum/lobby_art/chosen_one = tgui_input_list(src, "Choose a new lobby art to set.", "Lobby Art", SSlobby.loaded_lobby_arts)
	if(isnull(chosen_one))
		return

	SSlobby.change_lobby_art(chosen_one)

/datum/admins/proc/change_lobby_music()
	set name = "Change Lobby Music"
	set category = "Server"

	if(!check_rights(R_SERVER))
		return

	var/list/music_choices = list()
	for (var/type in typesof(/lobby_music))
		var/lobby_music/temp = new type()
		music_choices[temp.title] = type

	var/choice = input("Choose a new lobby music to set.", "Lobby Music") as null|anything in music_choices

	if (choice)
		var/lobby_music/M = music_choices[choice]
		GLOB.lobby_music = new M()
		message_admins("[key_name(usr)] has changed lobby music to [M.title].")
		for(var/client/C in GLOB.clients)
			if(C.mob && isnewplayer(C.mob))
				sound_to(C, sound(null, repeat = 0, wait = 0, volume = 0, channel = 1))
				C.playtitlemusic()
