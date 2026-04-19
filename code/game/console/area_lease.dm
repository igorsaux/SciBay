/obj/console/area_lease
	name = "lease terminal"
	desc = "A localized interface for signing short-term spatial lease agreements."
	icon_state = "tiny"
	screen_state = "tiny_lift"
	density = 0
	turf_height_offset = 0
	req_access = list(access_captain)

/obj/console/area_lease/attack_hand(user as mob)
	. = ..(user)

	if(.)
		return

	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Access Denied."))
		return TRUE

	ui_interact(user)

/obj/console/area_lease/proc/get_ui_data()
	var/list/data = list()
	
	// Get the area where the console is currently located
	var/area/private_space/current_area = get_area(src)
	
	// Pass the current station balance
	data["credits"] = GLOB.credits
	
	// Check if the console is in a valid leasable area
	if(istype(current_area))
		data["valid_area"] = TRUE
		data["area_name"] = current_area.name
		data["area_price"] = current_area.price
		
		// If price is null, it's not for sale
		data["is_for_sale"] = !isnull(current_area.price) && !current_area.is_owned
		
		if(!isnull(current_area.price))
			data["can_afford"] = (GLOB.credits >= current_area.price)
	else
		data["valid_area"] = FALSE

	return data

/obj/console/area_lease/OnTopic(mob/user, href_list)
	if(!user.Adjacent(src) || !allowed(user))
		return TOPIC_NOACTION

	if(href_list["purchase"])
		var/area/private_space/current_area = get_area(src)
		
		// Sanity checks to prevent exploits
		if(!istype(current_area))
			return TOPIC_NOACTION
			
		if(isnull(current_area.price))
			return TOPIC_NOACTION
			
		if(GLOB.credits < current_area.price)
			return TOPIC_NOACTION
			
		// Deduct credits (works fine even if price is 0)
		GLOB.credits -= current_area.price
		
		// Notify the user
		to_chat(user, SPAN_NOTICE("You have successfully leased [current_area.name]."))
		current_area.is_owned = TRUE
		
		// Delete the console after successful purchase
		// NanoUI will automatically close the UI for all users when the object is deleted
		qdel(src)
		return TOPIC_HANDLED

	return TOPIC_NOACTION

/obj/console/area_lease/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = get_ui_data()

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// Adjusted window size to fit the new content nicely
		ui = new(user, src, ui_key, "area_lease.tmpl", "Lease Terminal", 400, 350)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
