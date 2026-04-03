
/obj/item/reagent_containers/vessel/can
	name = "tin can"
	desc = "It opens, but never closes."
	matter = list(MATERIAL_STEEL = 500)

	volume = 0.330 LITERS
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = "25;30;50;60;100;150;330"

	atom_flags = 0 //starts closed
	lid_type = /datum/vessel_lid/can
	icon = 'icons/obj/reagent_containers/cans.dmi'
	force = 6.0
	mod_weight = 0.65
	mod_reach = 0.25
	mod_handy = 0.5
	unacidable = FALSE
	var/trash = null
	drop_sound = SFX_DROP_SODACAN
	pickup_sound = SFX_PICKUP_SODACAN
