/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	voice_name = "unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"

	throw_range = 4

	var/list/hud_list[12]
	var/embedded_flag	  //To check if we've need to roll for damage on movement while an item is imbedded in us.
	var/obj/item/rig/wearing_rig // This is very not good, but it's much much better than calling get_rig() every update_canmove() call.

	var/list/stance_limbs
	var/list/grasp_limbs
	var/last_body_response_to_pain = 0

/mob/living/carbon/human/New(new_loc, new_species = null)

	grasp_limbs = list()
	stance_limbs = list()

	if(!dna)
		dna = new /datum/dna(null)
		// Species name is handled by set_species()

	if(!species)
		if(new_species)
			set_species(new_species, 1)
		else
			set_species()

	if(species)
		real_name = species.get_random_name(gender)
		SetName(real_name)
		if(mind)
			mind.name = real_name

	hud_list[HEALTH_HUD]       = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD]       = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[LIFE_HUD]	       = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[ID_HUD]           = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[WANTED_HUD]       = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]     = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]      = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]     = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD]  = new /image/hud_overlay('icons/mob/huds/antag_hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD_OOC]   = new /image/hud_overlay('icons/mob/huds/hud.dmi', src, "hudblank")
	hud_list[XENO_HUD]         = new /image/hud_overlay('icons/mob/huds/antag_hud.dmi', src, "hudblank")

	GLOB.human_mob_list |= src
	..()

	if(dna)
		dna.ready_dna(src)
		dna.real_name = real_name
		dna.s_base = s_base
		sync_organ_dna()

	if(!should_have_organ(BP_LIVER)) // Blood can clot w/out a liver.
		coagulation = species.coagulation

	BITSET(hud_updateflag, STATUS_HUD)

/mob/living/carbon/human/Destroy()
	GLOB.human_mob_list -= src

	QDEL_NULL_LIST(worn_underwear)
	QDEL_LIST_ASSOC(hud_list)

	// carbon/Destroy() will handle qdeling the organs, let's just clear the lists.
	stance_limbs.Cut()
	grasp_limbs.Cut()
	bad_external_organs.Cut()

	return ..()

/mob/living/carbon/human/get_description_fluff()
	return print_flavor_text(FALSE)

/mob/living/carbon/human/Stat()
	. = ..()
	if(statpanel("Status"))
		stat("Intent:", "[a_intent]")
		stat("Move Mode:", "[m_intent]")
		stat("Poise:", "[round(100/poise_pool*poise)]%")

		if (istype(internal))
			if (!internal.air_contents)
				qdel(internal)
			else
				stat("Internal Atmosphere Info: ", internal.name)
				stat("Tank Pressure: ", internal.air_contents.return_pressure())
				stat("Distribution Pressure: ", internal.distribute_pressure)

/mob/living/carbon/human/ex_act(severity)
	if(!blinded)
		flash_eyes()

	var/b_loss = null
	var/f_loss = null
	var/cochlear = has_cochlear_implant()
	switch(severity)
		if(1.0)
			b_loss = 400
			f_loss = 100
			if(!prob(get_flat_armor(null, "bomb")))
				gib()
				return
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 1)
			//return
//				var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
				//user.throw_at(target, 200, 4)

		if(2.0)
			b_loss = 100
			f_loss = 50

			if(get_ear_protection() < 2)
				adjustEarDamage(30, 120)
			if(!cochlear && prob(70))
				Paralyse(10)

		if(3.0)
			b_loss = 50
			if(get_ear_protection() < 2)
				adjustEarDamage(15, 60)
			if(!cochlear && prob(50))
				Paralyse(10)

	// factor in armour
	var/protection = blocked_mult(get_flat_armor(null, "bomb"))
	b_loss *= protection
	f_loss *= protection

	// focus most of the blast on one organ
	var/obj/item/organ/external/take_blast = pick(external_organs)
	take_blast.take_external_damage(b_loss * 0.7, f_loss * 0.7, used_weapon = "Explosive Blast")

	// distribute the remaining 30% on all limbs equally (including the one already dealt damage)
	b_loss *= 0.3
	f_loss *= 0.3
	for(var/obj/item/organ/external/temp in external_organs)
		temp.take_external_damage(b_loss, f_loss, used_weapon = "Explosive Blast")

/mob/living/carbon/human/restrained()
	if (handcuffed)
		return 1
	if(grab_restrained())
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	if (!can_use_hands)
		return 1
	return 0

/mob/living/carbon/human/proc/grab_restrained()
	for (var/obj/item/grab/G in grabbed_by)
		if(G.restrains())
			return TRUE

/mob/living/carbon/human/var/co2overloadtime = null
/mob/living/carbon/human/var/temperature_resistance = 75 CELSIUS

/mob/living/carbon/human/show_inv(mob/user, underwear_only = FALSE)
	if(user.incapacitated())
		return FALSE

	if(!(user.Adjacent(src) || (istype(loc, /obj/item/holder) && loc.loc == user)))
		return FALSE

	var/dat = "<B><HR><FONT size=3>[name]</FONT></B><BR><HR>"
	if(!user.IsAdvancedToolUser(TRUE))
		dat += underwear_only ? "" : show_inv_get_slots_reduced()
	else
		dat += underwear_only ? "" : show_inv_get_slots()
		dat += show_inv_get_underwear()

	dat += show_inv_get_ending(user, underwear_only)

	if(!user.show_inventory || user.show_inventory.user != user)
		user.show_inventory = new /datum/browser(user, "mob[name]", "Inventory", 340, 560)
		user.show_inventory.set_content(dat)
	else
		user.show_inventory.set_content(dat)
		user.show_inventory.update()

	return TRUE

/mob/living/carbon/human/proc/show_inv_get_slots_reduced()
	var/data

	var/firstline = TRUE
	for(var/entry in species.hud.gear)
		var/list/slot_ref = species.hud.gear[entry]
		if((slot_ref["slot"] in list(slot_l_store, slot_r_store, slot_w_uniform, slot_gloves, slot_shoes, slot_wear_id)))
			continue
		var/obj/item/thing_in_slot = get_equipped_item(slot_ref["slot"])
		if(firstline)
			firstline = FALSE
		else
			data += "<BR>"
		data += "<B>[slot_ref["name"]]:</b> <a href='?src=\ref[src];item=[slot_ref["slot"]]'>[istype(thing_in_slot) ? thing_in_slot : "nothing"]</a>"
	data += "<HR>"

	if(species.hud.has_hands)
		data += "<b>Left hand:</b> <A href='?src=\ref[src];item=[slot_l_hand]'>[istype(l_hand) ? l_hand : "nothing"]</A>"
		data += "<BR><b>Right hand:</b> <A href='?src=\ref[src];item=[slot_r_hand]'>[istype(r_hand) ? r_hand : "nothing"]</A>"

	return data

