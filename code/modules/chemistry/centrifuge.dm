/obj/item/centrifuge
	name = "centrifuge"
	desc = "A laboratory centrifuge for separating mixtures."
	icon = 'icons/chemistry.dmi'
	icon_state = "centrifuge_off"
	layer = BELOW_OBJ_LAYER
	w_class = ITEM_SIZE_LARGE
	randpixel = 0
	anchored = FALSE

	// Configurable features for subtypes.
	var/target_rpm_settable = FALSE
	var/target_duration_settable = FALSE
	var/target_temp_settable = FALSE
	var/min_temp = 20 CELSIUS
	var/max_temp = 40 CELSIUS
	var/max_rpm = 1000

	// User settings.
	var/target_rpm = 1000
	var/target_temperature = 20 CELSIUS
	var/target_duration = 60 SECONDS

	// Runtime state.
	var/is_running = FALSE
	var/current_rpm = 0
	var/chamber_temp = 20 CELSIUS
	var/run_end_time = 0

	var/obj/item/centrifuge_rotor/rotor = null

	var/__last_think = 0

/obj/item/centrifuge/attackby(obj/item/W, mob/user)
	if(isWrench(W))
		if(!is_there_building_allowed(src))
			to_chat(user, SPAN_WARNING("You cannot secure \the [src] here; the floor is unsuitable."))

			return

		if(is_running)
			to_chat(user, SPAN_WARNING("You must turn off \the [src] before unsecuring it."))

			return

		user.visible_message(
			SPAN_NOTICE("[user] [anchored ? "unsecures" : "secures"] \the [src] [anchored ? "from" : "to"] the floor."),
			SPAN_NOTICE("You [anchored ? "unsecure" : "secure"] \the [src] [anchored ? "from" : "to"] the floor.")
		)

		anchored = !anchored
		playsound(src, 'sound/items/Ratchet.ogg', 50, TRUE)
		update_icon()

		return
	else if(isScrewdriver(W))
		if(QDELETED(rotor))
			to_chat(user, SPAN_WARNING("The centrifuge has no rotor installed."))

			return

		for(var/i in rotor.installed_containers)
			if(!QDELETED(rotor.installed_containers[i]))
				to_chat(user, SPAN_WARNING("Remove all containers from the rotor before detaching it."))

				return

		user.pick_or_drop(rotor)

		user.visible_message(
			SPAN_NOTICE("[user] removes \the [rotor] from \the [src]."),
			SPAN_NOTICE("You remove \the [rotor] from \the [src].")
		)

		rotor = null
		playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
		update_icon()

		return
	else if(istype(W, /obj/item/centrifuge_rotor))
		if(!QDELETED(rotor))
			to_chat(user, SPAN_WARNING("A rotor is already installed in \the [src]."))
			return

		var/obj/item/centrifuge_rotor/R = W
		var/compatible = FALSE

		for(var/path in R.compatible_centrifuges)
			if(istype(src, path))
				compatible = TRUE

				break

		if(!compatible)
			to_chat(user, SPAN_WARNING("\The [R] does not fit into \the [src]. Check the centrifuge specifications."))

			return

		if(!user.drop(W, src))
			return

		rotor = W
		W.forceMove(src)
		target_rpm = min(target_rpm, max_rpm, rotor.max_rpm)

		user.visible_message(
			SPAN_NOTICE("[user] installs \the [W] into \the [src]."),
			SPAN_NOTICE("You install \the [W] into \the [src].")
		)

		update_icon()
		return

	. = ..()

/obj/item/centrifuge/attack_hand(mob/user)
	. = ..()

	if(anchored)
		tgui_interact(user)

