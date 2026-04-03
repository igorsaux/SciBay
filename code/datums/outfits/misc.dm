/decl/hierarchy/outfit/standard_space_gear
	name = "Standard space gear"
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/helmet/space
	suit = /obj/item/clothing/suit/space
	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/tank/jetpack/oxygen
	mask = /obj/item/clothing/mask/breath
	flags = OUTFIT_HAS_JETPACK|OUTFIT_RESET_EQUIPMENT

/decl/hierarchy/outfit/soviet_soldier
	name = "Soviet soldier"
	uniform = /obj/item/clothing/under/soviet
	shoes = /obj/item/clothing/shoes/combat
	head = /obj/item/clothing/head/ushanka
	gloves = /obj/item/clothing/gloves/swat/combat
	back = /obj/item/storage/backpack/satchel

/decl/hierarchy/outfit/soviet_soldier/admiral
	name = "Soviet admiral"
	head = /obj/item/clothing/head/hgpiratecap
	glasses = /obj/item/clothing/glasses/hud/one_eyed/patch/thermal
	suit = /obj/item/clothing/suit/hgpirate

	id_slot = slot_wear_id
	id_type = /obj/item/card/id/centcom/station
	id_pda_assignment = "Admiral"

/decl/hierarchy/outfit/merchant
	name = "Merchant"
	shoes = /obj/item/clothing/shoes/black
	uniform = /obj/item/clothing/under/color/grey
	id_slot = slot_wear_id
	id_type = /obj/item/card/id/merchant
	pda_slot = slot_r_store
	id_pda_assignment = "Merchant"

/decl/hierarchy/outfit/merchant/vox
	name = "Merchant - Vox"
	shoes = /obj/item/clothing/shoes/jackboots/unathi
	suit = /obj/item/clothing/suit/armor/vox_scrap

/decl/hierarchy/outfit/clown
	name = "Clown"
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	uniform = /obj/item/clothing/under/rank/clown
	l_pocket = /obj/item/bikehorn
	flags = OUTFIT_HAS_BACKPACK|OUTFIT_RESET_EQUIPMENT

/decl/hierarchy/outfit/clown/New()
	..()
	backpack_overrides[/decl/backpack_outfit/backpack] = /obj/item/storage/backpack/clown
