// Generic damage proc (metroids and monkeys).
/atom/proc/attack_generic(mob/user as mob)
	return 0

/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(atom/A, proximity)
	if (machine_visual)
		return

	if(!..())
		return

	// Special glove functions:
	// If the gloves do anything, have them return TRUE to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(istype(G) && G.Touch(A,1))
		return

	A.attack_hand(src)

/atom/proc/attack_hand(mob/user as mob)
	return

/mob/living/carbon/human/RestrainedClickOn(atom/A)
	return

/mob/living/carbon/human/RangedAttack(atom/A)
	//Climbing up open spaces
	if((istype(A, /turf/simulated/floor) || istype(A, /turf/unsimulated/floor) || istype(A, /obj/structure/lattice) || istype(A, /obj/structure/catwalk)) && isturf(loc) && shadow && !is_physically_disabled()) //Climbing through openspace
		var/turf/T = get_turf(A)
		var/turf/above = shadow.loc
		if(T.Adjacent(shadow) && above.CanZPass(src, UP)) //Certain structures will block passage from below, others not

			if(has_gravity() && !can_overcome_gravity())
				return

			visible_message("<span class='notice'>[src] starts climbing onto \the [A]!</span>", "<span class='notice'>You start climbing onto \the [A]!</span>")
			shadow.visible_message("<span class='notice'>[shadow] starts climbing onto \the [A]!</span>")
			if(do_after(src, 50, A))
				visible_message("<span class='notice'>[src] climbs onto \the [A]!</span>", "<span class='notice'>You climb onto \the [A]!</span>")
				shadow.visible_message("<span class='notice'>[shadow] climbs onto \the [A]!</span>")
				src.Move(T)
			else
				visible_message("<span class='warning'>[src] gives up on trying to climb onto \the [A]!</span>", "<span class='warning'>You give up on trying to climb onto \the [A]!</span>")
				shadow.visible_message("<span class='warning'>[shadow] gives up on trying to climb onto \the [A]!</span>")
			return

	if(!gloves && !mutations.len) return
	var/obj/item/clothing/gloves/G = gloves
	if(istype(G) && G.Touch(A,0)) // for magic gloves
		return

/mob/living/RestrainedClickOn(atom/A)
	return

/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/new_player/ClickOn()
	return
