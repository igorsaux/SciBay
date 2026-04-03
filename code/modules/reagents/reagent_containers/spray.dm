/obj/item/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	item_flags = ITEM_FLAG_NO_BLUDGEON
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_range = 10
	amount_per_transfer_from_this = 25
	unacidable = 1 //plastic
	possible_transfer_amounts = "10;25" //Set to null instead of list, if there is only one.
	var/spray_size = 3
	var/list/spray_sizes = list(1,3)
	var/step_delay = 10 // lower is faster
	var/widespray = FALSE
	volume = 0.5 LITERS
	var/obj/item/reagent_containers/external_container = null // Using an external reagent container (i.e. backwear spray)

/obj/item/reagent_containers/spray/Initialize()
	. = ..()
	src.verbs -= /obj/item/reagent_containers/verb/set_APTFT

/obj/item/reagent_containers/spray/attack_self(mob/user)
	if(!possible_transfer_amounts)
		return
	amount_per_transfer_from_this = next_in_list(amount_per_transfer_from_this, cached_number_list_decode(possible_transfer_amounts))
	spray_size = next_in_list(spray_size, spray_sizes)
	to_chat(user, "<span class='notice'>You adjusted the pressure nozzle. You'll now use [amount_per_transfer_from_this] ml per spray.</span>")

//space cleaner
/obj/item/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	step_delay = 6

/obj/item/reagent_containers/spray/sterilizine
	name = "sterilizine"
	desc = "Great for hiding incriminating bloodstains and sterilizing scalpels."

/obj/item/reagent_containers/spray/hair_remover
	name = "hair remover"
	desc = "Very effective at removing hair, feathers, spines and horns."

/obj/item/reagent_containers/spray/hair_grower
	name = "hair grower"
	desc = "Very effective at growing hair."

/obj/item/reagent_containers/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by Uhang Inc., it fires a mist of condensed capsaicin to blind and down an opponent quickly."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "pepperspray"
	item_state = "pepperspray"
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = null
	volume = 75
	var/safety = 1
	step_delay = 1

/obj/item/reagent_containers/spray/pepper/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) <= 1)
		. += "The safety is [safety ? "on" : "off"]."

/obj/item/reagent_containers/spray/pepper/attack_self(mob/user)
	safety = !safety
	to_chat(usr, SPAN("notice", "You switch the safety [safety ? "on" : "off"]."))

/obj/item/reagent_containers/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/device.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = null
	volume = 0.1 LITERS

	drop_sound = SFX_DROP_HERB
	pickup_sound = SFX_PICKUP_HERB

/obj/item/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagent in a given area."
	icon = 'icons/obj/guns/gun.dmi'
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 3
	w_class = ITEM_SIZE_LARGE
	amount_per_transfer_from_this = 75
	possible_transfer_amounts = null
	volume = 1.5 LITERS
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3, TECH_ENGINEERING = 3)
	step_delay = 8
	widespray = TRUE

/obj/item/reagent_containers/spray/plantbgone
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon = 'icons/obj/hydroponics_items.dmi'
	icon_state = "plantbgone"
	item_state = "plantbgone"

/obj/item/reagent_containers/spray/plantbgone/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	..()

/obj/item/reagent_containers/spray/noreact
	name = "stasis spray"
	icon_state = "cleaner_noreact"
	desc = "The label says 'Finally, a use for that pesky experimental bluespace technology for the whole house to enjoy!'\n\
	A disclaimer towards the bottom states <span class = 'warning'>Warning: Do not use around the house, or in proximity of dogs|children|clowns</span>"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER|ATOM_FLAG_NO_REACT
	origin_tech = list(TECH_BLUESPACE = 3, TECH_MATERIAL = 5)
	possible_transfer_amounts = "50;100;250"
