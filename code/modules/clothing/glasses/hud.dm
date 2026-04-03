// HUD Lenses
/obj/item/device/hudlenses
	name = "HUD lenses"
	desc = "A set of attachable lenses for HUDs."
	icon = 'icons/obj/hud_modules.dmi'
	icon_state = ""
	item_state = ""
	w_class = ITEM_SIZE_TINY

/obj/item/device/hudlenses/proc/attach_lenses(obj/item/clothing/glasses/hud/H)
	if(!H)
		return 0
	forceMove(H)
	H.lenses = src
	return 1

/obj/item/device/hudlenses/proc/detach_lenses(obj/item/clothing/glasses/hud/H)
	if(!H)
		return
	dropInto(get_turf(H))
	H.lenses = null

/obj/item/device/hudlenses/prescription
	name = "HUD prescription lenses"
	desc = "A set of attachable prescription lenses for HUDs."
	icon = 'icons/obj/hud_modules.dmi'
	icon_state = "prescription"

/obj/item/device/hudlenses/prescription/attach_lenses(obj/item/clothing/glasses/hud/H)
	. = ..()
	if(!.)
		return 0
	H.prescription = 7

/obj/item/device/hudlenses/prescription/detach_lenses(obj/item/clothing/glasses/hud/H)
	if(!H)
		return
	H.prescription = initial(H.prescription)
	..()

/obj/item/device/hudlenses/sunshield
	name = "HUD sunshield lenses"
	desc = "A set of attachable sunshield lenses for HUDs."
	icon = 'icons/obj/hud_modules.dmi'
	icon_state = "sunshield"

/obj/item/device/hudlenses/sunshield/attach_lenses(obj/item/clothing/glasses/hud/H)
	. = ..()
	if(!.)
		return 0
	H.cumulative_flash_protection++

/obj/item/device/hudlenses/sunshield/detach_lenses(obj/item/clothing/glasses/hud/H)
	if(!H)
		return
	H.cumulative_flash_protection--
	..()

// Finally HUDs themselves
/obj/item/clothing/glasses/hud
	name = "HUD"
	desc = "A HUD."
	gender = NEUTER
	icon_state = "hud_standard"
	item_state = "hud_standard"
	item_state_slots = list(
		slot_l_hand_str = "sunglasses",
		slot_r_hand_str = "sunglasses"
		)
	origin_tech = list(TECH_MATERIAL = 2)
	action_button_name = "Toggle HUD"
	toggleable = TRUE
	electric = TRUE
	active = FALSE
	var/hud_name = ""
	var/hud_icon = ""
	var/obj/item/device/hudlenses/lenses = null
	var/cumulative_flash_protection = FLASH_PROTECTION_NONE
	var/sec_hud = FALSE
	var/med_hud = FALSE

/obj/item/clothing/glasses/hud/examine(mob/user, infix)
	. = ..()

	if(lenses)
		. += "It has [lenses] installed."

/obj/item/clothing/glasses/hud/Initialize()
	. = ..()
	icon_state = "hud_[hud_icon]"
	item_state = "hud_[hud_icon]"
	if(ispath(lenses))
		lenses = new lenses()
		lenses.attach_lenses(src)

/obj/item/clothing/glasses/hud/Destroy()
	QDEL_NULL(lenses)
	return ..()

/obj/item/clothing/glasses/hud/process_hud(mob/M)
	if(sec_hud)
		process_sec_hud(M, 1)
	if(med_hud)
		process_med_hud(M, 1)

/obj/item/clothing/glasses/hud/on_update_icon()
	ClearOverlays()
	if(lenses)
		AddOverlays(OVERLAY(icon, "[hud_icon]_[lenses.icon_state]", alpha))

/obj/item/clothing/glasses/hud/attackby(obj/item/W, mob/user)
	if(isScrewdriver(W))
		if(lenses)
			lenses.detach_lenses(src)
			update_icon()
			update_clothing_icon()
			user.update_action_buttons()
			return
		to_chat(user, SPAN("notice", "\The [src] has no optical matrix installed."))
		return

	if(istype(W, /obj/item/device/hudlenses))
		if(lenses)
			to_chat(user, SPAN("notice", "\The [src] already has [lenses] installed."))
			return
		if(one_eyed)
			to_chat(user, SPAN("notice", "\The [W] cannot be attached to \the [src]."))
			return
		if(active)
			to_chat(user, SPAN("notice", "You must deactivate the optical matrix first."))
			return
		if(user.drop(W))
			var/obj/item/device/hudlenses/H = W
			H.attach_lenses(src)
			to_chat(user, SPAN("notice", "You install \the [H] into \the [src]."))
			sound_to(user, sound(deactivation_sound, volume = 50))
			update_clothing_icon()
			user.update_action_buttons()

	else
		..()