/obj/item/centrifuge/tgui_data(mob/user)
	var/list/data = list()

	data["is_running"] = is_running
	data["anchored"] = anchored
	data["has_rotor"] = !QDELETED(rotor)

	// Settings availability flags.
	data["target_rpm_settable"] = target_rpm_settable
	data["target_duration_settable"] = target_duration_settable
	data["target_temp_settable"] = target_temp_settable

	// Current user settings.
	data["target_rpm"] = target_rpm
	data["target_temperature"] = target_temperature
	data["target_duration"] = target_duration

	// Machine limits.
	data["max_rpm"] = rotor ? min(max_rpm, rotor.max_rpm) : max_rpm
	data["min_temp"] = min_temp
	data["max_temp"] = max_temp

	// Live runtime values.
	data["current_rpm"] = current_rpm
	data["current_temp"] = chamber_temp
	data["time_remaining"] = is_running ? max(0, run_end_time - world.time) : 0

	// Rotor details and container map.
	if(rotor)
		data["rotor"] = list(
			"name" = rotor.name,
			"max_rpm" = rotor.max_rpm,
			"radius" = rotor.radius,
			"slots_count" = rotor.slots_count,
			"integrity" = rotor.integrity,
			"cycles_used" = rotor.cycles_used,
			"max_cycles" = rotor.max_cycles,
			"is_balanced" = rotor.is_balanced()
		)

		var/list/containers = list()

		for(var/slot = 1 to rotor.slots_count)
			var/list/slot_data = list(
				"slot" = slot,
				"occupied" = FALSE,
				"container_name" = null,
				"container_ref" = null,
			)

			var/obj/item/reagent_containers/vessel/V = rotor.installed_containers["[slot]"]

			if(!QDELETED(V))
				slot_data["occupied"] = TRUE
				slot_data["container_name"] = V.name
				slot_data["container_ref"] = "\ref[V]"

			containers += list(slot_data)

		data["containers"] = containers
	else
		data["rotor"] = null
		data["containers"] = list()

	return data

/obj/item/centrifuge/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return TRUE

	switch(action)
		if("turn_on")
			turn_on(usr)

			return TRUE
		if("turn_off")
			turn_off(usr)

			return TRUE
		if("set_g")
			if(!target_rpm_settable)
				return FALSE

			var/new_g = text2num(params["g"])

			if(isnull(new_g) || new_g < 0)
				return FALSE

			if(QDELETED(rotor))
				return FALSE

			var/radius_mm = rotor.radius * 1000

			if(radius_mm <= 0)
				return FALSE

			var/calculated_rpm = sqrt(new_g / (1.118e-5 * radius_mm))
			target_rpm = clamp(round(calculated_rpm), 0, max_rpm)
			target_rpm = min(target_rpm, rotor.max_rpm)

			return TRUE
		if("set_rpm")
			if(!target_rpm_settable)
				return FALSE

			var/new_rpm = text2num(params["rpm"])

			if(isnull(new_rpm))
				return FALSE

			target_rpm = clamp(round(new_rpm), 0, max_rpm)

			if(rotor)
				target_rpm = min(target_rpm, rotor.max_rpm)

			return TRUE
		if("set_duration")
			if(!target_duration_settable)
				return FALSE

			var/new_dur = text2num(params["duration"])

			if(isnull(new_dur))
				return FALSE

			target_duration = clamp(round(new_dur), 10 SECONDS, 24 HOURS)

			return TRUE
		if("set_temp")
			if(!target_temp_settable)
				return FALSE

			var/new_temp = text2num(params["temp"])

			if(isnull(new_temp))
				return FALSE

			target_temperature = clamp(round(new_temp, 1), min_temp, max_temp)

			return TRUE
		if("eject_container")
			if(QDELETED(rotor))
				return FALSE

			if(is_running)
				to_chat(usr, SPAN_WARNING("You cannot remove containers while the centrifuge is spinning!"))

				return FALSE

			var/slot = text2num(params["slot"])

			if(isnull(slot) || slot < 1 || slot > rotor.slots_count)
				return FALSE

			var/obj/item/reagent_containers/vessel/V = rotor.installed_containers["[slot]"]

			if(QDELETED(V))
				return FALSE

			rotor.installed_containers -= "[slot]"
			V.forceMove(get_turf(src))

			if(usr.put_in_hands(V))
				to_chat(usr, SPAN_NOTICE("You remove \the [V] from slot [slot]."))
			else
				to_chat(usr, SPAN_NOTICE("You eject \the [V] from slot [slot] onto the floor."))

			update_icon()

			return TRUE
		if("insert_container")
			if(QDELETED(rotor))
				return FALSE

			if(is_running)
				to_chat(usr, SPAN_WARNING("You cannot insert containers while the centrifuge is spinning!"))

				return FALSE

			var/slot = text2num(params["slot"])

			if(isnull(slot) || slot < 1 || slot > rotor.slots_count)
				return FALSE

			if(rotor.installed_containers["[slot]"])
				to_chat(usr, SPAN_WARNING("Slot [slot] is already occupied."))

				return FALSE

			var/obj/item/I = usr.get_active_hand()

			if(!istype(I, /obj/item/reagent_containers/vessel))
				to_chat(usr, SPAN_WARNING("You must hold a compatible vessel to insert it."))
				return FALSE

			var/obj/item/reagent_containers/vessel/V = I
			var/allowed = FALSE

			for(var/path in rotor.allowed_containers)
				if(istype(V, path))
					allowed = TRUE

					break

			if(!allowed)
				to_chat(usr, SPAN_WARNING("\The [V] is not compatible with this rotor."))

				return FALSE

			if(!usr.drop(V, src))
				return FALSE

			rotor.installed_containers["[slot]"] = V
			V.forceMove(src)
			to_chat(usr, SPAN_NOTICE("You insert \the [V] into slot [slot]."))
			update_icon()

			return TRUE

	return FALSE

