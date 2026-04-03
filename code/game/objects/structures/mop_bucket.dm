#define OXYLOS_PER_HEAD_DIP 10

/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	w_class = ITEM_SIZE_NORMAL
	atom_flags = ATOM_FLAG_CLIMBABLE
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	pull_slowdown = PULL_SLOWDOWN_TINY
	turf_height_offset = 14
	climb_delay = 1 SECONDS
	var/amount_per_transfer_from_this = 5	//shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/mopbucket/attackby(obj/item/I, mob/user)
	return

#undef OXYLOS_PER_HEAD_DIP
