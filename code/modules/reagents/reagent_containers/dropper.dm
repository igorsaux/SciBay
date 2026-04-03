/obj/item/reagent_containers/dropper
	name = "dropper"
	desc = "A dropper. Transfers up to 5 ml."
	icon = 'icons/chemistry.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "1;2;3;4;5"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	volume = 0.005 LITERS
	bottom_area = 0.000028 METERS

	drop_sound = SFX_DROP_GLASSSMALL
	pickup_sound = SFX_PICKUP_GLASSSMALL

/obj/item/reagent_containers/dropper/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return
	
	var/obj/item/reagent_containers/C = target

	if(!istype(C))
		return

	if(!C.is_open_container())
		to_chat(user, SPAN_NOTICE("\The [target] is closed."))
		return

	var/liquids_volume = get_liquids_volume()

	if(liquids_volume)
		var/to_transfer = amount_per_transfer_from_this / 1000

		var/liquids_trans = Z_CHEM_TRANSFER_LIQUID_VOLUME(src, C, to_transfer, C.volume)
		ASSERT(liquids_trans != null)

		if(liquids_trans <= 0.0)
			to_chat(user, SPAN_NOTICE("There is no more room in \the [target]."))
			return TRUE

		to_chat(user, SPAN_NOTICE("You transfer [round(liquids_trans * 1000, 1)] ml of the solution."))
		update_icon()
	else
		var/to_transfer = amount_per_transfer_from_this / 1000

		var/liquids_trans = Z_CHEM_TRANSFER_LIQUID_VOLUME(C, src, to_transfer, volume)
		ASSERT(liquids_trans != null)

		if(liquids_trans <= 0.0)
			to_chat(user, SPAN_NOTICE("There is no liquids in \the [target]."))
			return

		to_chat(user, SPAN_NOTICE("You fill \the [src] with [round(liquids_trans * 1000, 1)] ml of the solution."))
		update_icon()

	return

/obj/item/reagent_containers/dropper/update_icon()
	var/volume = get_liquids_volume()

	if(volume > 0.0)
		icon_state = "dropper1"
	else
		icon_state = "dropper0"

/obj/item/reagent_containers/dropper/industrial
	name = "industrial dropper"
	desc = "A larger dropper. Transfers up to 10 ml."
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "1;2;3;4;5;6;7;8;9;10"
	volume = 10
