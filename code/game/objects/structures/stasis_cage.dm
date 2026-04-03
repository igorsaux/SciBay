/obj/structure/stasis_cage
	name = "stasis cage"
	desc = "A high-tech animal cage, designed to keep contained fauna docile and safe."
	icon = 'icons/obj/crates.dmi'
	icon_state = "critter"
	density = 1
	pull_slowdown = PULL_SLOWDOWN_HEAVY

	var/mob/living/simple_animal/contained

/obj/structure/stasis_cage/Initialize()
	. = ..()

	var/mob/living/simple_animal/A = locate() in loc
	if(A)
		contain(A)

/obj/structure/stasis_cage/attack_hand(mob/user)
	release()

/obj/structure/stasis_cage/proc/contain(mob/living/simple_animal/animal)
	if(contained || !istype(animal))
		return

	contained = animal
	animal.forceMove(src)
	desc = initial(desc) + " \The [contained] is kept inside."

/obj/structure/stasis_cage/proc/release()
	if(!contained)
		return

	contained.dropInto(src)
	contained = null
	underlays.Cut()
	desc = initial(desc)

/obj/structure/stasis_cage/Destroy()
	release()

	return ..()
