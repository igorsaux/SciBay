/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "densecrate"
	density = 1
	atom_flags = ATOM_FLAG_CLIMBABLE
	pull_slowdown = PULL_SLOWDOWN_HEAVY
	turf_height_offset = 22
	climb_delay = 4 SECONDS // It's tall AF.

/obj/structure/largecrate/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/largecrate/LateInitialize(mapload, ...)
	. = ..()
	if(mapload) // if it's the map loading phase, relevant items at the crate's loc are put in the contents
		add_think_ctx("store_contents_mapload", CALLBACK(src, nameof(.proc/store_contents)), world.time + 1 SECOND)

/obj/structure/largecrate/proc/store_contents()
	for(var/obj/I in loc)
		if(I.density || I.anchored || I == src || !I.simulated || QDELETED(I))
			continue
		if(istype(I, /obj/effect) || istype(I, /obj/random))
			continue
		I.forceMove(src)
	remove_think_ctx("store_contents_mapload")

/obj/structure/largecrate/attack_hand(mob/user)
	to_chat(user, "<span class='notice'>You need a crowbar to pry this open!</span>")
	return

/obj/structure/largecrate/attackby(obj/item/W, mob/user)
	if(isCrowbar(W))
		new /obj/item/stack/material/wood(src)
		var/turf/T = get_turf(src)
		for(var/atom/movable/AM in contents)
			if(AM.simulated) AM.forceMove(T)
		user.visible_message("<span class='notice'>[user] pries \the [src] open.</span>", \
							 "<span class='notice'>You pry open \the [src].</span>", \
							 "<span class='notice'>You hear splitting wood.</span>")
		qdel(src)
	else
		return attack_hand(user)
