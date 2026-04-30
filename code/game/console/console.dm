/obj/console
	icon = 'icons/console.dmi'
	icon_state = "thick"
	layer = BELOW_OBJ_LAYER
	density = 1
	anchored = 1

	var/screen_state = null

/obj/console/Initialize()
	. = ..()

	update_icon()

/obj/console/on_update_icon()
	. = ..()
	
	ClearOverlays()

	if(screen_state != null)
		AddOverlays(image(icon, screen_state))

/obj/console/attack_hand(mob/living/user)
	. = ..()
	
	if(.)
		return
	
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Access Denied."))
		return TRUE

	ui_interact(user)
	return TRUE
