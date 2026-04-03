
/obj/structure/table/CanPass(atom/movable/mover, turf/target)
	if(flipped == 1)
		if(get_dir(loc, target) == dir)
			return !density
		else
			return TRUE
	if(istype(mover) && mover.pass_flags & PASS_FLAG_TABLE)
		return TRUE
	var/obj/structure/table/T = (locate() in get_turf(mover))
	return (T && !T.flipped) 	//If we are moving from a table, check if it is flipped.
								//If the table we are standing on is not flipped, then we can move freely to another table.

/obj/structure/table/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.pass_flags & PASS_FLAG_TABLE)
		return 1
	if(flipped==1)
		if(get_dir(loc, target) == dir)
			return !density
		else
			return 1
	return 1


/obj/structure/table/MouseDrop_T(obj/O, mob/living/user, params)
	for(var/obj/possible_blocker in get_turf(src))
		if(possible_blocker.atom_flags & ATOM_FLAG_FULLTILE_OBJECT)
			return

	if(can_reinforce && (!user.stat) && istype(O, /obj/item/stack/material) && user.has_in_hands(O))
		reinforce_table(O, user)
	else if(user.lying && !user.stat && !user.buckled && (user.loc != loc) && can_be_crawled_under())
		do_crawl(user)
	else if(!slide_object(O, user, params))
		return ..()

/obj/structure/table/attack_hand(mob/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species?.can_shred(H))
			user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
			user.do_attack_animation(src)
			shake_animation(stime = 1)
			user.visible_message(SPAN("danger", "[user] hacks through \the [src]!"))
			playsound(loc, 'sound/effects/deskslam.ogg', 50, 1)
			throw_contents_around(ITEM_SIZE_HUGE, 50)
			take_damage(reinforced ? 10 : 20)
			return
	if(user.a_intent == I_HURT)
		src.add_fingerprint(user)
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		playsound(loc, 'sound/effects/deskslam.ogg', 50, 1)
		user.do_attack_animation(src)
		user.visible_message(SPAN("warning", "[user] slams \the [src]!</span>"))
		throw_contents_around(ITEM_SIZE_NORMAL, 25)
		return
	..()

/obj/structure/table/attackby(obj/item/W, mob/user, click_params)
	if (!W) return

	// Handle harm intent grabbing/tabling.
	if(istype(W, /obj/item/grab) && get_dist(src,user)<2)
		var/obj/item/grab/G = W
		if (istype(G.affecting, /mob/living/carbon/human))
			var/obj/occupied = turf_is_crowded()
			if(occupied)
				to_chat(user, "<span class='danger'>There's \a [occupied] in the way.</span>")
				return

			if(G.force_danger())
				G.assailant.next_move = world.time + 13 //also should prevent user from triggering this repeatedly
				visible_message("<span class='warning'>[G.assailant] starts putting [G.affecting] on \the [src].</span>")
				if(!do_after(G.assailant, 13, luck_check_type = LUCK_CHECK_COMBAT))
					return FALSE

				if(!G) //check that we still have a grab
					return FALSE

				if(QDELETED(src))
					return FALSE

				G.affecting.forceMove(src.loc)
				G.affecting.Weaken(rand(1,4))
				G.affecting.Stun(1)
				visible_message("<span class='warning'>[G.assailant] puts [G.affecting] on \the [src].</span>")
				G.affecting.break_all_grabs(G.assailant)
				qdel(W)
			else
				to_chat(user, "<span class='danger'>You need a better grip to do that!</span>")
			return

	if(W.loc != user) // This should stop mounted modules ending up outside the module.
		return

	if(can_plate && !material)
		to_chat(user, "<span class='warning'>There's nothing to put \the [W] on! Try adding plating to \the [src] first.</span>")
		return

	if(user.a_intent == I_HURT && W.force)
		W.set_cooldown()
		user.do_attack_animation(src)
		obj_attack_sound(W)
		shake_animation(stime = 1)
		var/dam_threshhold = 5.0
		if(material)
			dam_threshhold = max(10.0, material.integrity / 15)
		if(reinforced)
			dam_threshhold *= 2
		if(W.force >= dam_threshhold)
			user.visible_message(SPAN("danger", "[user] hits \the [src] with \the [W]!"))
			throw_contents_around(ITEM_SIZE_HUGE, 50)
			take_damage(W.force/1.5)
		else
			user.visible_message(SPAN("danger", "[user] hits \the [src] with \the [W], but it bounces off!"))
		return

	// Placing stuff on tables
	if(user.drop(W, loc))
		auto_align(W, click_params)
		return 1

	return

/*
Automatic alignment of items to an invisible grid, defined by CELLS and CELLSIZE, defined in code/__defines/misc.dm.
Since the grid will be shifted to own a cell that is perfectly centered on the turf, we end up with two 'cell halves'
on edges of each row/column.
Each item defines a center_of_mass, which is the pixel of a sprite where its projected center of mass toward a turf
surface can be assumed. For a piece of paper, this will be in its center. For a bottle, it will be (near) the bottom
of the sprite.
auto_align() will then place the sprite so the defined center_of_mass is at the bottom left corner of the grid cell
closest to where the cursor has clicked on.
Note: This proc can be overwritten to allow for different types of auto-alignment.
*/
/obj/item/var/center_of_mass = "x=16;y=16" //can be null for no exact placement behaviour
/obj/structure/table/proc/auto_align(obj/item/W, click_params)
	// If item is anchored, we can't move it.
	if(W.anchored)
		return
	if (!W.center_of_mass) // Clothing, material stacks, generally items with large sprites where exact placement would be unhandy.
		W.pixel_x = rand(-W.randpixel, W.randpixel)
		W.pixel_y = rand(-W.randpixel, W.randpixel)
		W.pixel_z = 0
		return

	if (!click_params)
		return

	var/list/click_data = params2list(click_params)
	if (!click_data["icon-x"] || !click_data["icon-y"])
		return

	// Calculation to apply new pixelshift.
	var/mouse_x = text2num(click_data["icon-x"])-1 // Ranging from 0 to 31
	var/mouse_y = text2num(click_data["icon-y"])-1

	var/cell_x = Clamp(round(mouse_x/CELLSIZE), 0, CELLS-1) // Ranging from 0 to CELLS-1
	var/cell_y = Clamp(round(mouse_y/CELLSIZE), 0, CELLS-1)

	var/list/center = cached_key_number_decode(W.center_of_mass)

	W.pixel_x = (CELLSIZE * (cell_x + 0.5)) - center["x"]
	W.pixel_y = (CELLSIZE * (cell_y + 0.5)) - center["y"]
	W.pixel_z = 0

/obj/structure/table/rack/auto_align(obj/item/W, click_params)
	if(W && !W.center_of_mass)
		..(W)

	var/i = -1
	for (var/obj/item/I in get_turf(src))
		if (I.anchored || !I.center_of_mass)
			continue
		i++
		I.pixel_x = max(3-i*3, -3) + 1 // There's a sprite layering bug for 0/0 pixelshift, so we avoid it.
		I.pixel_y = max(4-i*4, -4) + 1
		I.pixel_z = 0
