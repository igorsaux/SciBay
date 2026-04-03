#define HEAT_CAPACITY_HUMAN 100 //249840 J/K, for a 72 kg person.

/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi' // map only
	icon_state = "pod_preview"
	density = 1
	anchored = 1.0
	interact_offline = 1
	layer = ABOVE_HUMAN_LAYER // this needs to be fairly high so it displays over most things, but it needs to be under lighting

	var/on = 0
	clicksound = 'sound/machines/buttonbeep.ogg'
	clickvol = 30

	var/temperature_archived
	var/mob/living/carbon/human/occupant = null
	var/obj/item/reagent_containers/vessel/beaker = null

	var/current_heat_capacity = 50

	var/ejecting = 0
	var/biochemical_stasis = 0
	var/datum/sound_token/cryo_sound_token = null

	component_types = list(
		/obj/item/circuitboard/cryo_cell,
		/obj/item/stock_parts/scanning_module,
		/obj/item/stock_parts/matter_bin,
		/obj/item/stock_parts/manipulator = 3,
		/obj/item/stock_parts/console_screen
	)

	beepsounds = list(
		'sound/effects/machinery/medical/beep1.ogg',
		'sound/effects/machinery/medical/beep2.ogg',
		'sound/effects/machinery/medical/beep3.ogg',
		'sound/effects/machinery/medical/beep4.ogg',
		'sound/effects/machinery/medical/beep5.ogg',
		'sound/effects/machinery/medical/beep6.ogg'
	)

/obj/machinery/atmospherics/unary/cryo_cell/Initialize()
	. = ..()
	icon = 'icons/obj/cryogenics_split.dmi'
	update_icon()

	RefreshParts()
	atmos_init()
	if(on)
		start_operating_sound()

/obj/machinery/atmospherics/unary/cryo_cell/Destroy()
	stop_operating_sound()
	var/turf/T = loc
	T.contents += contents
	if(beaker)
		beaker.forceMove(get_step(loc, SOUTH)) //Beaker is carefully ejected from the wreckage of the cryotube
		beaker = null
	if(occupant)
		occupant.forceMove(get_step(loc, SOUTH))
		occupant = null
	. = ..()

/obj/machinery/atmospherics/unary/cryo_cell/atmos_init()
	..()
	if(node)
		return
	var/node_connect = dir
	for(var/obj/machinery/atmospherics/target in get_step(src, node_connect))
		if(target.initialize_directions & get_dir(target, src))
			node = target
			break

/obj/machinery/atmospherics/unary/cryo_cell/examine(mob/user, infix)
	. = ..()

	if(!user.Adjacent(src))
		return

	if(beaker)
		. += "It is loaded with a beaker."
	if(emagged)
		. += "The panel is loose and the circuitry is charred."

/obj/machinery/atmospherics/unary/cryo_cell/Process()
	if(stat & (BROKEN|NOPOWER))
		stop_operating_sound()
		update_icon()
	..()
	if(!node)
		return
	if(!on)
		return

	play_beep()

	if(occupant)
		if(!occupant.is_ic_dead())
			THROTTLE(icon_update_cooldown, 3 SECONDS)
			if(icon_update_cooldown)
				update_icon()
			process_occupant()

	if(air_contents)
		temperature_archived = air_contents.temperature
		heat_gas_contents()
		if(occupant && iscarbon(occupant) && !occupant.is_ic_dead() && !occupant.is_asystole() && !occupant.losebreath)
			expel_gas()

	if(abs(temperature_archived-air_contents.temperature) > 1)
		network.update = 1

	return 1

/obj/machinery/atmospherics/unary/cryo_cell/relaymove(mob/user) // note that relaymove will also be called for mobs outside the cell with UI open
	if(occupant == user && !user.stat)
		go_out()