/mob/living/carbon/human/proc/show_inv_get_slots()
	var/data

	var/firstline = TRUE
	for(var/entry in species.hud.gear)
		var/list/slot_ref = species.hud.gear[entry]
		if((slot_ref["slot"] in list(slot_l_store, slot_r_store)))
			continue
		var/obj/item/thing_in_slot = get_equipped_item(slot_ref["slot"])
		if(firstline)
			firstline = FALSE
		else
			data += "<BR>"
		data += "<B>[slot_ref["name"]]:</b> <a href='?src=\ref[src];item=[slot_ref["slot"]]'>[istype(thing_in_slot) ? thing_in_slot : "nothing"]</a>"
		if(istype(thing_in_slot, /obj/item/clothing))
			var/obj/item/clothing/C = thing_in_slot
			if(LAZYLEN(C.accessories))
				data += "<BR><A href='?src=\ref[src];item=tie;holder=\ref[C]'>Remove accessory</A>"
	data += "<HR>"

	if(species.hud.has_hands)
		data += "<b>Left hand:</b> <A href='?src=\ref[src];item=[slot_l_hand]'>[istype(l_hand) ? l_hand : "nothing"]</A>"
		data += "<BR><b>Right hand:</b> <A href='?src=\ref[src];item=[slot_r_hand]'>[istype(r_hand) ? r_hand : "nothing"]</A>"

	// Do they get an option to set internals?
	if(istype(wear_mask, /obj/item/clothing/mask) || istype(head, /obj/item/clothing/head/helmet/space))
		if(istype(back, /obj/item/tank) || istype(belt, /obj/item/tank) || istype(s_store, /obj/item/tank))
			data += "<BR><A href='?src=\ref[src];item=internals'>Toggle internals.</A>"

	var/obj/item/clothing/under/suit = w_uniform
	// Other incidentals.
	if(istype(suit))
		data += "<BR><b>Pockets:</b> <A href='?src=\ref[src];item=pockets'>Empty or Place Item</A>"
		if(suit.rolled_down != -1)
			data += "<BR><A href='?src=\ref[src];item=rolldown'>Roll Down Jumpsuit</A>"
		if(suit.has_sensor == 1)
			data += "<BR><A href='?src=\ref[src];item=sensors'>Set sensors</A>"
	if(handcuffed)
		data += "<BR><A href='?src=\ref[src];item=[slot_handcuffed]'>Handcuffed</A>"

	return data

/mob/living/carbon/human/proc/show_inv_get_underwear()
	var/data

	for(var/entry in worn_underwear)
		var/obj/item/underwear/UW = entry
		data += "<BR><a href='?src=\ref[src];item=\ref[UW]'>Remove \the [UW]</a>"

	return data

/mob/living/carbon/human/proc/show_inv_get_ending(mob/user, underwear_only = FALSE)
	var/data

	if(!underwear_only && user.IsAdvancedToolUser(TRUE))
		data += "<BR><A href='?src=\ref[src];item=splints'>Remove splints</A>"
	data += "<HR><A href='?src=\ref[src];refresh=1;underwear_only=[underwear_only]'>Refresh</A>"
	data += "<BR><A href='?src=\ref[user];inv_close=1'>Close</A>"

	return data

// called when something steps onto a human
// this handles mulebots and vehicles
/mob/living/carbon/human/Crossed(atom/movable/AM)
	if(istype(AM, /obj/vehicle))
		var/obj/vehicle/V = AM
		V.RunOver(src)

// Get rank from ID, ID inside PDA, PDA, ID in wallet, etc.
/mob/living/carbon/human/proc/get_authentification_rank(if_no_id = "No id", if_no_job = "No job")
	var/obj/item/card/id/id = get_id_card()
	if(id)
		return id.rank ? id.rank : if_no_job
	else
		return if_no_id

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(if_no_id = "No id", if_no_job = "No job")
	var/obj/item/card/id/id = get_id_card()
	if(id)
		return id.assignment ? id.assignment : if_no_job
	else
		return if_no_id

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(if_no_id = "Unknown")
	var/obj/item/card/id/id = get_id_card()
	if(id)
		return id.registered_name ? id.registered_name : if_no_id
	else
		return if_no_id

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/proc/get_visible_name()
	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if((face_name == "Unknown") && id_name && (id_name != face_name))
		return "[face_name] (as [id_name])"
	return face_name

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
//Also used in AI tracking people by face, so added in checks for head coverings like masks and helmets
/mob/living/carbon/human/proc/get_face_name()
	var/obj/item/organ/external/H = get_organ(BP_HEAD)
	if(!H || (H.status & ORGAN_DISFIGURED) || H.is_stump() || !real_name || (MUTATION_HUSK in mutations) || (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE)))	//Face is unrecognizeable, use ID if able
		if(istype(wear_mask))
			return wear_mask.visible_name
		else
			return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(if_no_id = "Unknown")
	. = if_no_id
	if(wear_id)
		var/obj/item/card/id/I = wear_id.get_id_card()
		if(I)
			return I.registered_name
	return

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(shock_damage, obj/source, base_siemens_coeff = 1.0, def_zone = null)

	if(status_flags & GODMODE)
		return 0

	if(species.siemens_coefficient == -1)
		if(stored_shock_by_ref["\ref[src]"])
			stored_shock_by_ref["\ref[src]"] += shock_damage
		else
			stored_shock_by_ref["\ref[src]"] = shock_damage
		return

	if (!def_zone)
		def_zone = pick(BP_L_HAND, BP_R_HAND)

	return ..(shock_damage, source, base_siemens_coeff, def_zone)

