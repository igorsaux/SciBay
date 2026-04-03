/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	var/insert_anim = "bigscanner1"
	anchored = 1
	density = 1
	atom_flags = ATOM_FLAG_CLIMBABLE
	obj_flags = OBJ_FLAG_ANCHORABLE
	turf_height_offset = 15
	var/obj/item/copyitem = null	//what's in the copier!
	var/copies = 1	//how many copies to print!
	var/toner = 30 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!
	var/grayscale = TRUE //if FALSE it'll preserve colors at least on paper
	var/busy = FALSE

/obj/machinery/photocopier/Destroy()
	QDEL_NULL(copyitem)
	return ..()

/obj/machinery/photocopier/attack_hand(mob/user)
	user.set_machine(src)

	var/dat = "<meta charset=\"utf-8\">Photocopier<BR><BR>"
	if(copyitem)
		dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Item</a><BR>"
		if(toner)
			dat += "<a href='byond://?src=\ref[src];copy=1'>Copy</a><BR>"
			dat += "Printing: [copies] copies."
			dat += "<a href='byond://?src=\ref[src];min=1'>-</a> "
			dat += "<a href='byond://?src=\ref[src];add=1'>+</a><BR><BR>"
	else if(toner)
		dat += "Please insert something to copy.<BR><BR>"
	if(istype(user,/mob/living/silicon))
		dat += "<a href='byond://?src=\ref[src];aipic=1'>Print photo from database</a><BR><BR>"
	dat += "Current toner level: [toner]"
	if(!toner)
		dat +="<BR>Please insert a new toner cartridge!"
	show_browser(user, dat, "window=copier")
	onclose(user, "copier")
	return

/obj/machinery/photocopier/proc/busy_check(user)
	if (busy)
		to_chat(user, SPAN_WARNING("[src] is busy!"))
	return busy

/obj/machinery/photocopier/Topic(href, href_list)
	. = ..()
	if (. != TOPIC_NOACTION)
		return
	if (busy_check(usr))
		return
	if(href_list["copy"])
		if(stat & (BROKEN|NOPOWER))
			return

		busy = TRUE
		for(var/i = 0, i < copies, i++)
			if(toner <= 0)
				break
			if(stat & (BROKEN|NOPOWER))
				break
			if (istype(copyitem, /obj/item/paper))
				playsound(src.loc, 'sound/signals/processing20.ogg', 25)
				copy(copyitem)
				sleep(15)
			else if (istype(copyitem, /obj/item/photo))
				playsound(src.loc, 'sound/signals/processing20.ogg', 25)
				photocopy(copyitem)
				sleep(15)
			else if (istype(copyitem, /obj/item/paper_bundle))
				playsound(src.loc, 'sound/signals/processing20.ogg', 25)
				var/obj/item/paper_bundle/B = bundlecopy(copyitem)
				sleep(15*B.pages.len)
			else
				to_chat(usr, SPAN("warning", "\The [copyitem] can't be copied by \the [src]."))
				break

		updateUsrDialog()
		busy = FALSE
	else if(href_list["remove"])
		if(copyitem)
			if(usr.pick_or_drop(copyitem, loc))
				to_chat(usr, SPAN("notice", "You take \the [copyitem] out of \the [src]."))
			else
				to_chat(usr, SPAN("notice", "You remove \the [copyitem] from \the [src]."))
			copyitem = null
			updateUsrDialog()
	else if(href_list["min"])
		if(copies > 1)
			copies--
			updateUsrDialog()
	else if(href_list["add"])
		if(copies < maxcopies)
			copies++
			updateUsrDialog()

/obj/machinery/photocopier/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/paper) || istype(O, /obj/item/photo) || istype(O, /obj/item/paper_bundle))
		if(!copyitem)
			if(!user.drop(O, src))
				return
			copyitem = O
			to_chat(user, SPAN("notice", "You insert \the [O] into \the [src]."))
			flick(insert_anim, src)
			updateUsrDialog()
		else
			to_chat(user, SPAN("notice", "There is already something in \the [src]."))
	else if(istype(O, /obj/item/device/toner))
		if(toner <= 10) //allow replacing when low toner is affecting the print darkness
			if(!user.drop(O))
				return
			to_chat(user, SPAN("notice", "You insert the toner cartridge into \the [src]."))
			var/obj/item/device/toner/T = O
			toner += T.toner_amount
			qdel(O)
			updateUsrDialog()
		else
			to_chat(user, SPAN("notice", "This cartridge is not yet ready for replacement! Use up the rest of the toner."))
	else
		..()
	if(O.mod_weight >= 0.75)
		shake_animation(stime = 4)
	return

/obj/machinery/photocopier/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(50))
				qdel(src)
			else
				if(toner > 0)
					new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
					toner = 0
		else
			if(prob(50))
				if(toner > 0)
					new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
					toner = 0
	return

/obj/machinery/photocopier/proc/copy(obj/item/paper/copy, need_toner=1)
	var/obj/item/paper/c = copy.copy(loc, generate_stamps = FALSE)
	c.recolorize(saturation = Clamp(toner / 30.0, 0.5, 0.94), grayscale = src.grayscale)
	if(need_toner)
		toner--
	if(toner == 0)
		visible_message(SPAN("notice", "A red light on \the [src] flashes, indicating that it is out of toner."))
	c.update_icon()
	c.photocopied = TRUE
	return c

/obj/machinery/photocopier/proc/photocopy(obj/item/photo/photocopy, need_toner=1)
	var/obj/item/photo/p = photocopy.copy()
	p.forceMove(get_turf(src))

	if(toner > 10)	//plenty of toner, go straight greyscale
		p.img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))//I'm not sure how expensive this is, but given the many limitations of photocopying, it shouldn't be an issue.
		p.update_icon()
	else			//not much toner left, lighten the photo
		p.img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
		p.update_icon()
	if(need_toner)
		toner -= 5	//photos use a lot of ink!
	if(toner < 0)
		toner = 0
		visible_message(SPAN("notice", "A red light on \the [src] flashes, indicating that it is out of toner."))

	return p

//If need_toner is 0, the copies will still be lightened when low on toner, however it will not be prevented from printing. TODO: Implement print queues for fax machines and get rid of need_toner
/obj/machinery/photocopier/proc/bundlecopy(obj/item/paper_bundle/bundle, need_toner=1)
	var/obj/item/paper_bundle/p = new /obj/item/paper_bundle (src)
	for(var/obj/item/I in bundle.pages)
		if(toner <= 0 && need_toner)
			toner = 0
			visible_message(SPAN("notice", "A red light on \the [src] flashes, indicating that it is out of toner."))
			break

		if(istype(I, /obj/item/paper))
			I = copy(I)
		else if(istype(I, /obj/item/photo))
			I = photocopy(I)
		I.forceMove(p)
		p.pages += I

	p.dropInto(loc)
	p.update_icon()
	p.icon_state = "paper_words"
	p.SetName(bundle.name)
	return p

/obj/item/device/toner
	name = "toner cartridge"
	icon_state = "tonercartridge"
	var/toner_amount = 30
