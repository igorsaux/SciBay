/obj/item/bunsen
	name = "Bunsen burner (1200 K)"
	desc = "A laboratory gas burner producing a single open flame, capable of reaching up to 1200 Kelvin. The air intake valve can be adjusted to control flame temperature and intensity."
	icon = 'icons/chemistry.dmi'
	icon_state = "bunsen"
	layer = BELOW_OBJ_LAYER
	w_class = ITEM_SIZE_LARGE

	var/is_on = FALSE
	var/strength = 0.1
	var/flame_temperature = 1200 KELVIN
	var/max_convection = 500
	var/obj/item/reagent_containers/__container = null

/obj/item/bunsen/Destroy()
	if(!QDELETED(__container))
		qdel(__container)
		__container = null

	. = ..()

/obj/item/bunsen/examine(mob/user, infix)
	. = ..()

	if(is_on)
		var/flame_desc

		if(strength > 0.7)
			flame_desc = "hot blue"
		else if(strength > 0.4)
			flame_desc = "steady"
		else
			flame_desc = "low yellow"

		. += "The burner is [SPAN_NOTICE("lit")] with a [SPAN_NOTICE(flame_desc)] flame"
	else
		. += "The burner is off"

	. += "The gas valve is set to [round(strength * 100)]%."

	if(!QDELETED(__container))
		. += SPAN_NOTICE("It contains \the [__container]")
	else
		. += "It's empty"

/obj/item/bunsen/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/reagent_containers/vessel/beaker))
		var/obj/item/reagent_containers/vessel/beaker/B = W

		if(!QDELETED(__container))
			to_chat(user, SPAN_NOTICE("There is already \the [__container] in \the [src]."))
			return

		if(!user.drop(W, src))
			return

		__container = W
		user.visible_message(
			SPAN_NOTICE("[user] puts \the [B] in \the [src]."),
			SPAN_NOTICE("You put \the [B] in \the [src].")
		)

		return
	else if(istype(W, /obj/item/thermometer))
		if(QDELETED(__container))
			return
		
		__container.dip_thermometer(user, W)

		return
	else if(isWrench(W))
		if(!is_there_building_allowed(src))
			to_chat(user, SPAN_WARNING("You can't wrench \the [src] here."))
			return

		user.visible_message(
			SPAN_NOTICE("[user] [anchored ? "unwrenches" : "wrenches"] \the [src]."),
			SPAN_NOTICE("You [anchored ? "unwrench" : "wrench"] \the [src].")
		)

		anchored = !anchored
		playsound(src, 'sound/items/Ratchet.ogg', 50, TRUE)

		return

	. = ..()

/obj/item/bunsen/attack_hand(mob/user)
	if(!QDELETED(__container))
		if(!user.pick_or_drop(__container))
			return
		
		__container = null

	. = ..()

/obj/item/bunsen/on_update_icon()
	. = ..()

	if(is_on)
		icon_state = "bunsen_on"
	else
		icon_state = "bunsen"

/obj/item/bunsen/proc/toggle_valve(mob/activator = null)
	if(!is_on && !anchored)
		if(!QDELETED(activator))
			to_chat(activator, SPAN_WARNING("Wrench \the [src] first"))
		
		return

	is_on = !is_on

	if(!QDELETED(activator))
		if(is_on)
			activator.visible_message(
				SPAN_NOTICE("[usr] turns on \the [src]."),
				SPAN_NOTICE("You turn on \the [src].")
			)
		else
			activator.visible_message(
				SPAN_NOTICE("[usr] turns off \the [src]."),
				SPAN_NOTICE("You turn off \the [src].")
			)

	update_icon()

/obj/item/bunsen/verb/toggle()
	set src in view(1)
	set category = "Object"
	set name = "Toggle"

	toggle_valve(usr)

/obj/item/bunsen/MiddleClick(mob/M)
	if(!Adjacent(M))
		. = ..()
		return

	usr = M
	change_strength()

/obj/item/bunsen/AltClick(mob/user)
	if(!Adjacent(user))
		. = ..()
		return
	
	toggle_valve(user)

/obj/item/bunsen/verb/change_strength()
	set src in view(1)
	set category = "Object"
	set name = "Change Strength"

	var/value = tgui_input_list(usr, "Flame strength:", "[src]", list("10%", "20%", "30%", "40%", "50%", "60%", "70%", "80%", "90%", "100%"))
	if(!value)
		return

	switch(value)
		if("10%")
			strength = 0.1
		if("20%")
			strength = 0.2
		if("30%")
			strength = 0.3
		if("40%")
			strength = 0.4
		if("50%")
			strength = 0.5
		if("60%")
			strength = 0.6
		if("70%")
			strength = 0.7
		if("80%")
			strength = 0.8
		if("90%")
			strength = 0.9
		if("100%")
			strength = 1.0

	usr.visible_message(
		SPAN_NOTICE("[usr] changes the flame strength to [strength * 100]%."),
		SPAN_NOTICE("You change the flame strength to [strength * 100]%.")
	)
