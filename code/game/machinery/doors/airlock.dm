#define BOLTS_FINE 0
#define BOLTS_EXPOSED 1
#define BOLTS_CUT 2

#define DOOR_FAILURE -1
#define DOOR_IDLE 0
#define DOOR_OPENING 1
#define DOOR_CLOSING 2

/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/doorint.dmi'
	icon_state = "door_closed"

	explosion_resistance = 10

	anim_time_1 = 3
	anim_time_2 = 7
	anim_time_3 = 2

	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = 0 // if 1, this door can't be hacked by the AI
	var/electrified_until = 0			//World time when the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/main_power_lost_until = 0	 	//World time when main power is restored.
	var/backup_power_lost_until = -1	//World time when backup power is restored.
	var/next_beep_at = 0				//World time when we may next beep due to doors being blocked by mobs
	var/spawnPowerRestoreRunning = 0
	var/welded = null
	var/locked = 0
	var/lock_cut_state = BOLTS_FINE
	var/lights = 1 // bolt lights show by default
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/lockdownbyai = 0
	autoclose = 1
	var/assembly_type = /obj/structure/door_assembly
	var/mineral = null
	var/justzap = 0
	var/safe = 1
	normalspeed = 1
	var/obj/item/airlock_electronics/electronics = null
	var/hasShocked = 0 //Prevents multiple shocks from happening
	var/secured_wires = 0
	var/datum/wires/airlock/wires = null

	var/open_sound_powered = 'sound/machines/airlock/normal_open.ogg'
	var/open_sound_unpowered = 'sound/machines/airlock/force_open.ogg'
	var/open_failure_access_denied = 'sound/machines/airlock/error3.ogg'

	var/close_sound_powered = 'sound/machines/airlock/normal_close.ogg'
	var/close_sound_unpowered = 'sound/machines/airlock/force_close.ogg'
	var/close_failure_blocked = 'sound/machines/airlock/error1.ogg'

	var/bolts_rising = 'sound/machines/bolts_up.ogg'
	var/bolts_dropping = 'sound/machines/bolts_down.ogg'

	var/door_crush_damage = DOOR_CRUSH_DAMAGE

	var/_wifi_id
	var/datum/wifi/receiver/button/door/wifi_receiver
	var/obj/item/airlock_brace/brace = null

/obj/machinery/door/airlock/get_material()
	return get_material_by_name(mineral ? mineral : MATERIAL_STEEL)

/obj/machinery/door/airlock/Process()
	return PROCESS_KILL
/*
About the new airlock wires panel:
*	An airlock wire dialog can be accessed by the normal way or by using wirecutters or a multitool on the door while the wire-panel is open. This would show the following wires, which you can either wirecut/mend or send a multitool pulse through. There are 9 wires.
*		one wire from the ID scanner. Sending a pulse through this flashes the red light on the door (if the door has power). If you cut this wire, the door will stop recognizing valid IDs. (If the door has 0000 access, it still opens and closes, though)
*		two wires for power. Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter). Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be open, but bolts-raising will not work. Cutting these wires may electrocute the user.
*		one wire for door bolts. Sending a pulse through this drops door bolts (whether the door is powered or not) or raises them (if it is). Cutting this wire also drops the door bolts, and mending it does not raise them. If the wire is cut, trying to raise the door bolts will not work.
*		two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter). Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
*		one wire for opening the door. Sending a pulse through this while the door has power makes it open the door if no access is required.
*		one wire for AI control. Sending a pulse through this blocks AI control for a second or so (which is enough to see the AI control light on the panel dialog go off and back on again). Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
*		one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds. Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted. (Currently it is also STAYING electrified until someone mends the wire)
*		one wire for controling door safetys.  When active, door does not close on someone.  When cut, door will ruin someone's shit.  When pulsed, door will immedately ruin someone's shit.
*		one wire for controlling door speed.  When active, dor closes at normal rate.  When cut, door does not close manually.  When pulsed, door attempts to close every tick.
*/

/obj/machinery/door/airlock/bumpopen(mob/living/simple_animal/user)
	..(user)

