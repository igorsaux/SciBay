/obj/effect/effect/water
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	mouse_opacity = 0
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GRILLE

/obj/effect/effect/water/New(loc)
	..()
	QDEL_IN(src, 15 SECONDS) // In case whatever made it forgets to delete it

/obj/effect/effect/water/proc/set_color() // Call it after you move reagents to it
	return

/obj/effect/effect/water/proc/set_up(turf/target, step_count = 5, delay = 5)
	if(!target)
		return
	for(var/i = 1 to step_count)
		if(!loc)
			return
		step_towards(src, target)
		sleep(delay)
	sleep(10)
	qdel(src)

/obj/effect/effect/water/Move(newloc, direct)
	var/turf/new_turf = newloc
	if(istype(new_turf) && new_turf.density)
		return FALSE

	. = ..()

//Used by spraybottles.
/obj/effect/effect/water/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	icon_state = ""