/mob/living/carbon/human/apply_shock(shock_damage, def_zone, base_siemens_coeff = 1.0)
	var/obj/item/organ/external/initial_organ = get_organ(check_zone(def_zone))
	if(!initial_organ)
		initial_organ = pick(external_organs)

	var/obj/item/organ/external/floor_organ

	if(!lying)
		var/list/obj/item/organ/external/standing = list()
		for(var/limb_tag in list(BP_L_FOOT, BP_R_FOOT))
			var/obj/item/organ/external/E = external_organs_by_name[limb_tag]
			if(E && E.is_usable())
				standing[E.organ_tag] = E
		if((def_zone == BP_L_FOOT || def_zone == BP_L_LEG) && standing[BP_L_FOOT])
			floor_organ = standing[BP_L_FOOT]
		if((def_zone == BP_R_FOOT || def_zone == BP_R_LEG) && standing[BP_R_FOOT])
			floor_organ = standing[BP_R_FOOT]
		else
			floor_organ = standing[pick(standing)]

	if(!floor_organ)
		floor_organ = pick(external_organs)

	var/list/obj/item/organ/external/to_shock = trace_shock(initial_organ, floor_organ)

	if(to_shock && to_shock.len)
		shock_damage /= to_shock.len
		shock_damage = round(shock_damage, 0.1)
	else
		return 0

	var/total_damage = 0

	for(var/obj/item/organ/external/E in to_shock)
		total_damage += ..(shock_damage, E.organ_tag, base_siemens_coeff * get_siemens_coefficient_organ(E))
	return total_damage

/mob/living/carbon/human/proc/trace_shock(obj/item/organ/external/init, obj/item/organ/external/floor)
	var/list/obj/item/organ/external/traced_organs = list(floor)

	if(!init)
		return

	if(!floor || init == floor)
		return list(init)

	for(var/obj/item/organ/external/E in list(floor, init))
		while(E && E.parent_organ)
			E = external_organs_by_name[E.parent_organ]
			traced_organs += E
			if(E == init)
				return traced_organs

	return traced_organs

