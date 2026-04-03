/obj/item/storage/box/bloodpacks
	name = "IV bags box"
	desc = "This box contains IV bags."
	icon_state = "bloodbags"
	startswith = list(/obj/item/reagent_containers/ivbag = 7)

/obj/item/reagent_containers/ivbag
	name = "\improper IV bag"
	desc = "Flexible bag for IV injectors."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "empty"
	w_class = ITEM_SIZE_SMALL
	volume = 1.5 LITERS
	possible_transfer_amounts = "0.2;1;2;3;5;10;15"
	amount_per_transfer_from_this = REM
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	var/being_feed = FALSE
	var/vampire_marks = null
	var/mob/living/carbon/human/attached

	drop_sound = SFX_DROP_FOOD
	pickup_sound = SFX_PICKUP_FOOD

/obj/item/reagent_containers/ivbag/Destroy()
	attached = null
	. = ..()

/obj/item/reagent_containers/ivbag/examine(mob/user, infix)
	. = ..()

	. += "The [src] can hold up to <b>[volume]</b> ml."

/obj/item/reagent_containers/vessel/carton/get_storage_cost()
	if(w_class < ITEM_SIZE_NORMAL)
		return ..() * 1.5
	return ..()

/obj/item/reagent_containers/ivbag/examine(mob/user, infix)
	. = ..()

	if(vampire_marks)
		. += SPAN_WARNING("There are teeth marks on it.")

/obj/item/reagent_containers/ivbag/on_update_icon()
	ClearOverlays()
	AddOverlays(image('icons/obj/bloodpack.dmi', "top"))
	if(attached)
		AddOverlays(image('icons/obj/bloodpack.dmi', "dongle"))

/obj/item/reagent_containers/ivbag/MouseDrop(over_object, src_location, over_location)
	if(!CanMouseDrop(over_object))
		return
	if(!ismob(loc))
		return ..()
	if(attached)
		visible_message("\The [attached] is taken off \the [src]")
		attached = null
	else if(ishuman(over_object))
		visible_message(SPAN_WARNING("\The [usr] starts hooking \the [over_object] up to \the [src]."))
		if(do_after(usr, 30, , luck_check_type = LUCK_CHECK_MED))
			to_chat(usr, "You hook \the [over_object] up to \the [src].")
			attached = over_object
			set_next_think(world.time)
	update_icon()

/obj/item/reagent_containers/ivbag/nanoblood
	name = "\improper IV bag (nanoblood)"

/obj/item/reagent_containers/ivbag/blood
	name = "\improper IV bag (blood)"
	var/blood_type = null

/obj/item/reagent_containers/ivbag/blood/APlus
	blood_type = "A+"

/obj/item/reagent_containers/ivbag/blood/AMinus
	blood_type = "A-"

/obj/item/reagent_containers/ivbag/blood/BPlus
	blood_type = "B+"

/obj/item/reagent_containers/ivbag/blood/BMinus
	blood_type = "B-"

/obj/item/reagent_containers/ivbag/blood/OPlus
	blood_type = "O+"

/obj/item/reagent_containers/ivbag/blood/OMinus
	blood_type = "O-"

/obj/item/reagent_containers/ivbag/saline
	name = "\improper IV bag (saline)"
