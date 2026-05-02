
/obj/item/reagent_containers/vessel/beaker
	name = "beaker"
	desc = "A 250 ml beaker."
	icon = 'icons/obj/reagent_containers/chemical.dmi'
	icon_state = "beaker"
	item_state = null
	center_of_mass = "x=17;y=10"
	force = 5.0
	mod_weight = 0.5
	mod_reach = 0.25
	mod_handy = 0.45
	matter = list(MATERIAL_GLASS = 2500)
	brittle = TRUE
	precise_measurement = TRUE

	volume = 0.25 LITERS
	bottom_area = 0.00282
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = "10;15;25;30;50;60;100;150;250;300" // Quite precise, but still requires syringes/droppers/vials for precise transfer.

	label_icon = TRUE
	overlay_icon = TRUE
	filling_states = "5;10;25;50;75;80;100"
	lid_type = /datum/vessel_lid/lid
	drop_sound = SFX_DROP_HELMET
	pickup_sound = SFX_PICKUP_HELMET

/obj/item/reagent_containers/vessel/beaker/large
	name = "large beaker"
	desc = "A 500 ml beaker."
	icon_state = "beakerlarge"
	center_of_mass = "x=17;y=10"
	force = 6.5
	mod_weight = 0.65
	mod_reach = 0.3
	mod_handy = 0.45
	matter = list(MATERIAL_GLASS = 5000)

	volume = 0.5 LITER
	bottom_area = 0.00441
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = "10;15;25;30;50;60;100;150;250;300;600"

	override_lid_state = LID_OPEN

/obj/item/reagent_containers/vessel/beaker/large/get_storage_cost()
	return ..() * 1.5

/obj/item/reagent_containers/vessel/beaker/vial
	name = "vial"
	desc = "A small 5 ml glass vial."
	icon_state = "vial"
	center_of_mass = "x=16;y=10"
	force = 2.5
	mod_weight = 0.35
	mod_reach = 0.2
	mod_handy = 0.4
	matter = list(MATERIAL_GLASS = 1250)

	volume = 0.005 LITER
	bottom_area = 0.00028
	w_class = ITEM_SIZE_TINY
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = "1;5;10;15;25;30;50"

	override_lid_state = LID_OPEN
	lid_type = /datum/vessel_lid/cork
