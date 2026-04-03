/obj/structure/iv_drip
	name = "\improper IV drip"
	icon = 'icons/obj/iv_drip.dmi'
	anchored = 0
	density = 0
	pull_slowdown = PULL_SLOWDOWN_TINY
	var/mob/living/carbon/human/attached
	var/mode = 1 // 1 is injecting, 0 is taking blood.
	var/obj/item/reagent_containers/beaker
	var/list/transfer_amounts = list(REM, 1, 2, 3, 5, 10)
	var/transfer_amount = 1

/obj/structure/iv_drip/verb/set_APTFT()
	set name = "Set IV transfer amount"
	set category = "Object"
	set src in range(1)
	if(!istype(usr, /mob/living))
		to_chat(usr, SPAN_WARNING("You can't do that."))
		return
	var/N = input("Amount per transfer from this:","[src]") as null|anything in transfer_amounts
	if(N)
		transfer_amount = N

/obj/structure/iv_drip/on_update_icon()
	if(attached)
		icon_state = "hooked"
	else
		icon_state = ""

	ClearOverlays()

/obj/structure/iv_drip/MouseDrop(over_object, src_location, over_location)
	if(!CanMouseDrop(over_object))
		return

	if(attached)
		visible_message("\The [attached] is taken off \the [src]")
		attached = null
	else if(ishuman(over_object))
		visible_message("\The [usr] hooks \the [over_object] up to \the [src].")
		attached = over_object
		set_next_think(world.time)

	update_icon()

/obj/structure/iv_drip/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/reagent_containers))
		if(!QDELETED(src.beaker))
			to_chat(user, "There is already a reagent container loaded!")
			return
		if(!user.drop(W, src))
			return
		beaker = W
		to_chat(user, "You attach \the [W] to \the [src].")
		update_icon()
	else
		return ..()

/obj/structure/iv_drip/Destroy()
	attached = null
	qdel(beaker)
	beaker = null
	. = ..()

/obj/structure/iv_drip/attack_hand(mob/user as mob)
	if(beaker)
		beaker.dropInto(loc)
		beaker = null
		update_icon()
	else
		return ..()

/obj/structure/iv_drip/AltClick(mob/user)
	return set_APTFT()

/obj/structure/iv_drip/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle IV Mode"
	set src in view(1)

	if(!istype(usr, /mob/living))
		to_chat(usr, SPAN_WARNING("You can't do that."))
		return

	if(usr.incapacitated())
		return

	mode = !mode
	to_chat(usr, "The IV drip is now [mode ? "injecting" : "taking blood"].")

/obj/structure/iv_drip/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) > 2)
		return

	if(mode)
		. += "The IV drip is set to inject [transfer_amount] ml of chemicals per second."
	else
		. += "The IV drip is set to siphon [transfer_amount] ml of blood per second."

	. += SPAN_NOTICE("No chemicals are attached.")

	. += SPAN_NOTICE("[attached ? attached : "No one"] is hooked up to it.")