/obj/item/clothing/glasses/hud/standard
	name = "goggles HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	icon_state = "hud_standard"
	item_state = "hud_standard"
	hud_name = "goggles"
	hud_icon = "standard"

/obj/item/clothing/glasses/hud/dual
	name = "dual HUD"
	desc = "Old-fashioned heads-up display glasses."
	icon_state = "hud_standard"
	item_state = "hud_standard"
	hud_name = "dual"
	hud_icon = "dual"

/obj/item/clothing/glasses/hud/monoglass
	name = "clear HUD"
	desc = "Big and rimless HUD mono glasses."
	icon_state = "hud_monoglass"
	item_state = "hud_monoglass"
	hud_name = "clear"
	hud_icon = "monoglass"

/obj/item/clothing/glasses/hud/scanners
	name = "goggles HUD"
	desc = "Heavy and oddly shaped pair of HUD goggles."
	icon_state = "hud_scanners"
	item_state = "hud_scanners"
	hud_name = "goggles"
	hud_icon = "scanners"

/obj/item/clothing/glasses/hud/glasses
	name = "glasses HUD"
	desc = "HUD designed to look like a totally normal pair of glasses."
	icon_state = "hud_glasses"
	item_state = "hud_glasses"
	hud_name = "glasses"
	hud_icon = "glasses"

/obj/item/clothing/glasses/hud/aviators
	name = "aviators HUD"
	desc = "A pair of HUD aviators."
	icon_state = "hud_aviators"
	item_state = "hud_aviators"
	hud_name = "aviators"
	hud_icon = "aviators"

/obj/item/clothing/glasses/hud/visor
	name = "visor HUD"
	desc = "A rather retrofuturistic visor with an inbuilt HUD."
	icon_state = "hud_visor"
	item_state = "hud_visor"
	hud_name = "visor"
	hud_icon = "visor"

/obj/item/clothing/glasses/hud/shades
	name = "clip-on HUD"
	desc = "A weird pair of HUD glasses. Perhaps, you've never asked for these."
	icon_state = "hud_shades"
	item_state = "hud_shades"
	hud_name = "clip-on"
	hud_icon = "shades"

/obj/item/clothing/glasses/hud/one_eyed
	one_eyed = TRUE
	body_parts_covered = NO_BODYPARTS // Covering one eye isn't enough to protect you from eye-forking
	var/flipped = FALSE // Indicates left or right eye; FALSE = on the left

/obj/item/clothing/glasses/hud/one_eyed/verb/flip_patch()
	set name = "Flip HUD"
	set category = "Object"
	set src in usr

	if(usr.stat || usr.restrained())
		return

	flipped = !flipped
	if(flipped)
		hud_icon = "[initial(hud_icon)]_r"
	else
		hud_icon = "[initial(hud_icon)]"
	icon_state = "hud_[hud_icon]"
	item_state = "hud_[hud_icon]"
	to_chat(usr, "You flip \the [src] to cover the [src.flipped ? "left" : "right"] eye.")
	update_icon()
	update_clothing_icon()

/obj/item/clothing/glasses/hud/one_eyed/oneye
	name = "over-eye HUD"
	desc = "A small over-eye screen with an inbuilt HUD."
	icon_state = "hud_oneye"
	item_state = "hud_oneye"
	hud_name = "over-eye"
	hud_icon = "oneye"

/obj/item/clothing/glasses/hud/one_eyed/patch
	name = "patch HUD"
	desc = "A heads-up display that connects directly to the optical nerve of the user, replacing the need for that useless eyeball."
	icon_state = "hud_patch"
	item_state = "hud_patch"
	hud_name = "patch"
	hud_icon = "patch"

/obj/item/clothing/glasses/hud/plain
	active = TRUE
	action_button_name = null

/obj/item/clothing/glasses/hud/plain/Initialize()
	. = ..()
	icon_state = initial(icon_state)
	item_state = initial(item_state)

/obj/item/clothing/glasses/hud/plain/attack_self(mob/user)
	return

/obj/item/clothing/glasses/hud/plain/on_update_icon()
	return

/obj/item/clothing/glasses/hud/psychoscope
	name = "psychoscope"
	desc = "An old experimental glasses with a strange design."
	icon_state = "psychoscope_off"
	item_state = "psychoscope_off"
	hud_name = "psychoscope"
	activation_sound = 'sound/effects/psychoscope/psychoscope_on.ogg'
	w_class = ITEM_SIZE_NORMAL
	deactivation_sound = null
	use_alt_layer = TRUE

/obj/item/clothing/glasses/hud/psychoscope/on_update_icon()
	if(active)
		icon_state = "psychoscope_on"
		item_state = "psychoscope_on"
	else
		icon_state = "psychoscope_off"
		item_state = "psychoscope_off"

/obj/item/clothing/glasses/hud/psychoscope/Initialize()
	. = ..()

	icon_state = "psychoscope_off"
	item_state = "psychoscope_off"
