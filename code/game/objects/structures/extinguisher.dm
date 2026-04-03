#define MIN_EMAGGED_REAGENTS_VOLUME 10 MILLI LITERS
#define MAX_EMAGGED_REAGENTS_VOLUME 3 LITERS

/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_closed"
	anchored = TRUE
	density = FALSE
	/// Extinguisher stored in the cabinet.
	var/obj/item/extinguisher/has_extinguisher
	/// State of the cabinet's lid
	var/opened = FALSE
	/// Whether this cabinet can automatically refill extinguishers
	var/automatic_refill = TRUE
	/// Won't refill ff reagents that are not in this list.
	/// Tracks whether the refill process was interrupted by something.
	var/refill_interrupted = FALSE
	/// The amount of time this cabinet takes to refill extinguishers
	var/refill_duration = 30 SECONDS
	/// Whether this cabinet was emagged or not.
	var/emagged = FALSE

/obj/structure/extinguisher_cabinet/Initialize()
	. = ..()

	has_extinguisher = new /obj/item/extinguisher(src)

/obj/structure/extinguisher_cabinet/Destroy()
	QDEL_NULL(has_extinguisher)
	set_next_think(0)
	return ..()


/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.is_hand_usable())
			return

	if(has_extinguisher)
		if(!user.IsAdvancedToolUser(TRUE))
			to_chat(user, FEEDBACK_YOU_LACK_DEXTERITY)
			return

		user.pick_or_drop(has_extinguisher)
		to_chat(user, SPAN_NOTICE("You take [has_extinguisher] from [src]."))
		playsound(src.loc, 'sound/effects/extout.ogg', 50, 0)
		refill_interrupted = TRUE
		set_next_think(0)
		has_extinguisher = null
		opened = TRUE
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/AltClick(mob/user)
	if(CanPhysicallyInteract(user))
		opened = !opened
		update_icon()

/obj/structure/extinguisher_cabinet/on_update_icon()
	if(!opened)
		icon_state = "extinguisher_closed"
		return
	if(has_extinguisher)
		if(istype(has_extinguisher, /obj/item/extinguisher/mini))
			icon_state = "extinguisher_mini"
		else
			icon_state = "extinguisher_full"
	else
		icon_state = "extinguisher_empty"
