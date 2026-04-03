/obj/structure/closet/secure_closet/freezer/kitchen
	name = "kitchen cabinet"
	req_access = list(access_kitchen)

/obj/structure/closet/secure_closet/freezer/kitchen/WillContain()
	return list(
		/obj/item/reagent_containers/vessel/condiment/flour = 7,
		/obj/item/reagent_containers/vessel/condiment/sugar = 2
	)

/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()

/obj/structure/closet/secure_closet/freezer/meat
	name = "meat fridge"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_off = "fridgebroken"

/obj/structure/closet/secure_closet/freezer/meat/WillContain()
	return list(
	)

/obj/structure/closet/secure_closet/freezer/fridge
	name = "refrigerator"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_off = "fridgebroken"

/obj/structure/closet/secure_closet/freezer/fridge/WillContain()
	return list(
		/obj/item/reagent_containers/vessel/plastic/milk = 6,
		/obj/item/reagent_containers/vessel/plastic/soymilk = 4,
		/obj/item/storage/fancy/egg_box = 4
	)
