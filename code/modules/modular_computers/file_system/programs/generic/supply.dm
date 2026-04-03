/datum/computer_file/program/supply
	filename = "supply"
	filedesc = "Supply Management"
	nanomodule_path = /datum/nano_module/supply
	program_icon_state = "supply"
	program_key_state = "rd_key"
	program_menu_icon = "cart"
	program_light_color = "#B88B2E"
	extended_desc = "A management tool that allows for ordering of various supplies."
	size = 21
	category = PROG_SUPPLY
	available_on_ntnet = 1
	requires_ntnet = 1

/datum/nano_module/supply
	name = "Supply Management program"
	var/screen = 1 // 1: Catalog, 2: Cart
	var/selected_category
	var/list/category_names
	var/list/category_contents
	var/current_security_level

/datum/nano_module/supply/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, state = GLOB.default_state)
	var/list/data = host.initial_data()
	var/is_admin = check_access(user, access_cargo)
	
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
		if(1) // Catalog
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

		if(2) // Cart
			var/list/cart[0]
			for(var/datum/supply_order/SO in SSsupply.shoppinglist)
				cart.Add(order_to_nanoui(SO))
			data["cart"] = cart

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "supply.tmpl", name, 1050, 800, state = state)
		ui.set_auto_update(1)
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/supply/Topic(href, href_list)
	var/mob/user = usr
	if(..())
		return 1

	if(href_list["select_category"])
		selected_category = href_list["select_category"]
		return 1

	if(href_list["set_screen"])
		screen = text2num(href_list["set_screen"])
		return 1

	// Anyone can add to cart
	if(href_list["add_to_cart"])
		var/decl/hierarchy/supply_pack/P = locate(href_list["add_to_cart"]) in SSsupply.master_supply_list
		if(!istype(P) || P.is_category())
			return 1

		var/idname = ishuman(user) ? user:get_authentification_name() : user.real_name
		SSsupply.ordernum++

		var/datum/supply_order/O = new /datum/supply_order()
		O.ordernum = SSsupply.ordernum
		O.object = P
		O.orderedby = idname
		SSsupply.shoppinglist += O
		return 1

	// Removing from cart
	if(href_list["remove_from_cart"])
		var/id = text2num(href_list["remove_from_cart"])
		for(var/datum/supply_order/SO in SSsupply.shoppinglist)
			if(SO.ordernum == id)
				SSsupply.shoppinglist -= SO
				break
		return 1

	// Admin/Cargo access required below
	if(!check_access(access_cargo))
		return 1

	// Instant sell, no price shown
	if(href_list["sell"])
		SSsupply.sell() 
		to_chat(user, "<span class='notice'>Goods in the loading area have been sold.</span>")
		return 1
	
	// Checkout process
	if(href_list["checkout"])
		var/total_cost = 0
		for(var/datum/supply_order/SO in SSsupply.shoppinglist)
			total_cost += SO.object.get_cost()
			
		if(total_cost > GLOB.credits)
			to_chat(user, "<span class='warning'>Insufficient funds!</span>")
			return 1
			
		if(SSsupply.shoppinglist.len == 0)
			return 1

		// Deduct points and trigger buy logic
		GLOB.credits -= total_cost
		SSsupply.buy() // Assuming this proc handles spawning items from shoppinglist and clearing it
		
		to_chat(user, "<span class='notice'>Order placed successfully! Items will arrive shortly.</span>")
		return 1

/datum/nano_module/supply/proc/generate_categories()
	category_names = list()
	category_contents = list()
	for(var/decl/hierarchy/supply_pack/sp in cargo_supply_pack_root.children)
		if(sp.is_category())
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

/datum/nano_module/supply/proc/order_to_nanoui(datum/supply_order/SO)
	return list(list(
		"id" = SO.ordernum,
		"object" = SO.object.name,
		"vendor" = SO.object.vendor,
		"orderer" = SO.orderedby,
		"cost" = SO.object.get_cost()
		))
