
/obj/item/backwear/reagent/pepper
	name = "crowdbuster kit"
	desc = "A heavy backpack made of two pepper tanks and a retractable pepperspray nozzle, manufactured by Uhang Inc. Your best choice for killing them asthmatics!"
	icon_state = "pepper1"
	base_icon = "pepper"
	item_state = "backwear_pepper"
	hitsound = 'sound/effects/fighting/smash.ogg'
	gear_detachable = FALSE
	gear = /obj/item/reagent_containers/spray/chemsprayer/crowdbuster
	atom_flags = null
	origin_tech = list(TECH_ENGINEERING = 2)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_GLASS = 500)

/obj/item/backwear/reagent/pepper/resolve_grab_gear(mob/living/carbon/human/user)
	. = ..()
	if(. && gear)
		var/obj/item/reagent_containers/spray/chemsprayer/crowdbuster/C = gear
		C.external_container = src // Sadly it's safer and easier to do it this way since New/Initialize sequences are a shitmaze

/obj/item/reagent_containers/spray/chemsprayer/crowdbuster
	name = "crowdbuster"
	desc = "It fires a large cloud of condensed capsaicin to blind and down an opponent quickly."
	icon = 'icons/obj/backwear.dmi'
	icon_state = "crowdbuster0"
	item_state = "crowdbuster"
	possible_transfer_amounts = null
	volume = 0
	amount_per_transfer_from_this = 0.1 LITER
	step_delay = 1
	atom_flags = null
	slot_flags = null
	canremove = FALSE
	force_drop = TRUE
	unacidable = 1 //TODO: make these replaceable so we won't need such ducttaping
	matter = null
	var/obj/item/backwear/reagent/base_unit

/obj/item/reagent_containers/spray/chemsprayer/crowdbuster/New(newloc, obj/item/backwear/base)
	base_unit = base
	..(newloc)

/obj/item/reagent_containers/spray/chemsprayer/crowdbuster/Destroy() //it shouldn't happen unless the base unit is destroyed but still
	if(base_unit)
		if(base_unit.gear == src)
			base_unit.gear = null
			base_unit.update_icon()
		base_unit = null
	return ..()

/obj/item/reagent_containers/spray/chemsprayer/crowdbuster/dropped(mob/user)
	..()
	if(base_unit)
		base_unit.reattach_gear(user)

/obj/item/reagent_containers/spray/chemsprayer/crowdbuster/attack_self(mob/user)
	widespray = !widespray
	if(widespray)
		to_chat(user, "\The [src]'s nozzle is now set to wide spraying mode.")
		icon_state = "crowdbuster1"
	else
		to_chat(user, "\The [src]'s nozzle is now set to narrow spraying mode.")
		icon_state = "crowdbuster0"
