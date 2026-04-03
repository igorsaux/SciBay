/decl/hierarchy/outfit/job/medical
	hierarchy_type = /decl/hierarchy/outfit/job/medical
	shoes = /obj/item/clothing/shoes/white
	pda_slot = slot_l_store

/decl/hierarchy/outfit/job/medical/New()
	..()
	BACKPACK_OVERRIDE_MEDICAL

/decl/hierarchy/outfit/job/medical/chemist
	name = OUTFIT_JOB_NAME("Chemist")
	uniform = /obj/item/clothing/under/rank/chemist
	suit = /obj/item/clothing/suit/storage/toggle/labcoat/chemist
	id_type = /obj/item/card/id/medical/chemist

/decl/hierarchy/outfit/job/medical/chemist/New()
	..()
	BACKPACK_OVERRIDE_CHEMISTRY