/obj/item/centrifuge/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Centrifuge", "Centrifuge", 800, 600)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/item/centrifuge/Destroy()
	QDEL_NULL(rotor)

	. = ..()

/obj/item/centrifuge/proc/turn_on(mob/activator = null)
	if(is_running)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] is already spinning."))

		return FALSE

	if(QDELETED(rotor))
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] cannot operate without a rotor!"))

		return FALSE

	if(!anchored)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] must be bolted to the floor before operation."))

		return FALSE

	if(rotor.integrity <= 0)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] refuses to start: the rotor is too damaged to spin safely."))

		return FALSE

	if(rotor.cycles_used >= rotor.max_cycles)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] refuses to start: the rotor has exceeded its rated service life. The safety interlock is engaged."))

		return FALSE

	if(!rotor.is_balanced())
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] refuses to start: the load is dangerously unbalanced."))

		return FALSE

	if(target_rpm <= 0)
		if(activator)
			to_chat(activator, SPAN_WARNING("Set a target RPM greater than zero."))

		return FALSE

	if(target_duration <= 0)
		if(activator)
			to_chat(activator, SPAN_WARNING("Set a duration greater than zero."))

		return FALSE

	for(var/i in rotor.installed_containers)
		var/obj/item/reagent_containers/RC = rotor.installed_containers[i]

		if(QDELETED(RC))
			continue
		
		if(RC.is_open_container())
			if(activator)
				to_chat(activator, SPAN_WARNING("\The [src] refuses to start: \the [RC] is open. Secure the lid before spinning."))
			
			return FALSE

	// Warn the operator if the rotor is living on borrowed time
	if(rotor.integrity < 0.3)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [rotor] looks seriously fatigued. Vibration and failure are likely."))

	is_running = TRUE
	current_rpm = min(target_rpm, max_rpm, rotor.max_rpm)
	run_end_time = world.time + target_duration
	__last_think = world.time
	rotor.cycles_used++

	visible_message(SPAN_NOTICE("\The [src] whirs to life."))
	update_icon()
	set_next_think(world.time + 1 SECOND)

	return TRUE

