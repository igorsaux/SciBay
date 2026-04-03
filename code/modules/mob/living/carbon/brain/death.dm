/mob/living/carbon/brain/death(gibbed)
	return ..(gibbed, "no message")

/mob/living/carbon/brain/gib(anim, do_gibs)
	if(istype(loc, /obj/item/organ/internal/cerebrum/brain))
		qdel(loc)//Gets rid of the brain item
	return ..(null, FALSE)