/obj/machinery/door/airlock/requiresID()
	return TRUE

/obj/machinery/door/airlock/proc/set_idscan(activate, feedback = 0)
	var/message = ""
	if(activate && aiDisabledIdScanner)
		aiDisabledIdScanner = 0
		message = "IdScan feature has been enabled."
	else if(!activate && !aiDisabledIdScanner)
		aiDisabledIdScanner = 1
		message = "IdScan feature has been disabled."

	if(feedback && message)
		to_chat(usr, message)

/obj/machinery/door/airlock/on_update_icon(keep_light = 0)
	if(!keep_light)
		set_light(0)
	ClearOverlays()

	if(operating > DOOR_IDLE)
		ImmediateOverlayUpdate()
		return

	if(density)
		if(locked && lights)
			icon_state = "door_locked"
			AddOverlays(OVERLAY(icon, "lights_bolts", dir = src.dir))
			AddOverlays(emissive_appearance(icon, "lights_bolts_ea"))
			set_light(0.35, 0.9, 1.5, 3, COLOR_RED_LIGHT)
		else
			icon_state = "door_closed"

		if(p_open || welded)
			if(p_open)
				AddOverlays(OVERLAY(icon, "panel_open", dir = src.dir))
			if(!(stat & NOPOWER))
				if(stat & BROKEN)
					AddOverlays(OVERLAY(icon, "sparks_broken", dir = src.dir))
					AddOverlays(emissive_appearance(icon, "sparks_broken_ea"))
				else if(health < maxhealth * 0.75)
					AddOverlays(OVERLAY(icon, "sparks_damaged", dir = src.dir))
					AddOverlays(emissive_appearance(icon, "sparks_damaged_ea"))
			if(welded)
				AddOverlays(OVERLAY(icon, "welded", dir = src.dir))
		else if(health < maxhealth * 0.75 && !(stat & NOPOWER))
			AddOverlays(OVERLAY(icon, "sparks_damaged", dir = src.dir))
			AddOverlays(emissive_appearance(icon, "sparks_damaged_ea"))

		if(!p_open && !operating)
			AddOverlays(emissive_appearance(icon, "closed_ea"))
	else
		icon_state = "door_open"
		if(!p_open) // Doors with opened panels have no green lights on their icons
			set_light(0.30, 0.9, 1.5, 3, COLOR_LIME)
		if((stat & BROKEN) && !(stat & NOPOWER))
			AddOverlays(OVERLAY(icon, "sparks_open", dir = src.dir))
			AddOverlays(emissive_appearance(icon, "sparks_open_ea"))

	if(brace)
		brace.update_icon()
		AddOverlays(image(brace.icon, brace.icon_state))

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			if(!p_open)
				set_light(0.30, 0.9, 1.5, 3, COLOR_LIME)
			flick("[p_open ? "o_door_opening" : "door_opening"]", src)
			update_icon(1)
		if("closing")
			flick("[p_open ? "o_door_closing" : "door_closing"]", src)
			update_icon()
		if("spark")
			if(density)
				flick("door_spark", src)
		if("deny")
			if(density)
				flick("door_deny", src)
				playsound(loc, open_failure_access_denied, 50, 0)
	return