/mob/living/carbon/human/Topic(href, href_list)

	if(href_list["refresh"])
		if(Adjacent(src, usr))
			show_inv(usr, text2num(href_list["underwear_only"]))

	if(href_list["inv_close"])
		if(usr.show_inventory)
			usr.show_inventory.close()

	if(href_list["item"])
		handle_strip(href_list["item"],usr,locate(href_list["holder"]))

	if (href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		if(I)
			src.examinate(I)

	if (href_list["lookmob"])
		var/mob/M = locate(href_list["lookmob"])
		if(M)
			src.examinate(M)

	if (href_list["flavor_change"])
		if (usr != src)
			href_exploit(usr.ckey, href)
			return

		switch(href_list["flavor_change"])
			if("done")
				show_browser(src, null, "window=flavor_changes")
				return
			if("general")
				var/msg = sanitize(input(usr,"Update the general description of your character. This will be shown regardless of clothing, and may NOT include OOC notes and preferences.","Flavor Text",html_decode(flavor_texts[href_list["flavor_change"]])) as message, extra = 0)
				flavor_texts[href_list["flavor_change"]] = msg
				return
			else
				var/msg = sanitize(input(usr,"Update the flavor text for your [href_list["flavor_change"]].","Flavor Text",html_decode(flavor_texts[href_list["flavor_change"]])) as message, extra = 0)
				flavor_texts[href_list["flavor_change"]] = msg
				set_flavor()
				return
	..()
	return

///eyecheck()
///Returns a number between -1 to 2
/mob/living/carbon/human/eyecheck()
	var/total_protection = flash_protection
	if(internal_organs_by_name[BP_EYES]) // Eyes are fucked, not a 'weak point'.
		var/obj/item/organ/internal/eyes/I = internal_organs_by_name[BP_EYES]
		if(!I?.is_usable())
			return FLASH_PROTECTION_MAJOR
		else
			total_protection = I.get_total_protection(flash_protection)
	else // They can't be flashed if they don't have eyes.
		return FLASH_PROTECTION_MAJOR
	return total_protection

/mob/living/carbon/human/flash_eyes(intensity = FLASH_PROTECTION_MODERATE, override_blindness_check = FALSE, affect_silicon = FALSE, visual = FALSE, type = /atom/movable/screen/fullscreen/flash, effect_duration = 25)
	if(internal_organs_by_name[BP_EYES]) // Eyes are fucked, not a 'weak point'.
		var/obj/item/organ/internal/eyes/I = internal_organs_by_name[BP_EYES]
		I.additional_flash_effects(intensity)
	return ..()

//Used by various things that knock people out by applying blunt trauma to the head.
//Checks that the species has a "head" (brain containing organ) and that hit_zone refers to it.
/mob/living/carbon/human/proc/headcheck(target_zone, brain_tag = BP_BRAIN)

	var/obj/item/organ/affecting = internal_organs_by_name[brain_tag]

	target_zone = check_zone(target_zone)
	if(!affecting || affecting.parent_organ != target_zone)
		return 0

	//if the parent organ is significantly larger than the brain organ, then hitting it is not guaranteed
	var/obj/item/organ/parent = get_organ(target_zone)
	if(!parent)
		return 0

	if(parent.w_class > affecting.w_class + 1)
		return prob(100 / 2**(parent.w_class - affecting.w_class - 1))

	return 1

/mob/living/carbon/human/IsAdvancedToolUser(silent)
	if(species.has_fine_manipulation)
		return 1
	if(!silent)
		to_chat(src, FEEDBACK_YOU_LACK_DEXTERITY)
	return 0

/mob/living/carbon/human/abiotic(full_body = TRUE)
	if(full_body)
		if(src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.l_ear || src.r_ear || src.gloves)
			return FALSE
	return ..()

/mob/living/carbon/human/proc/check_dna()
	dna.check_integrity(src)
	return

/mob/living/carbon/human/get_species()
	if(!species)
		set_species()
	return species.name

/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		visible_message("<span class='warning'>\The [src] begins playing \his ribcage like a xylophone. It's quite spooky.</span>","<span class='notice'>You begin to play a spooky refrain on your ribcage.</span>","<span class='warning'>You hear a spooky xylophone melody.</span>")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/proc/check_has_mouth()
	// mobs do not have mouths by default
	return 0

/mob/living/carbon/human/check_has_mouth()
	// Todo, check stomach organ when implemented.
	var/obj/item/organ/external/head/H = get_organ(BP_HEAD)
	if(!H || !istype(H) || !H.can_intake_reagents)
		return 0
	return 1

/mob/living/carbon/human/proc/ingest(atom/movable/AM, ignore_taste = FALSE)
	if(QDELETED(AM))
		return FALSE

	if(!should_have_organ(BP_STOMACH))
		return FALSE // Whatever fallback we rely on.

	var/obj/item/organ/internal/stomach/S = internal_organs_by_name[BP_STOMACH]
	if(S)
		S.ingest(AM)

		if(S.is_broken())
			if(prob(25))
				custom_pain("Your stomach cramps agonizingly!", 20)
			else
				custom_pain("Your stomach cramps!", 10)
		else if(S.is_bruised() && prob(25))
			custom_pain("Your stomach cramps a little.", 3)

		return TRUE

	if(should_have_organ(BP_INTESTINES))
		var/obj/item/organ/internal/intestines/I = internal_organs_by_name[BP_INTESTINES]
		if(!I) // No stomach nor intestines, tough time to have a supper.
			// TODO: Abdominal cavity here
			custom_pain("Your guts cramp!", 10)
			AM.forceMove(loc)
		else
			AM.forceMove(I)
		return TRUE

	return FALSE

/mob/living/carbon/human/proc/vomit(toxvomit = 0, timevomit = 1, level = 3, silent = FALSE)
	set waitfor = 0
	if(!timevomit || !level || !check_has_mouth())
		return
	level = Clamp(level, 1, 3)
	timevomit = Clamp(timevomit, 1, 10)
	if(is_ic_dead())
		return
	if(!lastpuke)
		lastpuke = 1
		if(!silent)
			to_chat(src, "<span class='warning'>You feel nauseous...</span>")
		if(level > 1)
			sleep(150 / timevomit)	//15 seconds until second warning
			to_chat(src, "<span class='warning'>You feel like you are about to throw up!</span>")
			if(level > 2)
				sleep(100 / timevomit)	//and you have 10 more for mad dash to the bucket
				Stun(3)
				var/obj/item/organ/internal/stomach/stomach = internal_organs_by_name[BP_STOMACH]
				if(!istype(stomach))
					custom_emote(VISIBLE_MESSAGE, "dry heaves.", "AUTO_EMOTE")
				else if(!(nutrition > STOMACH_FULLNESS_SUPER_LOW))
					custom_emote(VISIBLE_MESSAGE, "dry heaves.", "AUTO_EMOTE")
				else
					// Actual stomach contents
					for(var/a in stomach.processing)
						if(prob(20))
							continue // Something may remain
						var/atom/movable/A = a
						if(A == stomach.currently_processing)
							continue // Gripping tight on whatever we're processing right now
						A.forceMove(get_turf(src))
						stomach.processing.Remove(a)
					stomach.recalc_items_volume()

					src.visible_message("<span class='warning'>[src] throws up!</span>","<span class='warning'>You throw up!</span>")
					playsound(loc, 'sound/effects/splat.ogg', 50, 1)

					remove_nutrition(10.0)
					remove_hydration(rand(50, 200))
		sleep(350)	//wait 35 seconds before next volley
		lastpuke = 0

/mob/living/carbon/human/proc/remotesay()
	set name = "Project mind"
	set category = "Superpower"

	if(stat!=CONSCIOUS)
		reset_view(0)
		remoteview_target = null
		return

	if(!(mRemotetalk in src.mutations))
		src.verbs -= /mob/living/carbon/human/proc/remotesay
		return
	var/list/creatures = list()
	for(var/mob/living/carbon/h in world)
		creatures += h
	var/mob/target = input("Who do you want to project your mind to ?") as null|anything in creatures
	if (QDELETED(target))
		return

	var/say = sanitize(input("What do you wish to say"))
	if(mRemotetalk in target.mutations)
		target.show_message("<span class='notice'>You hear [src.real_name]'s voice: [say]</span>")
	else
		target.show_message("<span class='notice'>You hear a voice that seems to echo around the room: [say]</span>")
	usr.show_message("<span class='notice'>You project your mind into [target.real_name]: [say]</span>")
	log_say("[key_name(usr)] sent a telepathic message to [key_name(target)]: [say]")
	for(var/mob/observer/ghost/G in world)
		G.show_message("<i>Telepathic message from <b>[src]</b> to <b>[target]</b>: [say]</i>")

/atom/proc/get_visible_gender()
	return gender

/mob/living/carbon/human/get_visible_gender()
	if(wear_suit && wear_suit.flags_inv & HIDEJUMPSUIT && ((head && head.flags_inv & HIDEMASK) || wear_mask))
		return NEUTER
	return ..()

/mob/living/carbon/human/revive(ignore_prosthetic_prefs = FALSE)
	species.create_organs(src) // Reset our organs/limbs.

	if(!client || !key) //Don't boot out anyone already in the mob.
		for(var/obj/item/organ/internal/cerebrum/brain/H in world)
			if(H.brainmob)
				if(H.brainmob.real_name == real_name)
					if(H.brainmob.mind)
						H.brainmob.mind.transfer_to(src)
						qdel(H)

	losebreath = 0

	..()

/mob/living/carbon/human/proc/is_lung_ruptured()
	var/obj/item/organ/internal/lungs/L = internal_organs_by_name[BP_LUNGS]
	return L && L.is_bruised()

/mob/living/carbon/human/add_blood(source)
	. = ..()
	if(!.)
		return

	//if this blood isn't already in the list, add it
	if(ishuman(source))
		var/mob/living/carbon/human/M = source
		if(!blood_DNA[M.dna.unique_enzymes])
			blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	hand_blood_color = blood_color
	update_inv_gloves(1) // handles bloody hands overlays and updating

	verbs += /mob/living/carbon/human/proc/bloody_doodle

/mob/living/carbon/human/clean_blood(clean_feet)
	. =..()
	if(!.)
		return

	gunshot_residue = null

	if(clean_feet && !shoes)
		track_blood = 0
		feet_blood_color = null
		feet_blood_DNA = null
		update_inv_shoes(1)

	if(gloves)
		if(gloves.clean_blood())
			update_inv_gloves(0)
	else
		if(!isnull(bloody_hands))
			bloody_hands = null
			update_inv_gloves(0)
	update_icons()	//apply the now updated overlays to the mob

/mob/living/carbon/human/get_embedded_objects(class = 0)
	var/list/embedded_objects = ..()

	for(var/obj/item/organ/external/organ in external_organs)
		for(var/obj/O in organ.embedded_objects)
			if((O.w_class <= class) || istype(O,/obj/item/material/shard/shrapnel))
				continue
			embedded_objects += O

	return embedded_objects

/mob/living/carbon/human/verb/check_pulse()
	set category = "Object"
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = 0

	if(usr.stat || usr.restrained() || !isliving(usr) || !ishuman(usr)) return

	if(usr == src)
		self = 1
	if(!self)
		usr.visible_message("<span class='notice'>[usr] kneels down, puts \his hand on [src]'s wrist and begins counting their pulse.</span>",\
		"You begin counting [src]'s pulse")
	else
		usr.visible_message("<span class='notice'>[usr] begins counting their pulse.</span>",\
		"You begin counting your pulse.")

	if(pulse())
		to_chat(usr, "<span class='notice'>[self ? "You have a" : "[src] has a"] pulse! Counting...</span>")
	else
		to_chat(usr, "<span class='danger'>[src] has no pulse!</span>")//it is REALLY UNLIKELY that a dead person would check his own pulse
		return

	to_chat(usr, "You must[self ? "" : " both"] remain still until counting is finished.")
	if(do_mob(usr, src, 60))
		var/message = "<span class='notice'>[self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)].</span>"
		to_chat(usr, message)
	else
		to_chat(usr, "<span class='warning'>You failed to check the pulse. Try again.</span>")

/mob/living/carbon/human/verb/lookup()
	set name = "Look up"
	set desc = "If you want to know what's above."
	set category = "IC"

	if(!is_physically_disabled())
		var/turf/above = GetAbove(src)
		if(shadow)
			if(client.eye == shadow)
				reset_view(0)
				return
			if(istype(above, /turf/simulated/open))
				to_chat(src, "<span class='notice'>You look up.</span>")
				if(client)
					reset_view(shadow)
				return
		to_chat(src, "<span class='notice'>You can see \the [above].</span>")
	else
		to_chat(src, "<span class='notice'>You can't look up right now.</span>")
	return

/mob/living/carbon/human/set_species(new_species, default_colour)
	if(!dna)
		if(!new_species)
			new_species = SPECIES_HUMAN
	else
		if(!new_species)
			new_species = dna.species
		else
			dna.species = new_species

	// No more invisible screaming wheelchairs because of set_species() typos.
	if(!all_species[new_species])
		new_species = SPECIES_HUMAN

	if(species)

		if(species.name && species.name == new_species)
			return
		if(species.language)
			remove_language(species.language)
		if(species.icon_scale != 1 || species.y_shift)
			update_transform()
		if(species.default_language)
			remove_language(species.default_language)
		for(var/datum/language/L in species.assisted_langs)
			remove_language(L)
		// Clear out their species abilities.
		species.on_species_loss(src)
		holder_type = null

	species = all_species[new_species]
	species.handle_pre_spawn(src)

	fix_body_build()

	if(species.language)
		add_language(species.language)
		species_language = all_languages[species.language]

	for(var/L in species.additional_langs)
		add_language(L)

	if(species.default_language)
		add_language(species.default_language)

	if(species.grab_type)
		current_grab_type = all_grabobjects[species.grab_type]

	if(species.base_color && default_colour)
		//Apply colour.
		r_skin = hex2num(copytext(species.base_color,2,4))
		g_skin = hex2num(copytext(species.base_color,4,6))
		b_skin = hex2num(copytext(species.base_color,6,8))
	else
		r_skin = 0
		g_skin = 0
		b_skin = 0

	if(default_colour || !(species.species_appearance_flags & HAS_EYE_COLOR))
		r_eyes = hex2num(copytext(species.default_eye_color, 2, 4))
		g_eyes = hex2num(copytext(species.default_eye_color, 4, 6))
		b_eyes = hex2num(copytext(species.default_eye_color, 6, 8))

	if(species.holder_type)
		holder_type = species.holder_type

	if(!(gender in species.genders))
		gender = species.genders[1]

	icon_state = lowertext(species.name)

	species.create_organs(src)
	species.handle_post_spawn(src)

	maxHealth = species.total_health

	default_pixel_x = initial(pixel_x) + species.pixel_offset_x
	default_pixel_y = initial(pixel_y) + species.pixel_offset_y
	pixel_x = default_pixel_x
	pixel_y = default_pixel_y

	spawn(0)
		regenerate_icons()

	// Rebuild the HUD. If they aren't logged in then login() should reinstantiate it for them.
	if(client)
		Login()

	//recheck species-restricted clothing
	for(var/slot in slot_first to slot_last)
		var/obj/item/C = get_equipped_item(slot)
		if(istype(C) && !C.mob_can_equip(src, slot, 1))
			drop(C, force = TRUE)

	return 1

/mob/living/carbon/human/proc/fix_body_build()
	if(body_build && (gender in body_build.genders) && (body_build in species.body_builds))
		return 1
	for(var/datum/body_build/BB in species.body_builds)
		if(gender in BB.genders)
			change_body_build(BB)
			return 1
	to_world_log("Can't find possible body_build. Gender = [gender], Species = [species]")
	return 0

/mob/living/carbon/human/proc/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if (src.stat)
		return

	if (usr != src)
		return 0 //something is terribly wrong

	if (!bloody_hands)
		verbs -= /mob/living/carbon/human/proc/bloody_doodle

	if (src.gloves)
		to_chat(src, "<span class='warning'>Your [src.gloves] are getting in the way.</span>")
		return

	var/turf/simulated/T = src.loc
	if (!istype(T)) //to prevent doodling out of mechs and lockers
		to_chat(src, "<span class='warning'>You cannot reach the floor.</span>")
		return

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	if (direction != "Here")
		T = get_step(T,text2dir(direction))
	if (!istype(T))
		to_chat(src, "<span class='warning'>You cannot doodle there.</span>")
		return

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		to_chat(src, "<span class='warning'>There is no space to write on!</span>")
		return

	var/max_length = bloody_hands * 30 //tweeter style

	var/message = sanitize(input("Write a message. It cannot be longer than [max_length] characters.","Blood writing", ""))

	if (message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if (length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")
		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.basecolor = (hand_blood_color) ? hand_blood_color : COLOR_BLOOD_HUMAN
		W.update_icon()
		W.message = message
		W.add_fingerprint(src)

#define CAN_INJECT 1
#define INJECTION_PORT 2
/mob/living/carbon/human/can_inject(mob/user, target_zone)
	var/obj/item/organ/external/affecting = get_organ(target_zone)

	if(!affecting)
		to_chat(user, "<span class='warning'>They are missing that limb.</span>")
		return 0

	. = CAN_INJECT
	for(var/obj/item/clothing/C in list(head, wear_mask, wear_suit, w_uniform, gloves, shoes))
		if(C && (C.body_parts_covered & affecting.body_part) && (C.item_flags & ITEM_FLAG_THICKMATERIAL))
			if(istype(C, /obj/item/clothing/suit/space))
				. = INJECTION_PORT //it was going to block us, but it's a space suit so it doesn't because it has some kind of port
			else
				to_chat(user, "<span class='warning'>There is no exposed flesh or thin material on [src]'s [affecting.name] to inject into.</span>")
				return 0


/mob/living/carbon/human/print_flavor_text(shrink = 1)
	var/list/equipment = list(head, wear_mask, glasses, w_uniform, wear_suit, gloves, shoes)
	var/head_exposed = TRUE
	var/face_exposed = TRUE
	var/eyes_exposed = TRUE
	var/torso_exposed = TRUE
	var/arms_exposed = TRUE
	var/legs_exposed = TRUE
	var/hands_exposed = TRUE
	var/feet_exposed = TRUE

	if(!has_intact_limb(BP_L_ARM) && !has_intact_limb(BP_R_ARM))
		arms_exposed = FALSE
		hands_exposed = FALSE //No need to check for hands if it has no arms

	if(hands_exposed && !has_intact_limb(BP_L_HAND) && !has_intact_limb(BP_R_HAND))
		hands_exposed = FALSE

	if(!has_intact_limb(BP_L_LEG) && !has_intact_limb(BP_R_LEG))
		legs_exposed = FALSE
		feet_exposed = FALSE

	if(feet_exposed && !has_intact_limb(BP_L_FOOT) && !has_intact_limb(BP_R_FOOT))
		feet_exposed = FALSE

	if(!has_intact_limb(BP_HEAD))
		head_exposed = FALSE
		face_exposed = FALSE
		eyes_exposed = FALSE

	for(var/obj/item/clothing/C in equipment)
		if(C.body_parts_covered & HEAD)
			head_exposed = FALSE
		if(C.body_parts_covered & FACE)
			face_exposed = FALSE
		if(C.body_parts_covered & EYES)
			eyes_exposed = FALSE
		if(C.body_parts_covered & UPPER_TORSO)
			torso_exposed = FALSE
		if(arms_exposed && C.body_parts_covered & ARMS)
			arms_exposed = FALSE
		if(hands_exposed && C.body_parts_covered & HANDS)
			hands_exposed = FALSE
		if(legs_exposed && C.body_parts_covered & LEGS)
			legs_exposed = FALSE
		if(feet_exposed && C.body_parts_covered & FEET)
			feet_exposed = FALSE

	flavor_text = ""
	for (var/T in flavor_texts)
		if(flavor_texts[T] && flavor_texts[T] != "")
			if((T == "general") || (T == "head" && head_exposed) || (T == "face" && face_exposed) || (T == "eyes" && eyes_exposed) || (T == "torso" && torso_exposed) || (T == "arms" && arms_exposed) || (T == "hands" && hands_exposed) || (T == "legs" && legs_exposed) || (T == "feet" && feet_exposed) || (T == "action" && !is_ic_dead()))
				flavor_text += flavor_texts[T]
				flavor_text += "\n\n"
	if(!shrink)
		return flavor_text
	else
		return ..()

/mob/living/carbon/human/getDNA()
	if(species.species_flags & SPECIES_FLAG_NO_SCAN)
		return null
	..()

/mob/living/carbon/human/setDNA()
	if(species.species_flags & SPECIES_FLAG_NO_SCAN)
		return
	..()

/mob/living/carbon/human/has_brain()
	if(internal_organs_by_name[BP_BRAIN])
		var/obj/item/organ/internal/cerebrum/brain = internal_organs_by_name[BP_BRAIN]
		if(brain && istype(brain))
			return 1
	return 0

/mob/living/carbon/human/has_eyes()
	if(internal_organs_by_name[BP_EYES])
		var/obj/item/organ/internal/eyes = internal_organs_by_name[BP_EYES]
		if(eyes && eyes.is_usable())
			return 1
	return 0

/mob/living/carbon/human/slip(slipped_on, stun_duration = 8)
	. = ..()
	if(.)
		damage_poise(stun_duration*5)

/mob/living/carbon/human/proc/undislocate()
	set category = "Object"
	set name = "Undislocate Joint"
	set desc = "Pop a joint back into place. Extremely painful."
	set src in view(1)

	if(!isliving(usr) || !usr.canClick())
		return

	usr.setClickCooldown(20)

	if(usr.stat > 0)
		to_chat(usr, "You are unconcious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/mob/S = src
	var/mob/U = usr
	var/self = null
	if(S == U)
		self = 1 // Removing object from yourself.

	var/list/limbs = list()
	for(var/limb in external_organs_by_name)
		var/obj/item/organ/external/current_limb = external_organs_by_name[limb]
		if(current_limb && current_limb.dislocated > 0 && !current_limb.is_parent_dislocated()) //if the parent is also dislocated you will have to relocate that first
			limbs |= current_limb
	var/obj/item/organ/external/current_limb = input(usr,"Which joint do you wish to relocate?") as null|anything in limbs

	if(!current_limb)
		return

	if(self)
		to_chat(src, "<span class='warning'>You brace yourself to relocate your [current_limb.joint]...</span>")
	else
		to_chat(U, "<span class='warning'>You begin to relocate [S]'s [current_limb.joint]...</span>")
	if(!do_after(U, 30, src))
		return
	if(!current_limb || !S || !U)
		return

	if(self)
		to_chat(src, "<span class='danger'>You pop your [current_limb.joint] back in!</span>")
	else
		to_chat(U, "<span class='danger'>You pop [S]'s [current_limb.joint] back in!</span>")
		to_chat(S, "<span class='danger'>[U] pops your [current_limb.joint] back in!</span>")
	current_limb.undislocate()

/mob/living/carbon/human/drop(obj/item/W, atom/Target = null, force = null, changing_slots)
	if(W in external_organs)
		return
	. = ..()

/mob/living/carbon/human/reset_view(atom/A, update_hud = 1)
	..()
	if(update_hud)
		handle_regular_hud_updates()


/mob/living/carbon/human/can_stand_overridden()
	return 0

/mob/living/carbon/human/verb/pull_punches()
	set name = "Pull Punches"
	set desc = "Try not to hurt them."
	set category = "IC"

	if(incapacitated() || species.species_flags & SPECIES_FLAG_CAN_NAB) return
	pulling_punches = !pulling_punches
	to_chat(src, "<span class='notice'>You are now [pulling_punches ? "pulling your punches" : "not pulling your punches"].</span>")
	return

// Similar to get_pulse, but returns only integer numbers instead of text.
// TODO[V] Please adjust get_pulse() proc to be used here
/mob/living/carbon/human/proc/get_pulse_as_number()
	var/obj/item/organ/internal/heart/heart_organ = internal_organs_by_name[BP_HEART]
	if(!heart_organ)
		return 0

	switch(pulse())
		if(PULSE_NONE)
			return 0
		if(PULSE_SLOW)
			return rand(40, 60)
		if(PULSE_NORM)
			return rand(60, 90)
		if(PULSE_FAST)
			return rand(90, 120)
		if(PULSE_2FAST)
			return rand(120, 160)
		if(PULSE_THREADY)
			return 250
	return 0

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/human/proc/get_pulse(method)	//method 0 is for hands, 1 is for machines, more accurate
	var/obj/item/organ/internal/heart/H = internal_organs_by_name[BP_HEART]
	if(!H)
		return
	if(H.open && !method)
		return "muddled and unclear; you can't seem to find a vein"

	var/temp = 0
	switch(pulse())
		if(PULSE_NONE)
			return "0"
		if(PULSE_SLOW)
			temp = rand(40, 60)
		if(PULSE_NORM)
			temp = rand(60, 90)
		if(PULSE_FAST)
			temp = rand(90, 120)
		if(PULSE_2FAST)
			temp = rand(120, 160)
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
	return "[method ? temp : temp + rand(-10, 10)]"
//			output for machines^	^^^^^^^output for people^^^^^^^^^

/mob/living/carbon/human/proc/pulse()
	var/obj/item/organ/internal/heart/H = internal_organs_by_name[BP_HEART]
	if(!H)
		return PULSE_NONE
	else
		return H.pulse

/mob/living/carbon/human/can_devour(atom/movable/victim)
	if(!src.species.gluttonous)
		return FALSE
	var/total = 0
	for(var/a in victim)
		if(ismob(a))
			var/mob/M = a
			total += M.mob_size
		else if(isobj(a))
			var/obj/item/I = a
			total += I.get_storage_cost()
	if(total > src.species.stomach_capacity)
		return FALSE

	if(iscarbon(victim))
		var/mob/living/L = victim
		if((src.species.gluttonous & GLUT_TINY) && (L.mob_size <= MOB_TINY) && !ishuman(victim)) // Anything MOB_TINY or smaller
			return DEVOUR_SLOW
		else if((src.species.gluttonous & GLUT_SMALLER) && (src.mob_size > L.mob_size)) // Anything we're larger than
			return DEVOUR_SLOW
		else if(src.species.gluttonous & GLUT_ANYTHING) // Eat anything ever
			return DEVOUR_FAST
	else if(istype(victim, /obj/item) && !istype(victim, /obj/item/holder)) //Don't eat holders. They are special.
		var/obj/item/I = victim
		var/cost = I.get_storage_cost()
		if(cost != ITEM_SIZE_NO_CONTAINER)
			if((src.species.gluttonous & GLUT_ITEM_TINY) && cost < 4)
				return DEVOUR_SLOW
			else if((src.species.gluttonous & GLUT_ITEM_NORMAL) && cost <= 4)
				return DEVOUR_SLOW
			else if(src.species.gluttonous & GLUT_ITEM_ANYTHING)
				return DEVOUR_FAST
	return ..()

/mob/living/carbon/human/should_have_organ(organ_check)
	return (species && species.has_organ[organ_check])

/mob/living/carbon/human/has_limb(limb_check)	//returns 1 if found, 2 if limb is robotic, 0 if not found and null if its chest or groin (dont pass those)

	if (limb_check == BP_CHEST || limb_check == BP_GROIN)	//obviously doesnt work with them
		return

	var/obj/item/organ/external/limb
	limb = external_organs_by_name[limb_check]

	if(limb && !limb.is_stump())
		return 1
	return 0

/// Basically the same as before, but also checks whether limb is FUBAR
/mob/living/carbon/human/proc/has_intact_limb(limb_check)
	if(limb_check == BP_CHEST || limb_check == BP_GROIN)
		return

	var/obj/item/organ/external/limb
	limb = external_organs_by_name[limb_check]

	if(limb && !limb.is_stump() && !(limb.status & ORGAN_DISFIGURED))
		return 1
	return 0

/mob/living/carbon/human/can_feel_pain(obj/item/organ/check_organ)
	if(no_pain)
		return 0
		// TODO [V] Remove this dirty hack
	if(check_organ)
		if(!istype(check_organ))
			return 0
		return check_organ.can_feel_pain()
	return !(species.species_flags & SPECIES_FLAG_NO_PAIN)

/mob/living/carbon/human/need_breathe()
	if(species.breathing_organ && should_have_organ(species.breathing_organ))
		if(does_not_breathe == 0)
			return 1
		else
			return 0

/mob/living/carbon/human/get_adjusted_metabolism(metabolism)
	. = ..(metabolism)
	for(var/datum/modifier/mod in modifiers)
		if(!isnull(mod.metabolism_percent))
			. *= mod.metabolism_percent
	. *= (species ? species.metabolism_mod : 1)

/mob/living/carbon/human/is_invisible_to(mob/viewer)
	return (is_cloaked() || ..())

/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if(src != M)
		..()
	else
		visible_message( \
			"<span class='notice'>[src] examines [gender==MALE ? "himself" : "herself"].</span>", \
			"<span class='notice'>You check yourself for injuries.</span>" \
			)

		for(var/obj/item/organ/external/org in external_organs)
			var/list/status = list()

			var/feels = 1 + round(org.get_pain()/100, 0.1)
			var/brutedamage = org.brute_dam * feels
			var/burndamage = org.burn_dam * feels

			switch(brutedamage)
				if(1 to 20)
					status += "bruised"
				if(20 to 40)
					status += "wounded"
				if(40 to INFINITY)
					status += "mangled"

			switch(burndamage)
				if(1 to 10)
					status += "numb"
				if(10 to 40)
					status += "blistered"
				if(40 to INFINITY)
					status += "peeling away"

			if(org.is_stump())
				status += "MISSING"
			if(org.status & ORGAN_MUTATED)
				status += "misshapen"
			if(org.dislocated == 2)
				status += "dislocated"
			if(org.status & ORGAN_BROKEN)
				status += "hurts when touched"
			if(org.status & ORGAN_DEAD)
				status += "is bruised and necrotic"
			if(!org.is_usable() || org.is_dislocated())
				status += "dangling uselessly"
			if(status.len)
				src.show_message("My [org.name] is <span class='warning'>[english_list(status)].</span>",1)
			else
				src.show_message("My [org.name] is <span class='notice'>OK.</span>",1)

		if((MUTATION_SKELETON in mutations) && (!w_uniform) && (!wear_suit))
			play_xylophone()

/mob/living/carbon/human/proc/resuscitate()
	if(!is_asystole() || !should_have_organ(BP_HEART))
		return
	var/obj/item/organ/internal/heart/heart = internal_organs_by_name[BP_HEART]
	if(istype(heart) && !(heart.status & ORGAN_DEAD))
		var/species_organ = species.breathing_organ
		var/active_breaths = 0
		if(species_organ)
			var/obj/item/organ/internal/lungs/L = internal_organs_by_name[species_organ]
			if(L)
				active_breaths = L.active_breathing
		if(!nervous_system_failure() && active_breaths)
			visible_message("<b>\The [src]</b> jerks and gasps for breath!")
		else
			visible_message("<b>\The [src]</b> twitches a bit as \his heart restarts!")
		shock_stage = min(shock_stage, 100) // 120 is the point at which the heart stops.
		if(getOxyLoss() >= 75)
			setOxyLoss(75)
		heart.pulse = PULSE_NORM

//Determine body temperature
/mob/living/carbon/human/proc/get_body_temperature()
	return bodytemperature

//Point at which you dun breathe no more. Separate from asystole crit, which is heart-related.
/mob/living/carbon/human/nervous_system_failure()
	return getBrainLoss() >= maxHealth * 0.8 // > than 80 brain dmg - ur rekt

/mob/living/carbon/human/verb/useblock()
	set name = "Block"
	set desc = "Get into a defensive stance, effectively blocking the next attack."
	set category = "IC"

	if(!incapacitated(INCAPACITATION_KNOCKOUT) && canClick())
		setClickCooldown(3)
		if(!weakened && !stunned)
			if(!blocking)
				src.useblock_on()
				to_chat(src, "<span class='notice'>You prepare for blocking!</span>")
			else
				src.useblock_off()
				to_chat(src, "<span class='notice'>You lower your defence.</span>")

/mob/living/carbon/human/proc/useblock_off()
	src.setClickCooldown(3)
	src.blocking = 0
	remove_movespeed_modifier(/datum/movespeed_modifier/blocking)
	if(src.block_icon) //in case we don't have the HUD and we use the hotkey
		src.block_icon.icon_state = "act_block0"

/mob/living/carbon/human/proc/useblock_on()
	src.blocking = 1
	add_movespeed_modifier(/datum/movespeed_modifier/blocking)
	if(src.block_icon) //in case we don't have the HUD and we use the hotkey
		src.block_icon.icon_state = "act_block1"


/mob/living/carbon/human/verb/toggle_aim_assist()
	set name = "Toggle Click Mode"
	set desc = "Choose whether to click on anything or mobs only."
	set category = "IC"

	if(!aim_assist)
		aim_assist = TRUE
		to_chat(src, SPAN("notice", "You will now prioritize mobs when clicking."))
		if(aim_assist_icon)
			aim_assist_icon.icon_state = "aim_assist1"
	else
		aim_assist = FALSE
		to_chat(src, SPAN("notice", "You will now click on things normally."))
		if(aim_assist_icon)
			aim_assist_icon.icon_state = "aim_assist0"

/mob/living/carbon/human/proc/verb_toggle_twohanded_mode()
	set name = "Toggle Two-Handed Mode"
	set desc = "Choose whether your RMB clicks things with offhand or acts normally."
	set category = "IC"

	toggle_twohanded_mode()

/mob/living/carbon/human/proc/toggle_twohanded_mode(new_state = -1, silent = FALSE)
	twohanded_mode = (new_state == -1) ? !twohanded_mode : new_state

	if(twohanded_mode)
		if(!silent)
			to_chat(src, SPAN("notice", "Your can now use your offhand via right-clicking."))
		if(twohanded_mode_icon)
			twohanded_mode_icon.icon_state = "act_twohanded1"
	else
		if(!silent)
			to_chat(src, SPAN("notice", "You will no longer use your offhand via right-clicking."))
		if(twohanded_mode_icon)
			twohanded_mode_icon.icon_state = "act_twohanded0"

	if(my_client)
		winset(my_client, "mapwindow.rightclickblocker", "is-visible=[twohanded_mode ? "true" : "false"]") // Please, forgive me for this abomination, but I can't think of a faster, mostly-client-sided way to preserve Shift, Ctrl and Alt macros' behavior.
		winset(my_client, "mapwindow.map", "right-click=[twohanded_mode ? "true" : "false"]")

/mob/living/carbon/human/verb/succumb()
	set hidden = 1

	if(internal_organs_by_name[BP_BRAIN])
		var/obj/item/organ/internal/cerebrum/brain/brain = internal_organs_by_name[BP_BRAIN]
		if(!brain.is_broken() || stat != UNCONSCIOUS)
			return

		to_chat(src, SPAN("notice", "You have given up life and succumbed to death."))
		log_and_message_admins("has succumbed")
		adjustBrainLoss(brain.max_damage)
		update_health()

/mob/living/carbon/human/verb/remove_underwear()
	set name = "Remove Underwear"
	set category = "IC"

	if(!show_inv(src, TRUE))
		return

	usr.show_inventory?.open()

/mob/living/carbon/human/get_runechat_color()
	return species.get_species_runechat_color(src)

/mob/living/carbon/human/lay_down()
	if(crawling && canClick())
		var/obj/structure/table/T = locate() in loc.contents
		if(!istype(T))
			..()
			return

		T.headbumped(src)
		return

	..()
	return
