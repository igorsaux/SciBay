
/obj/item/reagent_containers/rag
	name = "rag"
	desc = "For cleaning up messes, you suppose."
	w_class = ITEM_SIZE_TINY
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5"
	volume = 10
	item_flags = ITEM_FLAG_NO_BLUDGEON
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	unacidable = FALSE
	var/obj/item/stack/medical/bandage/BP

	var/on_fire = 0
	var/burn_time = 20 //if the rag burns for too long it turns to ashes

/obj/item/reagent_containers/rag/Initialize()
	. = ..()
	update_name()
	BP = new()

/obj/item/reagent_containers/rag/Destroy()
	QDEL_NULL(BP)
	return ..()

/obj/item/reagent_containers/rag/attack_self(mob/user as mob)
	if(on_fire)
		user.visible_message("<span class='warning'>\The [user] stamps out [src].</span>", "<span class='warning'>You stamp out [src].</span>")
		user.drop(src)
		extinguish()
	else
		remove_contents(user)

/obj/item/reagent_containers/rag/attackby(obj/item/W, mob/user)
	if(!on_fire && W.get_temperature_as_from_ignitor())
		ignite()
		if(on_fire)
			visible_message("<span class='warning'>\The [user] lights [src] with [W].</span>")
		else
			to_chat(user, "<span class='warning'>You manage to singe [src], but fail to light it.</span>")

	. = ..()
	update_name()

/obj/item/reagent_containers/rag/proc/update_name()
	return

/obj/item/reagent_containers/rag/on_update_icon()
	if(on_fire)
		icon_state = "raglit"
	else
		icon_state = "rag"

	var/obj/item/reagent_containers/vessel/bottle/B = loc
	if(istype(B))
		B.update_icon()

/obj/item/reagent_containers/rag/proc/remove_contents(mob/user, atom/trans_dest = null)
	return

/obj/item/reagent_containers/rag/proc/wipe_down(atom/A, mob/user)
	return

/obj/item/reagent_containers/rag/proc/default_attack(atom/target, mob/user)
	return

/obj/item/reagent_containers/rag/attack(atom/target, mob/user)
	if(isliving(target))
		var/mob/living/M = target
		if(on_fire)
			user.visible_message("<span class='danger'>\The [user] hits [target] with [src]!</span>",)
			user.do_attack_animation(src)
			M.IgniteMob()

		default_attack(target, user)

		return

	return ..()

/obj/item/reagent_containers/rag/afterattack(atom/A as obj|turf|area, mob/user as mob, proximity)
	if(!proximity)
		return

	if(!on_fire && istype(A) && (src in user))
		if(A.is_open_container() && !(A in user))
			remove_contents(user, A)
		else if(!ismob(A)) //mobs are handled in attack() - this prevents us from wiping down people while smothering them.
			wipe_down(A, user)
		return

/obj/item/reagent_containers/rag/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature >= (50 CELSIUS))
		ignite()
	if(exposed_temperature >= (900 CELSIUS))
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)

//rag must have a minimum of 2 units welder fuel and at least 80% of the reagents must be welder fuel.
//maybe generalize flammable reagents someday
/obj/item/reagent_containers/rag/proc/can_ignite()
	return FALSE

/obj/item/reagent_containers/rag/proc/ignite()
	if(on_fire)
		return
	if(!can_ignite())
		return

	set_next_think(world.time)
	set_light(0.5, 0.1, 2, 2, "#e38f46")
	on_fire = 1
	update_name()
	update_icon()

/obj/item/reagent_containers/rag/proc/extinguish()
	set_next_think(0)
	set_light(0)
	on_fire = 0

	//rags sitting around with 1 second of burn time left is dumb.
	//ensures players always have a few seconds of burn time left when they light their rag
	if(burn_time <= 5)
		visible_message("<span class='warning'>\The [src] falls apart!</span>")
		new /obj/effect/decal/cleanable/ash(get_turf(src))
		qdel(src)
	update_name()
	update_icon()

/obj/item/reagent_containers/rag/think()
	if(!can_ignite())
		visible_message("<span class='warning'>\The [src] burns out.</span>")
		extinguish()

	//copied from matches
	if(isliving(loc))
		var/mob/living/M = loc
		M.IgniteMob()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5)

	if(burn_time <= 0)
		new /obj/effect/decal/cleanable/ash(location)
		qdel(src)
		return

	update_name()
	burn_time--

	set_next_think(world.time + 1 SECOND)

/obj/item/reagent_containers/rag/get_temperature_as_from_ignitor()
	if(on_fire)
		return 2000
	return 0
