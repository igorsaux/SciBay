/obj/console/supply
	name = "supply terminal"
	desc = "Interface for localized inventory requisition. Allows manifest compilation and procurement requests."
	screen_state = "thick_supply"
	req_access = list(access_cargo)

	/// Current history page (1-indexed)
	var/history_page = 1
	/// Items per page in history view
	var/history_per_page = 10
	var/selected_category
	var/list/category_names
	var/list/category_contents

/obj/console/supply/attack_hand(mob/user)
	. = ..()

	tgui_interact(user)

/obj/console/supply/tgui_data(mob/user)
	var/list/data = list()
	var/is_admin = allowed(user)

	if(!category_names || !category_contents)
		generate_categories()

	data["is_admin"] = is_admin
	data["credits"] = SSsupply.money
	data["currency"] = "₠"

	// Cart totals
	var/cart_total = 0
	for(var/datum/supply_order/SO in SSsupply.shoppinglist)
		cart_total += SO.object.get_cost()

	data["cart_total"] = cart_total
	data["cart_count"] = length(SSsupply.shoppinglist)

	// Categories
	data["categories"] = category_names
	data["selected_category"] = selected_category

	// Items for the selected category
	if(selected_category && category_contents[selected_category])
		var/list/cart_counts = list()

		for(var/datum/supply_order/SO in SSsupply.shoppinglist)
			var/ref = "\ref[SO.object]"

			cart_counts[ref] = (cart_counts[ref] || 0) + 1

		var/list/purchases = list()

		for(var/list/item_data in category_contents[selected_category])
			var/list/item = item_data.Copy()

			item["in_cart"] = cart_counts[item["ref"]] || 0
			purchases.Add(list(item))

		data["possible_purchases"] = purchases
	else
		data["possible_purchases"] = list()

	// Cart items
	var/list/cart = list()

	for(var/datum/supply_order/SO in SSsupply.shoppinglist)
		cart.Add(list(list(
			"id" = SO.ordernum,
			"object" = SO.object.name,
			"vendor" = SO.object.vendor,
			"orderer" = SO.orderedby,
			"cost" = SO.object.get_cost()
		)))

	data["cart"] = cart

	// History with proper pagination
	var/history_count = length(SSsupply.history)
	var/total_pages = max(1, CEILING(history_count / history_per_page, 1))
	history_page = clamp(history_page, 1, total_pages)

	var/list/history_display = list()
	if(history_count > 0)
		// Most recent entries first, paginated
		var/start_idx = history_count - (history_page - 1) * history_per_page
		var/end_idx = max(1, start_idx - history_per_page + 1)

		for(var/i = start_idx; i >= end_idx; i--)
			history_display += list(SSsupply.history[i])

	data["history"] = history_display
	data["history_page"] = history_page
	data["history_total_pages"] = total_pages
	data["history_count"] = history_count

	return data

/obj/console/supply/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return TRUE

	switch(action)
		if("select_category")
			selected_category = params["category"]

			return TRUE

		// Anyone can add to cart
		if("add_to_cart")
			var/decl/hierarchy/supply_pack/P = locate(params["ref"]) in SSsupply.master_supply_list

			if(!istype(P) || P.is_category())
				return TRUE

			var/idname = ishuman(usr) ? usr:get_authentification_name() : usr.real_name
			SSsupply.ordernum++

			var/datum/supply_order/O = new /datum/supply_order()
			O.ordernum = SSsupply.ordernum
			O.object = P
			O.orderedby = idname
			SSsupply.shoppinglist += O

			return TRUE
		if("remove_from_cart")
			var/id = text2num(params["id"])

			for(var/datum/supply_order/SO in SSsupply.shoppinglist)
				if(SO.ordernum == id)
					SSsupply.shoppinglist -= SO
					break

			return TRUE
		// Admin/Cargo access required below
		if("sell")
			if(!allowed(usr))
				return TRUE

			SSsupply.sell()
			to_chat(usr, SPAN_NOTICE("Goods in the loading area have been sold."))

			return TRUE
		if("checkout")
			if(!allowed(usr))
				return TRUE

			var/total_cost = 0

			for(var/datum/supply_order/SO in SSsupply.shoppinglist)
				total_cost += SO.object.get_cost()

			if(total_cost > SSsupply.money)
				to_chat(usr, SPAN_WARNING("Insufficient funds!"))
				return TRUE

			if(length(SSsupply.shoppinglist) == 0)
				return TRUE

			SSsupply.money -= total_cost
			SSsupply.buy()
			to_chat(usr, SPAN_NOTICE("Order placed successfully! Items will arrive shortly."))

			return TRUE
		if("set_history_page")
			history_page = text2num(params["page"])

			return TRUE

/obj/console/supply/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "SupplyTerminal", "Supply Terminal", 800, 600)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/console/supply/proc/generate_categories()
	category_names = list()
	category_contents = list()

	for(var/decl/hierarchy/supply_pack/sp in cargo_supply_pack_root.children)
		if(!sp.is_category())
			continue

		category_names.Add(sp.name)

		var/list/category = list()

		for(var/decl/hierarchy/supply_pack/spc in sp.children)
			category.Add(list(list(
				"name" = spc.name,
				"vendor" = spc.vendor,
				"cost" = spc.get_cost(),
				"ref" = "\ref[spc]"
			)))

		category_contents[sp.name] = category
