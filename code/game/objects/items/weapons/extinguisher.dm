/obj/item/extinguisher
	name = "fire extinguisher"
	desc = "A traditional red fire extinguisher."
	icon = 'icons/obj/items.dmi'
	icon_state = "fire_extinguisher0"
	item_state = "fire_extinguisher"
	hitsound = 'sound/effects/fighting/smash.ogg'
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 15.0
	throwforce = 10
	mod_handy = 0.7
	mod_weight = 1.5
	mod_reach = 1.0
	w_class = ITEM_SIZE_LARGE
	throw_range = 10
	matter = list(MATERIAL_STEEL = 900)
	attack_verb = list("slammed", "whacked", "bashed", "thunked", "battered", "bludgeoned", "thrashed")

	var/spray_particles = 3
	var/spray_amount = 0.5 LITERS // ML of liquid per spray
	var/max_volume = 7.5 LITERS
	var/last_use = 1.0
	var/safety = 1
	var/sprite_name = "fire_extinguisher"
	var/external_source = FALSE
	var/spray_cooldown = 1.5 SECONDS

	drop_sound = SFX_DROP_GASCAN
	pickup_sound = SFX_PICKUP_GASCAN

/obj/item/extinguisher/mini
	name = "fire extinguisher"
	desc = "A light and compact fibreglass-framed model fire extinguisher."
	icon_state = "miniFE0"
	item_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	force = 7.5
	throwforce = 2
	mod_handy = 0.7
	mod_weight = 0.65
	mod_reach = 0.6
	armor_penetration = 5
	w_class = ITEM_SIZE_SMALL
	spray_amount = 0.25 LITERS
	max_volume = 2 LITERS
	sprite_name = "miniFE"
	matter = list(MATERIAL_STEEL = 500)

/obj/item/extinguisher/attack_self(mob/user)
	if(external_source)
		return
	safety = !safety
	src.icon_state = "[sprite_name][!safety]"
	src.desc = "The safety is [safety ? "on" : "off"]."
	to_chat(user, "The safety is [safety ? "on" : "off"].")
	return

/obj/item/extinguisher/proc/propel_object(obj/O, mob/user, movementdirection)
	if(O.anchored)
		return

	var/obj/structure/bed/chair/C
	if(istype(O, /obj/structure/bed/chair))
		C = O

	var/area/A = get_area(src)
	if(A.has_gravity) // No gravity? Your chair is a space ship then.
		if(C?.foldable)
			C.fold(null)
			return
		if(O.pull_slowdown > PULL_SLOWDOWN_MEDIUM)
			return // Too much friction, not enough wheels

	var/list/move_speed = list(1, 1, 1, 2, 2, 3)
	for(var/i in 1 to 6)
		if(C) C.propelled = (6-i)
		O.Move(get_step(user,movementdirection), movementdirection)
		sleep(move_speed[i])

	//additional movement
	for(var/i in 1 to 3)
		O.Move(get_step(user,movementdirection), movementdirection)
		sleep(3)