/obj/machinery/atmospherics/unary/cryo_cell/OnTopic(user, href_list)
	if(user == occupant)
		return STATUS_CLOSE

	if(href_list["switchOn"])
		on = 1
		update_icon()
		start_operating_sound()
		return TOPIC_REFRESH

	if(href_list["switchOff"])
		on = 0
		update_icon()
		stop_operating_sound()
		return TOPIC_REFRESH

	if(href_list["ejectBeaker"])
		if(beaker)
			beaker.forceMove(get_step(loc, SOUTH))
			beaker = null
		return TOPIC_REFRESH

	if(href_list["ejectOccupant"])
		if(!occupant)
			return TOPIC_HANDLED // don't update UIs attached to this object
		go_out()
		return TOPIC_REFRESH

	if(href_list["biochemicalStasisOn"])
		biochemical_stasis = 1
		update_icon()
		return TOPIC_REFRESH

	if(href_list["biochemicalStasisOff"])
		biochemical_stasis = 0
		update_icon()
		return TOPIC_REFRESH

/obj/machinery/atmospherics/unary/cryo_cell/proc/start_operating_sound()
	if(cryo_sound_token)
		return
	var/sound_id = "\ref[src]_cryo"
	cryo_sound_token = GLOB.sound_player.PlayLoopingSound(src, sound_id, 'sound/effects/machinery/medical/cryo_ambient.ogg', volume = 15, range = 7, falloff = 3)

/obj/machinery/atmospherics/unary/cryo_cell/proc/stop_operating_sound()
	if(!cryo_sound_token)
		return
	cryo_sound_token.Stop()
	cryo_sound_token = null

/obj/machinery/atmospherics/unary/cryo_cell/attackby(obj/G, mob/user as mob)
	if(default_deconstruction_screwdriver(user, G))
		return
	if(default_deconstruction_crowbar(user, G))
		return
	if(default_part_replacement(user, G))
		return
	if(istype(G, /obj/item/reagent_containers/vessel))
		if(beaker)
			to_chat(user, SPAN("warning", "A beaker is already loaded into the machine."))
			return
		if(!user.drop(G, src))
			return
		beaker = G
		user.visible_message("[user] adds \a [G] to \the [src]!", "You add \a [G] to \the [src]!")
	else if(istype(G, /obj/item/grab))
		if(!ismob(G:affecting))
			return

		user.visible_message(SPAN("notice", "\The [user] begins placing \the [G:affecting] into \the [src]."), SPAN("notice", "You start placing \the [G:affecting] into \the [src]."))
		if(!do_after(user, 30, src))
			return
		if(!ismob(G:affecting))
			return
		var/mob/M = G:affecting
		if(put_mob(M))
			qdel(G)
			user.visible_message(SPAN("notice", "\The [user] places \the [M] into \the [src]."), SPAN("notice", "You place \the [M] into \the [src]."))
	return

/obj/machinery/atmospherics/unary/cryo_cell/AltClick(mob/user)
	grab_container(user, &beaker, get_step(loc, SOUTH))

/obj/machinery/atmospherics/unary/cryo_cell/on_update_icon()
	ClearOverlays()
	var/overlays_state = 0
	if(stat & (BROKEN|NOPOWER))
		overlays_state = 0
	else
		overlays_state = !on ? 0 : biochemical_stasis ? 2 : 1

	icon_state = "pod[overlays_state]"
	var/image/I
	I = image(icon, "pod[overlays_state]_top")

	I.pixel_z = 32
	AddOverlays(I)

	if(occupant)
		occupant.update_damage_overlays()
		var/image/pickle = image(occupant.icon, occupant.icon_state)
		pickle.CopyOverlays(occupant)
		pickle.pixel_z = 18
		AddOverlays(pickle)

	I = image(icon, "lid[overlays_state]")
	AddOverlays(I)

	I = image(icon, "lid[overlays_state]_top")
	I.pixel_z = 32
	AddOverlays(I)

/obj/machinery/atmospherics/unary/cryo_cell/proc/process_occupant()
	return

/obj/machinery/atmospherics/unary/cryo_cell/proc/heat_gas_contents()
	if(air_contents.total_moles < 1)
		return
	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	if(combined_heat_capacity > 0)
		var/combined_energy = (20 CELSIUS) * current_heat_capacity + air_heat_capacity * air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity

/obj/machinery/atmospherics/unary/cryo_cell/proc/expel_gas()
	if(air_contents.total_moles < 1)
		return
	air_contents.remove(air_contents.total_moles/50)

