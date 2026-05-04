/obj/console/area_lease
	name = "lease terminal"
	desc = "A localized interface for signing short-term spatial lease agreements."
	icon_state = "tiny"
	screen_state = "tiny_lift"
	turf_height_offset = 0
	req_access = list(access_captain)

/obj/console/area_lease/attack_hand(mob/user)
	. = ..()

	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Access Denied."))
		return

	tgui_interact(user)

/obj/console/area_lease/tgui_data(mob/user)
	var/list/data = list()
	var/area/private_space/current_area = get_area(src)
	
	data["credits"] = SSsupply.money
	
	// Check if the console is in a valid leasable area
	if(istype(current_area))
		data["valid_area"] = TRUE
		data["area_name"] = current_area.name
		data["area_price"] = current_area.price
		
		// If price is null, it's not for sale
		data["is_for_sale"] = !isnull(current_area.price) && !current_area.is_owned
		
		if(!isnull(current_area.price))
			data["can_afford"] = (SSsupply.money >= current_area.price)
	else
		data["valid_area"] = FALSE

	return data

/obj/console/area_lease/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	
	if(.)
		return TRUE
	
	switch(action)
		if("purchase")
			var/area/private_space/current_area = get_area(src)
			
			if(!istype(current_area))
				return TRUE
				
			if(isnull(current_area.price))
				return TRUE
				
			if(SSsupply.money < current_area.price)
				return TRUE
				
			SSsupply.money -= current_area.price
			
			to_chat(ui.user, SPAN_NOTICE("You have successfully leased [current_area.name]."))
			current_area.is_owned = TRUE
			
			qdel(src)

			return TRUE

/obj/console/area_lease/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "AreaLease", "Lease Terminal", 400, 350)
		ui.set_autoupdate(TRUE)
		ui.open()
