//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!

/obj/item/clothing/head/helmet/space
	name = "Space helmet"
	icon_state = "space"
	item_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	item_flags = ITEM_FLAG_STOPPRESSUREDAMAGE | ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_AIRTIGHT
	flags_inv = BLOCKHAIR
	permeability_coefficient = 0
	armor = list(melee = 40, bullet = 10, laser = 35,energy = 15, bomb = 0, bio = 100)
	coverage = 1.0
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = HEAD|FACE|EYES
	visor_body_parts_covered = NO_BODYPARTS
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
	center_of_mass = null
	randpixel = 0
	species_restricted = list("exclude", SPECIES_DIONA, "Xenomorph")
	flash_protection = FLASH_PROTECTION_MAJOR

	var/obj/machinery/camera/camera

	action_button_name = "Toggle Helmet Light"
	light_overlay = "helmet_light"
	brightness_on = 4
	on = 0
	rad_resist_type = /datum/rad_resist/space_gear

/obj/item/clothing/suit/space
	name = "Space suit"
	desc = "A suit that protects against low pressure environments."
	icon_state = "space"
	item_state = "space"
	w_class = ITEM_SIZE_LARGE//large item
	gas_transfer_coefficient = 0
	permeability_coefficient = 0
	item_flags = ITEM_FLAG_STOPPRESSUREDAMAGE | ITEM_FLAG_THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/tank/emergency,/obj/item/device/suit_cooling_unit)
	armor = list(melee = 20, bullet = 10, laser = 30,energy = 15, bomb = 0, bio = 100)
	coverage = 1.0
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
	center_of_mass = null
	randpixel = 0
	species_restricted = list("exclude", SPECIES_DIONA, "Xenomorph")
	valid_accessory_slots = list(ACCESSORY_SLOT_INSIGNIA)
