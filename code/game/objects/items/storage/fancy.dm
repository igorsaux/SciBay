/*
 * The 'fancy' path is for objects like candle boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 *
 * Contains:
 *		Egg Box
 *		Candle Box
 *		Crayon Box
 *		Cigarette Box
 *		Vial Box
 *		Rolling Papers Box
 */

/obj/item/storage/fancy
	item_state = "syringe_kit" //placeholder, many of these don't have inhands
	var/obj/item/key_type //path of the key item that this "fancy" container is meant to store
	var/opened = 0 //if an item has been removed from this container
	var/hasany = 0 //if an item only changes sprite upon being used/finished, w/out displaying each key_type occasion

/obj/item/storage/fancy/remove_from_storage()
	. = ..()
	if(!opened && .)
		opened = 1
		update_icon()


/obj/item/storage/fancy/on_update_icon()
	if(!opened)
		icon_state = initial(icon_state)
		return

	var/key_count = count_by_type(contents, key_type)
	if(hasany)
		if(key_count)
			icon_state = "[initial(icon_state)]1"
		else
			icon_state = "[initial(icon_state)]0"
	else
		icon_state = "[initial(icon_state)][key_count]"

	. = ..()

/obj/item/storage/fancy/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) > 1)
		return

	var/key_name = initial(key_type.name)
	if(!contents.len)
		. += "There are no [key_name]s left in the box."
	else
		var/key_count = count_by_type(contents, key_type)
		. += "There [key_count == 1? "is" : "are"] [key_count] [key_name]\s in the box."

/obj/item/storage/fancy/egg_box/empty
	startswith = null


/*
 * Candle Box
 */

/obj/item/storage/fancy/candle_box
	name = "candle pack"
	desc = "A pack of red candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox"
	opened = 1 //no closed state
	throwforce = 2
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = 5
	slot_flags = SLOT_BELT

	key_type = /obj/item/flame/candle
	startswith = list(/obj/item/flame/candle = 5)

/*
 * Crayon Box
 */

/obj/item/storage/fancy/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = 6

	key_type = /obj/item/pen/crayon
	startswith = list(
		/obj/item/pen/crayon/red,
		/obj/item/pen/crayon/orange,
		/obj/item/pen/crayon/yellow,
		/obj/item/pen/crayon/green,
		/obj/item/pen/crayon/blue,
		/obj/item/pen/crayon/purple,
		)

/obj/item/storage/fancy/crayons/on_update_icon()
	ClearOverlays() //resets list
	AddOverlays(image('icons/obj/crayons.dmi',"crayonbox"))
	for(var/obj/item/pen/crayon/crayon in contents)
		AddOverlays(image('icons/obj/crayons.dmi',crayon.colourName))

	. = ..()

/*
 * Vial Box
 */

/obj/item/storage/fancy/vials
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox"
	name = "vial storage box"
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_TINY
	storage_slots = 6

	key_type = /obj/item/reagent_containers/vessel/beaker/vial
	startswith = list(/obj/item/reagent_containers/vessel/beaker/vial = 6)

/obj/item/storage/fancy/vials/on_update_icon()
	var/key_count = count_by_type(contents, key_type)
	icon_state = "[initial(icon_state)][key_count]"

/obj/item/storage/lockbox/vials
	name = "secure vial storage box"
	desc = "A locked box for keeping things away from children."
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox0"
	item_state = "syringe_kit"
	inspect_state = FALSE
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = null
	storage_slots = 6
	req_access = list(access_virology)
	can_hold = list(/obj/item/reagent_containers/vessel/beaker/vial)

/obj/item/storage/lockbox/vials/on_update_icon()
	var/total_contents = count_by_type(contents, /obj/item/reagent_containers/vessel/beaker/vial)
	ClearOverlays()
	icon_state = "vialbox[Floor(total_contents)]"
	if (!broken)
		AddOverlays(image(icon, src, "led[locked]"))
		if(locked)
			AddOverlays(image(icon, src, "cover"))
	else
		AddOverlays(image(icon, src, "ledb"))
	return
