// Medium

/obj/item/reagent_containers/vessel/bottle/chemical/dichloromethane
	start_label = "dichloromethane (99.9%)"
	override_lid_state = LID_CLOSED
	startswith = alist(
		Z_MOL_DICHLOROMETHANE = 0.4995 LITERS,
		Z_MOL_OXIDANE = 0.0005 LITERS,
	)

/obj/item/reagent_containers/vessel/bottle/chemical/calcium_carbonate
	start_label = "calcium carbonate"
	override_lid_state = LID_CLOSED
	startswith = alist(
		Z_MOL_CALCIUM_CARBONATE = list(0.369 LITERS, 1e-5)
	)

/obj/item/reagent_containers/vessel/bottle/chemical/graphite
	start_label = "graphite"
	override_lid_state = LID_CLOSED
	startswith = alist(
		Z_MOL_GRAPHITE = list(0.4425 LITERS, 2.5e-5)
	)

/obj/item/reagent_containers/vessel/bottle/chemical/sodium_chloride
	start_label = "sodium chloride"
	override_lid_state = LID_CLOSED
	startswith = alist(
		Z_MOL_SODIUM_CHLORIDE = list(0.463 LITERS, 5e-4)
	)

/obj/item/reagent_containers/vessel/bottle/chemical/disodium_sulfate
	start_label = "disodium sulfate"
	override_lid_state = LID_CLOSED
	startswith = alist(
		Z_MOL_DISODIUM_SULFATE = list(0.3731 LITERS, 1.5e-4)
	)

/obj/item/reagent_containers/vessel/bottle/chemical/barium_sulfate
	start_label = "barium sulfate"
	override_lid_state = LID_CLOSED
	startswith = alist(
		Z_MOL_BARIUM_SULFATE = list(0.22 LITERS, 1e-5)
	)

// Big

/obj/item/reagent_containers/vessel/bottle/chemical/big/ethanol
	start_label = "ethanol 95%"
	override_lid_state = LID_CLOSED
	startswith = alist(
		Z_MOL_ETHANOL = 0.95 LITERS,
		Z_MOL_OXIDANE = 0.05 LITERS
	)

/obj/item/reagent_containers/vessel/bottle/chemical/big/acetic_acid
	start_label = "acetic acid 70%"
	override_lid_state = LID_CLOSED
	startswith = alist(
		Z_MOL_ACETIC_ACID = 0.6999 LITERS,
		Z_MOL_OXIDANE = 0.2999 LITERS
	)

/obj/item/reagent_containers/vessel/bottle/chemical/big/water
	start_label = "distilled water"
	override_lid_state = LID_CLOSED
	startswith = alist(
		Z_MOL_OXIDANE = 1.0 LITERS
	)
