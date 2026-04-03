/decl/hierarchy/outfit/job
	name = "Standard Gear"
	hierarchy_type = /decl/hierarchy/outfit/job

	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/black

	id_slot = slot_wear_id
	id_type = /obj/item/card/id/civilian
	pda_slot = slot_belt
	backpack_contents = list()

	flags = OUTFIT_HAS_BACKPACK

/decl/hierarchy/outfit/job/equip_id(mob/living/carbon/human/H)
	var/obj/item/card/id/C = ..()
	if(!C)
		return

	return C
