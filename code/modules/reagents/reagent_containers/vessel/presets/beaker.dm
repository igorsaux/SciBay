// Vials

/obj/item/reagent_containers/vessel/beaker/vial/barium_dichloride
	start_label = "barium dichloride (99.9%)"
	override_lid_state = LID_CLOSED
	startswith = alist(
		Z_MOL_BARIUM_DICHLORIDE = list(0.001815 LITERS, 2e-4),
	)

/obj/item/storage/fancy/vials/barium_dichloride
	startswith = list(
		/obj/item/reagent_containers/vessel/beaker/vial/barium_dichloride = 6,
	)