/obj/item/centrifuge/proc/turn_off(mob/activator = null)
	if(!is_running)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] is not running."))

		return FALSE

	is_running = FALSE
	current_rpm = 0

	visible_message(SPAN_NOTICE("\The [src] powers down with a decelerating hum."))
	update_icon()
	set_next_think(world.time + 1 SECOND)

	return TRUE

/obj/item/centrifuge/think()
	if(!is_running)
		// Return chamber temperature toward ambient when idle.
		if(target_temp_settable)
			if(abs(chamber_temp - 20 CELSIUS) > 0.5)
				chamber_temp += clamp(20 CELSIUS - chamber_temp, -1, 1)
				set_next_think(world.time + 1 SECOND)
		else
			if(chamber_temp > 20 CELSIUS)
				chamber_temp = max(chamber_temp - 0.5, 20 CELSIUS)
				set_next_think(world.time + 1 SECOND)

		return

	if(QDELETED(rotor))
		turn_off()

		return

	var/dt = (world.time - __last_think) / 10
	var/radius_mm = rotor.radius * 1000
	var/relative_g = 1.0 + 1.118e-5 * radius_mm * (current_rpm ** 2)
	var/total_g = G0 * relative_g

	// Rotor wear: high-speed stress and age fatigue
	if(current_rpm > rotor.max_rpm * 0.85)
		rotor.integrity -= 0.001 * dt
	else if(current_rpm > rotor.max_rpm * 0.5)
		rotor.integrity -= 0.0002 * dt

	if(rotor.cycles_used > rotor.max_cycles * 0.8)
		rotor.integrity -= 0.0003 * dt

	if(rotor.integrity <= 0)
		handle_rotor_failure()
		turn_off()

		return

	for(var/i in rotor.installed_containers)
		var/obj/item/reagent_containers/vessel/V = rotor.installed_containers[i]
		if(QDELETED(V))
			continue

		V.adjust_stratification(Z_CHEM_GET_STRATIFICATION_RATE(V, total_g) * dt)

		ASSERT(Z_CHEM_EXCHANGE_HEAT(V, chamber_temp, 5 * V.bottom_area, dt) != null)

	// Auto-stop when the timer expires.
	if(world.time >= run_end_time)
		visible_message(SPAN_NOTICE("\The [src] beeps as the cycle finishes."))
		turn_off()

		return

	// Thermal logic.
	if(target_temp_settable)
		var/temp_diff = target_temperature - chamber_temp
		chamber_temp += clamp(temp_diff, -2, 2)
	else
		chamber_temp += 0.3
		chamber_temp = min(chamber_temp, max_temp)

	__last_think = world.time
	set_next_think(world.time + 1 SECOND)

/obj/item/centrifuge/proc/handle_rotor_failure()
	visible_message(SPAN_DANGER("\The [src] emits a deafening shriek as the rotor tears itself apart!"))

	for(var/i in rotor.installed_containers)
		var/obj/item/reagent_containers/vessel/V = rotor.installed_containers[i]

		if(QDELETED(V))
			continue

		V.forceMove(get_turf(src))
		V.throw_at_random(FALSE, 12, 3)

	qdel(rotor)
	rotor = null

/obj/item/centrifuge/Value(base)
	. = ..()

	if(!QDELETED(rotor))
		. += get_base_value(rotor)

/obj/item/centrifuge/on_update_icon()
	. = ..()

	if(is_running)
		icon_state = "centrifuge_on"
	else
		icon_state = "centrifuge_off"

/obj/item/centrifuge/mini
	name = "mini centrifuge"
	desc = "A compact microcentrifuge for quick spins."

	w_class = ITEM_SIZE_NORMAL

	max_rpm = 15000

/obj/item/centrifuge/benchtop
	target_rpm_settable = TRUE
	target_duration_settable = TRUE

/obj/item/centrifuge/benchtop/lowspeed
	name = "benchtop low-speed centrifuge"
	desc = "A general-purpose centrifuge for routine separations."

	max_rpm = 6000

