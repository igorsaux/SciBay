/obj/item/orbital_shaker
	name = "orbital shaker"
	desc = "A heavy-duty laboratory orbital shaker. It uses continuous circular motion to keep reagent mixtures homogeneous."
	icon = 'icons/chemistry.dmi'
	icon_state = "orbital_shaker"
	layer = BELOW_OBJ_LAYER
	w_class = ITEM_SIZE_HUGE
	randpixel = 0

	var/__is_running = FALSE
	var/__target_stirring = 0.0

/obj/item/orbital_shaker/attack_hand(mob/user)
	. = ..()

	if(anchored)
		tgui_interact(user)

/obj/item/orbital_shaker/attackby(obj/item/W, mob/user)
	if(isWrench(W))
		if(!is_there_building_allowed(src))
			to_chat(user, SPAN_WARNING("You can't wrench \the [src] here."))

			return
		
		if(__is_running)
			to_chat(user, SPAN_WARNING("Turn \the [src] off before unwrenching it."))

			return

		user.visible_message(
			SPAN_NOTICE("[user] [anchored ? "unwrenches" : "wrenches"] \the [src] [anchored ? "from" : "to"] the floor."),
			SPAN_NOTICE("You [anchored ? "unwrench" : "wrench"] \the [src] [anchored ? "from" : "to"] the floor.")
		)

		anchored = !anchored
		playsound(src, 'sound/items/Ratchet.ogg', 50, TRUE)

		return

	. = ..()

/obj/item/orbital_shaker/think()
	if(!__is_running)
		return
	
	var/turf/T = get_turf(src)
	
	for(var/obj/item/reagent_containers/C in T?.contents)
		if(!istype(C))
			continue
		
		var/new_stirring = max(C.__stirring, __target_stirring)
		C.set_stirring(new_stirring)
	
	set_next_think(world.time + (1 DECI SECOND))

/obj/item/orbital_shaker/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "OrbitalShaker", "Orbital Shaker", 350, 250)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/item/orbital_shaker/tgui_data(mob/user)
	var/list/data = list()

	data["is_running"] = __is_running
	data["target_stirring"] = __target_stirring

	return data

/obj/item/orbital_shaker/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return TRUE

	switch(action)
		if("toggle_power")
			if(!anchored)
				to_chat(ui.user, SPAN_WARNING("\The [src] must be anchored to operate."))

				return TRUE

			__is_running = !__is_running

			if(__is_running)
				set_next_think(world.time + (1 DECI SECOND))
				ui.user.visible_message(
					SPAN_NOTICE("[ui.user] starts \the [src]."),
					SPAN_NOTICE("You start \the [src].")
				)
			else
				set_next_think(0)
				ui.user.visible_message(
					SPAN_NOTICE("[ui.user] stops \the [src]."),
					SPAN_NOTICE("You stop \the [src].")
				)

			return TRUE

		if("set_stirring")
			var/new_value = text2num(params["value"])

			if(isnull(new_value))
				return TRUE

			__target_stirring = clamp(new_value, 0, 1)

			return TRUE
