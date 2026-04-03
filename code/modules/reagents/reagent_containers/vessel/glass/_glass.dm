
/obj/item/reagent_containers/vessel/glass
	name = "glass" // Name when empty
	base_name = "glass"
	desc = "A generic drinking glass." // Description when empty
	icon = DRINK_ICON_FILE
	base_icon = "square" // Base icon name
	item_state = "glass_empty"
	center_of_mass ="x=16;y=9"
	filling_states = "20;40;60;80;100"
	force = 5.0
	mod_weight = 0.45
	mod_reach = 0.25
	mod_handy = 0.65
	volume = 0.25 LITERS
	matter = list(MATERIAL_GLASS = 65)
	can_be_splashed = TRUE
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = "25;30;50;60;100;150;250"
	lid_type = null
	label_icon = TRUE
	overlay_icon = TRUE
	brittle = TRUE
	can_flip = TRUE

	var/list/extras = list() // List of extras. Two extras maximum
	var/rim_pos // Position of the rim for fruit slices. list(y, x_left, x_right)

	drop_sound = SFX_DROP_GLASS
	pickup_sound = SFX_PICKUP_GLASS

/obj/item/reagent_containers/vessel/glass/examine(mob/user, infix)
	. = ..()

	for(var/I in extras)
		if(istype(I, /obj/item/glass_extra))
			. += "There is \a [I] in \the [src]."
		else
			. += "There is \a [I] somewhere on the glass. Somehow."

	if(has_ice())
		. += "There is some ice floating in the drink."

	if(has_fizz())
		. += "It is fizzing slightly."

/obj/item/reagent_containers/vessel/glass/proc/has_ice()
	return FALSE

/obj/item/reagent_containers/vessel/glass/proc/has_fizz()
	return FALSE

/obj/item/reagent_containers/vessel/glass/proc/has_vapor()
	return FALSE

/obj/item/reagent_containers/vessel/glass/proc/can_add_extra(obj/item/glass_extra/GE)
	return FALSE

/obj/item/reagent_containers/vessel/glass/on_update_icon()
	underlays.Cut()
	ClearOverlays()
	icon = DRINK_ICON_FILE
	icon_state = base_icon

	SetName(initial(name))
	desc = initial(desc)
	can_flip = TRUE

	if(overlay_icon)
		AddOverlays(image(icon, src, overlay_icon))

	var/side = "left"
	for(var/item in extras)
		if(istype(item, /obj/item/glass_extra))
			var/obj/item/glass_extra/GE = item
			var/image/I = image(DRINK_ICON_FILE, src, "[base_icon]_[GE.glass_addition][side]")
			if(GE.glass_color)
				I.color = GE.glass_color
			if(GE.isoverlaying)
				AddOverlays(I)
			else
				underlays += I
		else
			continue
		side = "right"
