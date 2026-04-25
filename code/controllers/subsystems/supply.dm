SUBSYSTEM_DEF(supply)
	name = "Supply"
	priority = SS_PRIORITY_SUPPLY
	flags = SS_NO_TICK_CHECK | SS_NO_FIRE

	//control
	var/ordernum
	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/donelist = list()
	var/list/master_supply_list = list()
	/// Infinite history of buy/sell operations
	var/list/history = list()

/datum/controller/subsystem/supply/Initialize()
	. = ..()

	ordernum = rand(1,9000)

	//Build master supply list
	for(var/decl/hierarchy/supply_pack/sp in cargo_supply_pack_root.children)
		if(sp.is_category())
			for(var/decl/hierarchy/supply_pack/spc in sp.children)
				master_supply_list += spc

/datum/controller/subsystem/supply/stat_entry()
	..("Credits: [GLOB.credits]")

//To stop things being sent to centcomm which should not be sent to centcomm. Recursively checks for these types.
/datum/controller/subsystem/supply/proc/forbidden_atoms_check(atom/A)
	if(istype(A,/mob/living))
		return 1

	for(var/i=1, i<=A.contents.len, i++)
		var/atom/B = A.contents[i]
		if(.(B))
			return 1

/datum/controller/subsystem/supply/proc/sell()
	var/value = 0
	var/area/public_space/cargo/AR = locate(/area/public_space/cargo)

	for(var/atom/movable/AM in AR)
		if(AM.anchored)
			continue

		if(!istype(AM, /obj))
			continue

		if(istype(AM, /obj/structure/closet/crate/))
			var/obj/structure/closet/crate/CR = AM
			value += floor(get_base_value(CR) * 0.9)

			for(var/atom/atom in CR)
				value += floor(get_base_value(atom) * 0.9)

		qdel(AM)
	
	GLOB.credits += value

	// Record sell in history
	if(value > 0)
		history += list(list(
			"type" = "sell",
			"time" = stationtime2text(),
			"items" = "-",
			"diff" = "[value]",
			"color" = "#44bb44"
		))

//Buyin
/datum/controller/subsystem/supply/proc/buy()
	if(!length(shoppinglist))
		return

	// Count items before clearing shoppinglist
	var/item_count = length(shoppinglist)
	var/total_cost = 0
	for(var/datum/supply_order/SO in shoppinglist)
		total_cost += SO.object.get_cost()

	var/list/clear_turfs = list()
	var/area/public_space/cargo/AR = locate(/area/public_space/cargo)

	for(var/turf/T in AR)
		if(T.density)
			continue

		var/occupied = FALSE

		for(var/atom/A in T.contents)
			if(!A.simulated)
				continue

			occupied = TRUE
			break

		if(!occupied)
			clear_turfs += T

	for(var/S in shoppinglist)
		if(!length(clear_turfs))
			break

		var/turf/pickedloc = pick_n_take(clear_turfs)
		shoppinglist -= S
		donelist += S

		var/datum/supply_order/SO = S
		var/decl/hierarchy/supply_pack/SP = SO.object

		var/obj/A = new SP.containertype(pickedloc)
		A.SetName("[SP.containername][SO.comment ? " ([SO.comment])":"" ]")

		//supply manifest generation begin

		var/obj/item/paper/manifest/slip
		var/info = ""

		info +="<h3>[command_name()] Shipping Manifest</h3><hr><br>"
		info +="Order #[SO.ordernum]<br>"
		info +="Destination: [GLOB.using_map.station_name]<br>"
//			info +="[shoppinglist.len] PACKAGES IN THIS SHIPMENT<br>"
		info +="CONTENTS:<br><ul>"

		slip = new /obj/item/paper/manifest(A)
		slip.set_content(info, rawhtml = TRUE)
		slip.is_copy = 0

		//spawn the stuff, finish generating the manifest while you're at it
		if(SP.access)
			if(!islist(SP.access))
				A.req_access = list(SP.access)
			else if(islist(SP.access))
				// access var is a plain var, we need a list
				var/list/L = SP.access
				A.req_access = L.Copy()

		var/list/spawned = SP.spawn_contents(A)
		for(var/atom/content in spawned)
			//add the item to the manifest
			slip.info += "<li>[content.name]</li>"

	// Record buy in history
	history += list(list(
		"type" = "purchase",
		"time" = stationtime2text(),
		"items" = "[item_count]",
		"diff" = "[total_cost]",
		"color" = "#dd4444"
	))

/datum/supply_order
	var/ordernum
	var/decl/hierarchy/supply_pack/object = null
	var/orderedby = null
	var/comment = null
	var/reason = null
	//used for supply console printing
	var/orderedrank = null
