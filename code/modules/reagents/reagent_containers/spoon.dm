/obj/item/reagent_containers/spoon
	name = "measuring spoon"
	desc = "A small spoon. Perfect for precise measurements."
	icon = 'icons/chemistry.dmi'
	icon_state = "spoon"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "1;2;3;4;5"
	volume = 0.005 LITERS
	bottom_area = 0.000028 METERS

	drop_sound = SFX_DROP_GLASSSMALL
	pickup_sound = SFX_PICKUP_GLASSSMALL

/obj/item/reagent_containers/spoon/examine(mob/user, infix)
	. = ..()

	. += "Can hold up to <b>[round(volume * 1000, 1)]</b> ml."

	if(!Adjacent(user))
		return

	var/used_volume = get_used_volume()

	if(used_volume > 0.0)
		var/list/phases = list()

		if(Z_CHEM_GET_LIQUID_PHASES(src) > 0)
			phases += "liquid"
		if(Z_CHEM_GET_SOLID_PHASES(src) > 0)
			phases += "solid"

		if(length(phases))
			. += SPAN_NOTICE("It contains <b>[round(used_volume * 1000, 1)]</b>ml of [phases.Join(" and ")].")
		else
			. += SPAN_NOTICE("It is empty.")
	else
		. += SPAN_NOTICE("It is empty.")

/obj/item/reagent_containers/spoon/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return

	if(!istype(target, /obj/item/reagent_containers))
		return

	if(!target.is_open_container())
		to_chat(user, SPAN_WARNING("\The [target] is closed."))
		return

	// Spoon has contents - pour into target
	if(!is_empty())
		standard_pour_into(user, target)
		return

	// Spoon is empty - try to fill from target
	if(!Z_CHEM_HAS_CONTENTS(target))
		to_chat(user, SPAN_NOTICE("\The [target] is empty."))
		return

	var/to_transfer = amount_per_transfer_from_this / 1000
	var/transferred = Z_CHEM_POUR(target, src, to_transfer, volume)

	if(transferred <= 0.0)
		to_chat(user, SPAN_NOTICE("There is no more room in \the [name]."))
		return

	playsound(src, 'sound/effects/using/bottles/transfer1.ogg', 50, FALSE)
	to_chat(user, SPAN_NOTICE("You fill \the [name] with [round(transferred * 1000, 1)] ml of the solution from \the [target]."))

	update_icon()
	target.update_icon()
