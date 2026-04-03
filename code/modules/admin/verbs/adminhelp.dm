/client/proc/adminhelp(msg)
	// handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Admin-PM: You cannot send adminhelps (Muted).</font>")
		return

	adminhelped = 1 // Determines if they get the message to reply by clicking the name.

	// clean the input msg
	if(!msg)
		msg = input(src, "", "Adminhelp")
	msg = sanitize(msg)
	if(!msg)
		return
	var/original_msg = msg


	if(!mob) // this doesn't happen
		return

	// handle ticket
	var/datum/client_lite/client_lite = client_repository.get_lite_client(src)
	var/datum/ticket/ticket = get_open_ticket_by_client(client_lite)
	if(!ticket)
		ticket = new /datum/ticket(client_lite)
	else if(ticket.status == TICKET_ASSIGNED)
		// manually check that the target client exists here as to not spam the usr for each logged out admin on the ticket
		var/admin_found = 0
		for(var/datum/client_lite/admin in ticket.assigned_admins)
			var/client/admin_client = client_by_ckey(admin.ckey)
			if(admin_client)
				admin_found = 1
				src.cmd_admin_pm(admin_client, original_msg, ticket)
				break
		if(!admin_found)
			to_chat(src, SPAN("warning", "Error: Private-Message: Client not found. They may have lost connection, so please be patient!"))
		return

	ticket.msgs += new /datum/ticket_msg(src.ckey, null, original_msg)
	update_ticket_panels()


	// Options bar:  mob, details ( admin = 2, dev = 3, mentor = 4, character name (0 = just ckey, 1 = ckey and character name), link? (0 no don't make it a link, 1 do so),
	//		highlight special roles (0 = everyone has same looking name, 1 = antags / special roles get a golden name)

	var/mentor_msg = SPAN("notice linkify", "<b><font color=red>[create_text_tag("help", "HELP")] </font>[get_options_bar(mob, 4, 1, 1, 0, ticket)] (<a href='?_src_=holder;take_ticket=\ref[ticket]'>[(ticket.status == TICKET_OPEN) ? "TAKE" : "JOIN"]</a>) (<a href='?src=\ref[usr];close_ticket=\ref[ticket]'>CLOSE</a>):</b> [msg]")
	msg = SPAN("notice linkify", "<b><font color=red>[create_text_tag("help", "HELP")] </font>[get_options_bar(mob, 2, 1, 1, 1, ticket)] (<a href='?_src_=holder;take_ticket=\ref[ticket]'>[(ticket.status == TICKET_OPEN) ? "TAKE" : "JOIN"]</a>) (<a href='?src=\ref[usr];close_ticket=\ref[ticket]'>CLOSE</a>):</b> [msg]")

	var/admin_number_afk = 0

	for(var/client/X in GLOB.admins)
		if((R_ADMIN|R_MOD|R_MENTOR) & X.holder.rights)
			if(X.is_afk())
				admin_number_afk++
			if(X.get_preference_value(/datum/client_preference/staff/play_adminhelp_ping) == GLOB.PREF_HEAR)
				sound_to(X, sound('sound/effects/adminhelp.ogg'))
			if(X.holder.rights == R_MENTOR)
				to_chat(X, mentor_msg, type = MESSAGE_TYPE_ADMINPM) // Mentors won't see coloring of names on people with special_roles (Antags, etc.)
			else
				to_chat(X, msg, type = MESSAGE_TYPE_ADMINPM)
	// show it to the person adminhelping too
	to_chat(src, SPAN("notice linkify", "PM to-<b>Staff</b> (<a href='?src=\ref[usr];close_ticket=\ref[ticket]'>CLOSE</a>): [original_msg]"), type = MESSAGE_TYPE_ADMINPM)
	var/admin_number_present = GLOB.admins.len - admin_number_afk
	log_admin("HELP: [key_name(src)]: [original_msg] - heard by [admin_number_present] non-AFK admins.")

	return

/client/verb/adminhelp_verb()
	set category = "Admin"
	set name = "Adminhelp"

	// Sweet copypasta, but we need it.
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Admin-PM: You cannot send adminhelps (Muted).</font>")
		return

	var/klauza = input(usr, "Describe your problem:", "Admin, help!") as text|null
	if(!klauza)
		return

	adminhelp(klauza)
	return