/obj/machinery/door/airlock/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/data[0]

	data["main_power_loss"]   = round(main_power_lost_until   > 0 ? max(main_power_lost_until - world.time,   0) / 10 : main_power_lost_until,   1)
	data["backup_power_loss"] = round(backup_power_lost_until > 0 ? max(backup_power_lost_until - world.time, 0) / 10 : backup_power_lost_until, 1)
	data["electrified"]       = round(electrified_until       > 0 ? max(electrified_until - world.time,       0) / 10 : electrified_until,       1)
	data["open"] = !density

	var/commands[0]
	commands[++commands.len] = list("name" = "IdScan",      "command"= "idscan",   "active" = !aiDisabledIdScanner, "enabled" = "Enabled", "disabled" = "Disable",    "danger" = 0, "act" = 1)
	commands[++commands.len] = list("name" = "Bolts",       "command"= "bolts",    "active" = !locked,              "enabled" = "Raised ", "disabled" = "Dropped",    "danger" = 0, "act" = 0)
	commands[++commands.len] = list("name" = "Bolt Lights", "command"= "lights",   "active" = lights,               "enabled" = "Enabled", "disabled" = "Disable",    "danger" = 0, "act" = 1)
	commands[++commands.len] = list("name" = "Safeties",    "command"= "safeties", "active" = safe,                 "enabled" = "Nominal", "disabled" = "Overridden", "danger" = 1, "act" = 0)
	commands[++commands.len] = list("name" = "Timing",      "command"= "timing",   "active" = normalspeed,          "enabled" = "Nominal", "disabled" = "Overridden", "danger" = 1, "act" = 0)
	commands[++commands.len] = list("name" = "Door State",  "command"= "open",     "active" = density,              "enabled" = "Closed",  "disabled" = "Opened",     "danger" = 0, "act" = 0)

	data["commands"] = commands

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "door_control.tmpl", "Door Controls", 450, 350, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/door/airlock/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species?.can_shred(H))
			if(density && (stat & BROKEN))
				user.setClickCooldown(DEFAULT_WEAPON_COOLDOWN)
				to_chat(user, "You start forcing \the [src] open...")
				if(do_after(user, 30, src, luck_check_type = LUCK_CHECK_ENG))
					if(welded)
						to_chat(user, SPAN("danger", "The airlock has been welded shut!"))
					else if(locked)
						to_chat(user, SPAN("danger", "The door bolts are down!"))
					else if(density)
						visible_message(SPAN("danger","\The [user] forces \the [src] open!"))
						INVOKE_ASYNC(src, nameof(.proc/open), TRUE)
						shake_animation(2, 2)
				return
			playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
			visible_message(SPAN("danger", "[user] slashes at \the [name]."))
			take_damage(10)
			user.do_attack_animation(src)
			user.setClickCooldown(5)
			shake_animation(2, 2)
			return

	if(p_open)
		user.set_machine(src)
	else
		..(user)
	return

/obj/machinery/door/airlock/CanUseTopic(mob/user)
	if(operating == DOOR_FAILURE) //emagged
		to_chat(user, "<span class='warning'>Unable to interface: Internal error.</span>")
		return STATUS_CLOSE

	return ..()

/obj/machinery/door/airlock/Topic(href, href_list)
	if(..())
		return 1

	var/activate = text2num(href_list["activate"])
	switch(href_list["command"])
		if("idscan")
			set_idscan(activate, 1)

		if("bolts")
			if(activate && src.lock())
				to_chat(usr, "The door bolts have been dropped.")
			else if(!activate && src.unlock())
				to_chat(usr, "The door bolts have been raised.")

		if("open")
			if(src.welded)
				to_chat(usr, text("The airlock has been welded shut!"))
			else if(src.locked)
				to_chat(usr, text("The door bolts are down!"))
			else if(activate && density)
				INVOKE_ASYNC(src, nameof(.proc/open))
			else if(!activate && !density)
				INVOKE_ASYNC(src, nameof(.proc/close))

		if("timing")
			// Door speed control
			if(activate && normalspeed)
				normalspeed = 0
			else if(!activate && !normalspeed)
				normalspeed = 1

		if("lights")
			// Bolt lights
			if(!activate && lights)
				lights = 0
				to_chat(usr, "The door bolt lights have been disabled.")
			else if(activate && !lights)
				lights = 1
				to_chat(usr, "The door bolt lights have been enabled.")

	update_icon()
	return 1

