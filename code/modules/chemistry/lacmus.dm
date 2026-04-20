/obj/item/lacmus
	name = "pH indicator strip"
	desc = "A small strip of paper treated with pH-sensitive dyes. Dip it into a liquid to measure acidity or alkalinity. Single use only."
	icon = 'icons/chemistry.dmi'
	icon_state = "lacmus"
	w_class = ITEM_SIZE_TINY

	var/ph = 7.0
	var/used = FALSE

/obj/item/lacmus/Initialize()
	. = ..()
	update_icon()

/obj/item/lacmus/Value(base)
	if(used)
		return ceil(base * 0.2)
	
	return base

/obj/item/lacmus/examine(mob/user, infix)
	. = ..()

	if(used)
		var/acidity_desc

		switch(ph)
			if(-INFINITY to 3)
				acidity_desc = "strongly acidic"
			if(3 to 5)
				acidity_desc = "acidic"
			if(5 to 6.5)
				acidity_desc = "slightly acidic"
			if(6.5 to 7.5)
				acidity_desc = "neutral"
			if(7.5 to 9)
				acidity_desc = "slightly alkaline"
			if(9 to 11)
				acidity_desc = "alkaline"
			if(11 to INFINITY)
				acidity_desc = "strongly alkaline"

		. += SPAN_NOTICE("The strip indicates a [acidity_desc] solution (pH ≈ [round(ph, 0.5)]).")
	else
		. += SPAN_NOTICE("The strip is unused and ready for testing.")

/obj/item/lacmus/on_update_icon()
	. = ..()
	
	if(!used)
		color = "#f5f5dc"
		return

	var/clamped_ph = clamp(ph, 0, 14)
	
	switch(clamped_ph)
		if(0 to 2)
			color = "#ff0000"
		if(2 to 4)
			color = "#ff6600"
		if(4 to 5)
			color = "#ff9900"
		if(5 to 6)
			color = "#ffcc00"
		if(6 to 7)
			color = "#ccff00"
		if(7 to 8)
			color = "#66cc33"
		if(8 to 9)
			color = "#33cc99"
		if(9 to 10)
			color = "#3399cc"
		if(10 to 12)
			color = "#3366cc"
		if(12 to 14)
			color = "#6633cc"
		else
			color = "#66cc33"
