/obj/item/reagent_containers/vessel/spoon
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
	precise_measurement = TRUE
	lid_type = null