//returns 1 on success, 0 on failure
/obj/machinery/door/airlock/proc/cut_bolts(obj/item/item, mob/user)
	var/cut_delay = (15 SECONDS)
	var/cut_verb
	var/cut_sound

	if(isWelder(item))
		cut_sound = null
		cut_verb = "cutting"

	else if(istype(item,/obj/item/circular_saw))
		cut_verb = "sawing"
		cut_sound = 'sound/effects/fighting/circsawhit.ogg'
		cut_delay *= 1.5

	else if(istype(item, /obj/item/material/twohanded/fireaxe))
		//special case - zero delay, different message
		if(lock_cut_state == BOLTS_EXPOSED)
			return 0 //can't actually cut the bolts, go back to regular smashing
		var/obj/item/material/twohanded/fireaxe/F = item
		if(!F.wielded)
			return 0
		user.visible_message(
			"<span class='danger'>\The [user] smashes the bolt cover open!</span>",
			"<span class='warning'>You smash the bolt cover open!</span>"
			)
		playsound(src, 'sound/effects/fighting/smash.ogg', 100, 1)
		lock_cut_state = BOLTS_EXPOSED
		return 0

	else
		// I guess you can't cut bolts with that item. Never mind then.
		return 0

	if(src.lock_cut_state == BOLTS_FINE)
		user.visible_message(
			"<span class='notice'>\The [user] begins [cut_verb] through the bolt cover on [src].</span>",
			"<span class='notice'>You begin [cut_verb] through the bolt cover.</span>"
			)

		if(!isnull(cut_sound))
			playsound(src, cut_sound, 100, 1)
		var/obj/item/weldingtool/WT = item
		if((!istype(WT) && do_after(user, cut_delay, src)) || (istype(WT) && WT.use_tool(src, user, delay = cut_delay, amount = 50)))
			if(QDELETED(src))
				return

			user.visible_message(
				"<span class='notice'>\The [user] removes the bolt cover from [src]</span>",
				"<span class='notice'>You remove the cover and expose the door bolts.</span>"
				)
			src.lock_cut_state = BOLTS_EXPOSED
		return 1

	if(lock_cut_state == BOLTS_EXPOSED)
		user.visible_message(
			"<span class='notice'>\The [user] begins [cut_verb] through [src]'s bolts.</span>",
			"<span class='notice'>You begin [cut_verb] through the door bolts.</span>"
			)
		if(!isnull(cut_sound))
			playsound(src, cut_sound, 100, 1)
		var/obj/item/weldingtool/WT = item
		if((!istype(WT) && do_after(user, cut_delay, src)) || (istype(WT) && WT.use_tool(src, user, delay = cut_delay, amount = 50)))
			user.visible_message(
				"<span class='notice'>\The [user] severs the door bolts, unlocking [src].</span>",
				"<span class='notice'>You sever the door bolts, unlocking the door.</span>"
				)
			lock_cut_state = BOLTS_CUT
			unlock(1) //force it
		return 1

/obj/machinery/door/airlock/attackby(obj/item/C, mob/user)
	if(user.a_intent == I_HURT && !isWelder(C))
		return ..()

	// Brace is considered installed on the airlock, so interacting with it is protected from electrification.
	if(brace && (istype(C.get_id_card(), /obj/item/card/id/) || istype(C, /obj/item/crowbar/brace_jack)))
		return brace.attackby(C, user)

	if(!brace && istype(C, /obj/item/airlock_brace))
		var/obj/item/airlock_brace/B = C
		if(!density)
			to_chat(user, "You must close \the [src] before installing \the [B]!")
			return

		if((!B.req_access.len && !B.req_one_access) && (alert("\the [B]'s 'Access Not Set' light is flashing. Install it anyway?", "Access not set", "Yes", "No") == "No"))
			return

		if(do_after(user, 50, src, luck_check_type = LUCK_CHECK_ENG) && density && user.drop(B, src))
			to_chat(user, "You successfully install \the [B]. \The [src] has been locked.")
			brace = B
			brace.airlock = src
			update_icon()
		return

	if(istype(C, /obj/item/taperoll))
		return

	if(!repairing && (stat & BROKEN) && locked) //bolted and broken
		if(!cut_bolts(C,user))
			..()
		return

	if(!repairing && isWelder(C) && !(operating > 0) && density)
		var/obj/item/weldingtool/W = C
		if(!W.use_tool(src, user, amount = 10))
			return

		if(!welded)
			welded = TRUE
		else
			welded = null
		update_icon()

	else if(isScrewdriver(C))
		if(p_open)
			if(stat & BROKEN)
				to_chat(usr, "<span class='warning'>The panel is broken and cannot be closed.</span>")
			else
				p_open = FALSE
		else
			p_open = TRUE
		update_icon()

	else if(isWirecutter(C))
		return attack_hand(user)

	else if(isMultitool(C))
		return attack_hand(user)

	else if(!repairing && isCrowbar(C))
		to_chat(user, SPAN("notice", "The airlock's motors resist your efforts to force it."))

	//if door is unbroken, but at half health or less, hit with fire axe using harm intent
	else if (istype(C, /obj/item/material/twohanded/fireaxe) && !(stat & BROKEN) && (src.health <= src.maxhealth / 2) && user.a_intent == I_HURT)
		var/obj/item/material/twohanded/fireaxe/F = C
		if(F.wielded)
			playsound(src, 'sound/effects/fighting/smash.ogg', 100, 1)
			user.visible_message("<span class='danger'>[user] smashes \the [C] into the airlock's control panel! It explodes in a shower of sparks!</span>", "<span class='danger'>You smash \the [C] into the airlock's control panel! It explodes in a shower of sparks!</span>")
			health = 0
			set_broken(TRUE)
		else
			return ..()
	else
		..()

