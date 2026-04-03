/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:

			mind.transfer_to(new_mob)

	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

/datum/mind
	var/key
	var/name				//replaces mob/var/original_name
	var/mob/living/current
	var/weakref/original_mob = null // must contain /mob/living
	var/active = 0

	var/memory
	var/list/known_connections //list of known (RNG) relations between people
	var/gen_relations_info

	var/assigned_role
	var/special_role

	var/role_alt_title

	var/datum/job/assigned_job

	//used for optional self-objectives that antagonists can give themselves, which are displayed at the end of the round.
	var/ambitions

	//used to store what traits the player had picked out in their preferences before joining, in text form.
	var/list/traits = list()

/datum/mind/New(key)
	src.key = key
	..()

/datum/mind/Destroy()
	SSticker.minds -= src
	set_current(null)
	original_mob = null
	. = ..()

/datum/mind/proc/set_current(mob/new_current)
	if(new_current && QDELETED(new_current))
		util_crash_with("Tried to set a mind's current var to a qdeleted mob, what the fuck")
	if(current)
		unregister_signal(src, SIGNAL_QDELETING)
	current = new_current
	if(current)
		register_signal(src, SIGNAL_QDELETING, nameof(.proc/clear_current))

/datum/mind/proc/clear_current(datum/source)
	set_current(null)

/datum/mind/proc/transfer_to(mob/living/new_character)
	if(!istype(new_character))
		to_world_log("## DEBUG: transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob. Please inform developers.")
		return FALSE

	if(current)					//remove ourself from our old body's mind variable
		current.mind = null
		SSnano.user_transferred(current, new_character) // transfer active NanoUI instances to new user

	if(new_character.mind)		//remove any mind currently in our new body's mind variable
		new_character.mind.set_current(null)

	set_current(new_character) //link ourself to our new body
	new_character.mind = src   //and link our new body to ourself

	if(active)
		new_character.key = key		//now transfer the key to link the client to our new body

	return TRUE

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<BR>"

/datum/mind/proc/show_memory(mob/recipient)
	var/output = "<meta charset=\"utf-8\"><B>[current.real_name]'s Memory</B><HR>"
	output += memory

	if(ambitions)
		output += "<HR><B>Ambitions:</B> [ambitions]<br>"
	show_browser(recipient, output,"window=memory")

/datum/mind/proc/edit_memory()
	if(GAME_STATE <= RUNLEVEL_SETUP)
		alert("Not before round-start!", "Alert")
		return

	var/out = "<meta charset=\"utf-8\"><B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"
	out += "Mind currently owned by key: [key] [active?"(synced)":"(not synced)"]<br>"
	out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>"
	out += "<hr>"
	out += "</table><hr>"

	out += "<br><a href='?src=\ref[src];obj_add=1'>\[add\]</a><br><br>"
	out += "<b>Ambitions:</b> [ambitions ? ambitions : "None"] <a href='?src=\ref[src];amb_edit=\ref[src]'>\[edit\]</a></br>"
	show_browser(usr, out, "window=edit_memory[src]")

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))	return

	else if (href_list["role_edit"])
		var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in joblist
		if (!new_role) return
		assigned_role = new_role

	else if (href_list["memory_edit"])
		var/new_memo = sanitize(input("Write new memory", "Memory", memory) as null|message)
		if (isnull(new_memo)) return
		memory = new_memo

	else if (href_list["amb_edit"])
		var/datum/mind/mind = locate(href_list["amb_edit"])
		if(!mind)
			return
		var/new_ambition = input("Enter a new ambition", "Memory", mind.ambitions) as null|message
		if(isnull(new_ambition))
			return
		new_ambition = sanitize(new_ambition)
		if(mind)
			mind.ambitions = new_ambition
			if(new_ambition)
				to_chat(mind.current, "<span class='warning'>Your ambitions have been changed by higher powers, they are now: [mind.ambitions]</span>")
				log_and_message_admins("made [key_name(mind.current)]'s ambitions be '[mind.ambitions]'.")
			else
				to_chat(mind.current, "<span class='warning'>Your ambitions have been unmade by higher powers.</span>")
				log_and_message_admins("has cleared [key_name(mind.current)]'s ambitions.")
		else
			to_chat(usr, "<span class='warning'>The mind has ceased to be.</span>")
	else if (href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/I in current)
					current.drop(I)

	edit_memory()

/datum/mind/proc/reset()
	assigned_role =   null
	special_role =    null
	role_alt_title =  null
	assigned_job =    null

//Antagonist role check
/mob/living/proc/check_special_role(role)
	if(mind)
		if(!role)
			return mind.special_role
		else
			return (mind.special_role == role) ? 1 : 0
	else
		return 0

//Initialisation procs
/mob/living/proc/mind_initialize()
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		mind.original_mob = weakref(src)
		SSticker.minds += mind
	if(!mind.name)	mind.name = real_name
	mind.set_current(src)

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)	mind.assigned_role = "Assistant"	//defualt