/obj/machinery/atmospherics/unary/cryo_cell/proc/go_out(force_move=TRUE)
	if(!occupant)
		return
	//for(var/obj/O in src)
	//	O.loc = loc
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE

	if(force_move)
		occupant.forceMove(get_step(loc, SOUTH))	//this doesn't account for walls or anything, but i don't forsee that being a problem.

	if(occupant.bodytemperature < 261 && occupant.bodytemperature >= 70) //Patch by Aranclanos to stop people from taking burn damage after being ejected
		occupant.bodytemperature = 261									  // Changed to 70 from 140 by Zuhayr due to reoccurance of bug.
	occupant = null
	current_heat_capacity = initial(current_heat_capacity)
	update_icon()
	return
/obj/machinery/atmospherics/unary/cryo_cell/proc/put_mob(mob/living/carbon/M as mob)
	if (stat & (NOPOWER|BROKEN))
		to_chat(usr, SPAN("warning", "The cryo cell is not functioning."))
		return
	if (!istype(M))
		to_chat(usr, SPAN("danger", "The cryo cell cannot handle such a lifeform!"))
		return
	if (occupant)
		to_chat(usr, SPAN("danger", "The cryo cell is already occupied!"))
		return
	if (M.abiotic())
		to_chat(usr, SPAN("warning", "Subject may not have abiotic items on."))
		return
	if(!node)
		to_chat(usr, SPAN("warning", "The cell is not correctly connected to its pipe network!"))
		return
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.stop_pulling()
	M.forceMove(src)
	M.ExtinguishMob()
	if(!M.is_ic_dead() && air_contents.temperature <= 278)
		to_chat(M, SPAN("notice", "<b>You feel a cold liquid surround you. Your skin starts to freeze up.</b>"))
	occupant = M
	current_heat_capacity = HEAT_CAPACITY_HUMAN

	add_fingerprint(usr)
	occupant.update_icon()
	update_icon()
	return 1

/obj/machinery/atmospherics/unary/cryo_cell/proc/check_compatibility(mob/target, mob/user)
	if(!CanMouseDrop(target, user))
		return 0
	if (!istype(target))
		return 0
	if (target.buckled)
		to_chat(user, SPAN("warning", "Unbuckle the subject before attempting to move them."))
		return 0
	return 1

	//Like grab-putting, but for mouse-dropping.
/obj/machinery/atmospherics/unary/cryo_cell/MouseDrop_T(mob/target, mob/user)
	if(!check_compatibility(target, user))
		return
	user.visible_message(SPAN("notice", "\The [user] begins placing \the [target] into \the [src]."), SPAN("notice", "You start placing \the [target] into \the [src]."))
	if(!do_after(user, 30, src))
		return
	if(!check_compatibility(target, user))
		return
	put_mob(target)


/obj/machinery/atmospherics/unary/cryo_cell/verb/move_eject()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)
	if(usr == occupant)//If the user is inside the tube...
		if(usr.stat == 2 || ejecting)//and he's not dead or not trying already....
			return
		to_chat(usr, SPAN("notice", "Release sequence activated. This will take two minutes."))
		ejecting = 1
		if(do_after(occupant, 1200, src, needhand = 0, incapacitation_flags = 0) && (src || usr || occupant || (occupant == usr))) //Check if someone's released/replaced/bombed him already
			ejecting = 0
			go_out()//and release him from the eternal prison.
		ejecting = 0
	else
		if(usr.stat != 0)
			return
		go_out()
	add_fingerprint(usr)
	return

/obj/machinery/atmospherics/unary/cryo_cell/verb/move_inside()
	set name = "Move Inside"
	set category = "Object"
	set src in oview(1)

	if (usr.stat != 0)
		return
	put_mob(usr)
	return

/obj/machinery/atmospherics/unary/cryo_cell/return_air()
	if(on)
		return air_contents
	..()

//This proc literally only exists for cryo cells.
/atom/proc/return_air_for_internal_lifeform()
	return return_air()

/obj/machinery/atmospherics/unary/cryo_cell/return_air_for_internal_lifeform()
	//assume that the cryo cell has some kind of breath mask or something that
	//draws from the cryo tube's environment, instead of the cold internal air.
	if(loc)
		return loc.return_air()
	else
		return null

/datum/data/function/proc/reset()
	return

/datum/data/function/proc/r_input(href, href_list, mob/user as mob)
	return

/datum/data/function/proc/display()
	return
