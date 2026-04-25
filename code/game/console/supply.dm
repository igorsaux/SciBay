/obj/console/supply
	name = "supply terminal"
	desc = "Interface for localized inventory requisition. Allows manifest compilation and procurement requests."
	screen_state = "thick_supply"
	req_access = list(access_cargo)

	/// 1: Catalog, 2: Cart, 3: History
	var/screen = 1
	var/selected_category
	var/list/category_names
	var/list/category_contents

/obj/console/supply/OnTopic(mob/user, href_list)
	if(!user.Adjacent(src))
		return TOPIC_NOACTION

	if(href_list["select_category"])
		selected_category = href_list["select_category"]

		return TOPIC_HANDLED

	if(href_list["set_screen"])
		screen = text2num(href_list["set_screen"])

		return TOPIC_HANDLED

	// Anyone can add to cart
	if(href_list["add_to_cart"])
		var/decl/hierarchy/supply_pack/P = locate(href_list["add_to_cart"]) in SSsupply.master_supply_list
		
		if(!istype(P) || P.is_category())
			return TOPIC_NOACTION

		var/idname = ishuman(user) ? user:get_authentification_name() : user.real_name
		SSsupply.ordernum++

		var/datum/supply_order/O = new /datum/supply_order()
		O.ordernum = SSsupply.ordernum
		O.object = P
		O.orderedby = idname
		SSsupply.shoppinglist += O

		return TOPIC_HANDLED

	// Removing from cart
	if(href_list["remove_from_cart"])
		var/id = text2num(href_list["remove_from_cart"])

		for(var/datum/supply_order/SO in SSsupply.shoppinglist)
			if(SO.ordernum == id)
				SSsupply.shoppinglist -= SO
				break

		return TOPIC_HANDLED

	// Admin/Cargo access required below
	if(!allowed(user))
		return TOPIC_NOACTION

	// Instant sell, no price shown
	if(href_list["sell"])
		SSsupply.sell() 
		to_chat(user, SPAN_NOTICE("Goods in the loading area have been sold."))

		return TOPIC_HANDLED
	
	// Checkout process
	if(href_list["checkout"])
		var/total_cost = 0
		for(var/datum/supply_order/SO in SSsupply.shoppinglist)
			total_cost += SO.object.get_cost()
			
		if(total_cost > GLOB.credits)
			to_chat(user, SPAN_WARNING("Insufficient funds!"))
			return TOPIC_NOACTION
			
		if(length(SSsupply.shoppinglist) == 0)
			return TOPIC_NOACTION

		// Deduct points and trigger buy logic
		GLOB.credits -= total_cost
		// Assuming this proc handles spawning items from shoppinglist and clearing it
		SSsupply.buy()
		
		to_chat(user, SPAN_NOTICE("Order placed successfully! Items will arrive shortly."))
		return TOPIC_HANDLED

/obj/console/supply/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, state = GLOB.default_state)
	var/list/data = list()
	var/is_admin = allowed(user)
	
	if(!category_names || !category_contents)
		generate_categories()

	data["is_admin"] = is_admin
	data["screen"] = screen
	data["credits"] = "[GLOB.credits]"
	data["currency"] = "₠"
	
	// Calculate cart total
	var/cart_total = 0
	for(var/datum/supply_order/SO in SSsupply.shoppinglist)
		cart_total += SO.object.get_cost()

	data["cart_total"] = cart_total

	switch(screen)
		// Catalog
		if(1)
			data["categories"] = category_names

			if(selected_category)
				data["category"] = selected_category
				
				var/list/cart_counts = list()

				for(var/datum/supply_order/SO in SSsupply.shoppinglist)
					var/ref = "\ref[SO.object]"
					cart_counts[ref] = (cart_counts[ref] || 0) + 1
				
				var/list/purchases = list()

				for(var/list/item_data in category_contents[selected_category])
					item_data["in_cart"] = cart_counts[item_data["ref"]] || 0
					purchases.Add(list(item_data))
					
				data["possible_purchases"] = purchases
		// Cart
		if(2)
			var/list/cart[0]

			for(var/datum/supply_order/SO in SSsupply.shoppinglist)
				cart.Add(order_to_nanoui(SO))

			data["cart"] = cart
		// History
		if(3)
			var/list/history_display = list()
			var/history_count = length(SSsupply.history)
			
			// Show only last 10 entries
			for(var/i = 1; i <= history_count; i++)
				var/entry_idx = history_count - i + 1
				if(i > 10)
					break
				if(entry_idx >= 1 && entry_idx <= history_count)
					var/entry = SSsupply.history[entry_idx]
					history_display += list(entry)
			
			data["history"] = history_display

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "supply.tmpl", name, 1050, 800, state = state)
		ui.set_auto_update(1)
		ui.set_initial_data(data)
		ui.open()

/obj/console/supply/proc/generate_categories()
	category_names = list()
	category_contents = list()

	for(var/decl/hierarchy/supply_pack/sp in cargo_supply_pack_root.children)
		if(!sp.is_category())
			continue

		category_names.Add(sp.name)

		var/list/category[0]

		for(var/decl/hierarchy/supply_pack/spc in sp.children)
			category.Add(list(list(
				"name" = spc.name,
				"vendor" = spc.vendor,
				"cost" = spc.get_cost(),
				"ref" = "\ref[spc]"
			)))

		category_contents[sp.name] = category

/obj/console/supply/proc/order_to_nanoui(datum/supply_order/SO)
	return list(list(
		"id" = SO.ordernum,
		"object" = SO.object.name,
		"vendor" = SO.object.vendor,
		"orderer" = SO.orderedby,
		"cost" = SO.object.get_cost()
	))