/obj/item/centrifuge/benchtop/highspeed
	name = "benchtop high-speed centrifuge"
	desc = "A high-speed centrifuge for fine separations."

	max_rpm = 20000

/obj/item/centrifuge/benchtop/refrigerated
	name = "refrigerated centrifuge"
	desc = "A refrigerated high-speed centrifuge for temperature-sensitive samples."

	target_temp_settable = TRUE

	min_temp = -20 CELSIUS
	max_temp = 40 CELSIUS
	max_rpm = 30000

/obj/item/centrifuge/ultra
	name = "ultracentrifuge"
	desc = "An analytical ultracentrifuge for subcellular fractionation."

	max_rpm = 150000
	target_rpm_settable = TRUE
	target_temp_settable = TRUE
	target_duration_settable = TRUE
	min_temp = -10 CELSIUS
	max_temp = 40 CELSIUS

/obj/item/centrifuge_rotor
	name = "centrifuge rotor"
	desc = "A replaceable rotor for a centrifuge."
	icon = 'icons/chemistry.dmi'

	w_class = ITEM_SIZE_NORMAL

	var/max_rpm = 4000
	var/radius = 8.6 CENTI METERS

	var/slots_count = 4

	var/list/allowed_containers = list()
	var/list/compatible_centrifuges = list(
		/obj/item/centrifuge
	)

	var/integrity = 1.0
	var/max_cycles = 10000
	var/cycles_used = 0

	var/alist/installed_containers = alist()

/obj/item/centrifuge_rotor/Destroy()
	for(var/i in installed_containers)
		qdel(installed_containers[i])

	. = ..()

/obj/item/centrifuge_rotor/examine(mob/user, infix)
	. = ..()

	. += SPAN_NOTICE("The rotor radius is [radius * 100] cm. Maximum speed: [max_rpm] RPM.")

	var/integrity_desc

	switch(integrity)
		if(0.9 to INFINITY)
			integrity_desc = "pristine, showing no visible wear"
		if(0.7 to 0.9)
			integrity_desc = "lightly scuffed from normal use"
		if(0.5 to 0.7)
			integrity_desc = "visibly worn, with faint scoring along the buckets"
		if(0.3 to 0.5)
			integrity_desc = "fatigued; hairline stress marks are visible under the finish"
		if(0.1 to 0.3)
			integrity_desc = "severely compromised and should be replaced soon"
		else
			integrity_desc = "on the verge of catastrophic failure; it groans ominously when handled"

	var/life_desc
	var/life_ratio = cycles_used / max(max_cycles, 1)

	switch(life_ratio)
		if(0 to 0.25)
			life_desc = "It has seen light service."
		if(0.25 to 0.5)
			life_desc = "It has logged considerable runtime."
		if(0.5 to 0.75)
			life_desc = "It is well into its service life."
		if(0.75 to 1.0)
			life_desc = "It is approaching its rated limit."
		else
			life_desc = "It has exceeded its design lifespan and is operating on borrowed time."

	. += SPAN_NOTICE("The rotor looks [integrity_desc].")
	. += SPAN_NOTICE("[life_desc]")

/obj/item/centrifuge_rotor/proc/is_balanced()
	if(slots_count % 2 != 0)
		// Odd slot count: all occupied slots must have equal weight.
		var/first_weight = null

		for(var/i = 1 to slots_count)
			var/w = get_slot_weight(i)

			if(w == 0)
				continue

			if(isnull(first_weight))
				first_weight = w
			else if(abs(w - first_weight) > 0.5)
				return FALSE

		return TRUE

	var/half = slots_count / 2

	for(var/i = 1 to half)
		var/wa = get_slot_weight(i)
		var/wb = get_slot_weight(i + half)

		if(abs(wa - wb) > 0.5)
			return FALSE

	return TRUE