/obj/machinery/door/airlock/deconstruct(mob/user, moved = FALSE)
	var/obj/structure/door_assembly/da = new assembly_type(src.loc)
	if(istype(da, /obj/structure/door_assembly/multi_tile))
		da.set_dir(src.dir)
	if(mineral)
		da.glass = mineral
	//else if(glass)
	else if(glass && !da.glass)
		da.glass = 1

	if(moved)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
	else
		da.anchored = 1
	da.state = 1
	da.created_name = src.name
	da.update_state()

	if(operating == DOOR_FAILURE || (stat & BROKEN))
		new /obj/item/circuitboard/broken(src.loc)
		operating = DOOR_IDLE
	else
		if(!electronics)
			create_electronics()

		electronics.dropInto(loc)
		electronics = null

	qdel(src)

	return da

/obj/machinery/door/airlock/set_broken(new_state)
	. = ..()
	if(. && new_state)
		p_open = 1
		if (secured_wires)
			lock()
		visible_message("\The [src]'s control panel bursts open, sparks spewing out!")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()

/obj/machinery/door/airlock/can_open(forced = 0)
	if(brace)
		return 0
	if(locked || welded)
		return 0
	return ..()

/obj/machinery/door/airlock/can_close(forced = 0)
	if(locked || welded)
		return 0
	return ..()

/obj/machinery/door/airlock/open(forced = 0)
	if(!can_open(forced))
		return 0

	if(islist(open_sound_powered))
		playsound(loc, pick(open_sound_powered), 70, 1)
	else
		playsound(loc, open_sound_powered, 70, 1)

	if(closeOther != null && istype(closeOther, /obj/machinery/door/airlock/) && !closeOther.density)
		INVOKE_ASYNC(closeOther, nameof(.proc/close))
	return ..()

/obj/machinery/door/airlock/close(forced = 0)
	var/wait = normalspeed ? 150 : 5
	if(!can_close(forced))
		set_next_think_ctx("close", world.time + wait)
		return 0

	if(safe)
		for(var/turf/T in locs)
			for(var/atom/movable/AM in T)
				if(AM.blocks_airlock())
					if(autoclose && tryingToLock)
						set_next_think_ctx("close", world.time + (30 SECONDS))
					if(world.time > next_beep_at)
						playsound(src.loc, close_failure_blocked, 30, 0, -3)
						next_beep_at = world.time + SecondsToTicks(10)
					set_next_think_ctx("close", world.time + wait)
					return

	for(var/turf/T in locs)
		for(var/atom/movable/AM in T)
			if(AM.airlock_crush(door_crush_damage))
				take_damage(door_crush_damage)

	tryingToLock = FALSE
	playsound(src.loc, pick(close_sound_powered), 100, 1)

	return ..(forced, safe)

