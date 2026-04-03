/obj/item/scales
	name = "lab scales"
	desc = "A high-precision electronic scale for chemical reagents."
	icon = 'icons/chemistry.dmi'
	icon_state = "scales"
	layer = BELOW_OBJ_LAYER
	w_class = ITEM_SIZE_HUGE
	randpixel = 0

	var/tare_weight = 0

/obj/item/scales/examine(mob/user, infix)
	. = ..()
	
	var/current_total = get_weight()
	var/net_weight = current_total - tare_weight

	. += SPAN_INFO("The display reads: <B>[round(net_weight, 0.01)] g</B>")
	. += "<a href='?src=\ref[src];action=tare'>\[TARE\]</a> <a href='?src=\ref[src];action=reset'>\[RESET\]</a>"

/obj/item/scales/proc/get_weight()
	var/turf/T = get_turf(src)

	if(T == null)
		return 0.0
	
	var/weight = 0

	for(var/obj/item/reagent_containers/C in T.contents)
		if(!istype(C))
			continue

		weight += C.get_liquids_weight() + C.get_solids_weight()

	return weight

/obj/item/scales/attackby(obj/item/W, mob/user)
	. = ..()
	
	var/obj/item/reagent_containers/C = W
	if(!istype(C))
		return
	
	user.drop(W, get_turf(src))

/obj/item/scales/Topic(href, href_list, datum/topic_state/state)
	if(..() || !Adjacent(usr))
		return TRUE

	switch(href_list["action"])
		if("tare")
			tare_weight = get_weight()
			to_chat(usr, SPAN_NOTICE("You zero out the scales at [round(tare_weight, 0.01)] g."))

			return TRUE
		if("reset")
			tare_weight = 0
			to_chat(usr, SPAN_NOTICE("You reset the tare memory."))

			return TRUE