/obj/item/centrifuge_rotor/proc/get_slot_weight(index)
	var/obj/item/reagent_containers/C = installed_containers["[index]"]

	if(QDELETED(C))
		return 0

	return C.get_solids_weight() + C.get_liquids_weight()

/obj/item/centrifuge_rotor/Value(base)
	. = ..()

	for(var/i in installed_containers)
		var/obj/item/I = installed_containers[i]

		if(!QDELETED(I))
			. += get_base_value(I)

/obj/item/centrifuge_rotor/micro
	name = "micro rotor"
	desc = "A fixed-angle rotor for microcentrifuge tubes and vials. 12 positions."
	icon_state = "rotor_medium"

	max_rpm = 15000
	radius = 5.4 CENTI METERS

	slots_count = 12

	allowed_containers = list(
		/obj/item/reagent_containers/vessel/beaker/vial
	)
	compatible_centrifuges = list(
		/obj/item/centrifuge/mini
	)

/obj/item/centrifuge_rotor/standard
	name = "standard fixed-angle rotor"
	desc = "A 6-position fixed-angle rotor for standard laboratory vessels."
	icon_state = "rotor_slow"

	max_rpm = 6000
	radius = 10.0 CENTI METERS

	slots_count = 6

	allowed_containers = list(
		/obj/item/reagent_containers/vessel/beaker,
		/obj/item/reagent_containers/vessel/beaker/large,
	)

	compatible_centrifuges = list(
		/obj/item/centrifuge/benchtop,
		/obj/item/centrifuge/ultra
	)

/obj/item/centrifuge_rotor/highspeed
	name = "high-speed fixed-angle rotor"
	desc = "A 6-position fixed-angle rotor for high-speed separations."
	icon_state = "rotor_high"

	max_rpm = 20000
	radius = 8.0 CENTI METERS

	slots_count = 6

	allowed_containers = list(
		/obj/item/reagent_containers/vessel/beaker,
		/obj/item/reagent_containers/vessel/beaker/large,
	)

	compatible_centrifuges = list(
		/obj/item/centrifuge/benchtop,
		/obj/item/centrifuge/ultra
	)

/obj/item/centrifuge_rotor/refrigerated
	name = "refrigerated high-speed rotor"
	desc = "A sealed 6-position fixed-angle rotor rated for refrigerated high-speed operation."
	icon_state = "rotor_high"

	max_rpm = 30000
	radius = 7.0 CENTI METERS

	slots_count = 6

	allowed_containers = list(
		/obj/item/reagent_containers/vessel/beaker,
		/obj/item/reagent_containers/vessel/beaker/large,
	)

	compatible_centrifuges = list(
		/obj/item/centrifuge/benchtop,
		/obj/item/centrifuge/ultra
	)

/obj/item/centrifuge_rotor/bottle
	name = "bottle fixed-angle rotor"
	desc = "A 4-position fixed-angle rotor with deep buckets for bottles."
	icon_state = "rotor_slow"

	max_rpm = 5000
	radius = 11.5 CENTI METERS

	slots_count = 4

	allowed_containers = list(
		/obj/item/reagent_containers/vessel/bottle/chemical/small,
		/obj/item/reagent_containers/vessel/bottle/chemical/big,
		/obj/item/reagent_containers/vessel/beaker,
		/obj/item/reagent_containers/vessel/beaker/large
	)

	compatible_centrifuges = list(
		/obj/item/centrifuge/benchtop,
		/obj/item/centrifuge/ultra
	)

/obj/item/centrifuge_rotor/ultra
	name = "titanium fixed-angle rotor"
	desc = "A high-strength titanium rotor rated for extreme centrifugal forces."
	icon_state = "rotor_ultra"

	max_rpm = 150000
	radius = 8.0 CENTI METERS

	slots_count = 8

	allowed_containers = list(
		/obj/item/reagent_containers/vessel/beaker/vial
	)

	compatible_centrifuges = list(
		/obj/item/centrifuge/ultra
	)