/obj/machinery/door/airlock/proc/lock(forced = 0)
	if(locked)
		return 0

	if(operating && !forced)
		return 0

	if(lock_cut_state == BOLTS_CUT)
		return 0 //what bolts?

	locked = TRUE
	playsound(src, bolts_dropping, 30, 0, -6)
	audible_message("You hear a click from the bottom of the door.", hearing_distance = 1, splash_override = "*click*")
	update_icon()
	return 1

/obj/machinery/door/airlock/proc/unlock(forced = 0)
	if(!locked)
		return 0

	if(!forced && operating)
		return 0

	locked = FALSE
	playsound(src, bolts_rising, 30, 0, -6)
	audible_message("You hear a click from the bottom of the door.", hearing_distance = 1, splash_override = "*click*")
	update_icon()
	return 1

/obj/machinery/door/airlock/allowed(mob/M)
	if(locked)
		return 0
	return ..(M)

/obj/machinery/door/airlock/New(newloc, obj/structure/door_assembly/assembly = null)
	..()

	add_think_ctx("close", CALLBACK(src, nameof(.proc/close)), 0)

	//if assembly is given, create the new door from the assembly
	if (assembly && istype(assembly))
		assembly_type = assembly.type

		electronics = assembly.electronics
		electronics.forceMove(src)
		assembly.electronics = null

		//update the door's access to match the electronics'
		secured_wires = electronics.secure
		if(electronics.one_access)
			req_access.Cut()
			req_one_access = src.electronics.conf_access
		else
			req_one_access.Cut()
			req_access = src.electronics.conf_access

		//get the name from the assembly
		if(assembly.created_name)
			SetName(assembly.created_name)
		else
			SetName("[istext(assembly.glass) ? "[assembly.glass] airlock" : assembly.base_name]")

		//get the dir from the assembly
		set_dir(assembly.dir)

/obj/machinery/door/airlock/Initialize()
	if(closeOtherId != null)
		for(var/obj/machinery/door/airlock/A in world)
			if(A.closeOtherId == closeOtherId && A != src)
				closeOther = A
				break

	var/turf/T = loc
	var/obj/item/airlock_brace/A = locate(/obj/item/airlock_brace) in T
	if(!brace && A)
		brace = A
		brace.airlock = src
		brace.forceMove(src)
		update_icon()

	return ..()

/obj/machinery/door/airlock/Destroy()
	qdel(wifi_receiver)
	wifi_receiver = null
	if(brace)
		qdel(brace)
	return ..()

// Most doors will never be deconstructed over the course of a round,
// so as an optimization defer the creation of electronics until
// the airlock is deconstructed
/obj/machinery/door/airlock/proc/create_electronics()
	//create new electronics
	if(secured_wires)
		electronics = new /obj/item/airlock_electronics/secure( src.loc )
	else
		electronics = new /obj/item/airlock_electronics( src.loc )

	//update the electronics to match the door's access
	if(!req_access)
		check_access()
	if(req_access.len)
		electronics.conf_access = req_access
	else if(req_one_access.len)
		electronics.conf_access = req_one_access
		electronics.one_access = 1

// Braces can act as an extra layer of armor - they will take damage first.
/obj/machinery/door/airlock/take_damage(amount)
	if(brace)
		brace.take_damage(amount)
	else
		..(amount)

/obj/machinery/door/airlock/examine(mob/user, infix)
	. = ..()

	if(lock_cut_state == BOLTS_EXPOSED)
		. += "The bolt cover has been cut open."
	if(lock_cut_state == BOLTS_CUT)
		. += "The door bolts have been cut."
	if(brace)
		. += "\The [brace] is installed on \the [src], preventing it from opening."
		. += "[brace.examine_health()]"

/obj/machinery/door/airlock/autoname
	name = "hatch"
	icon = 'icons/obj/doors/doorhatchmaint2.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_mhatch

/obj/machinery/door/airlock/autoname/New()
	var/area/A = get_area(src)
	name = A.name
	..()
