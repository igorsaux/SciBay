var/decl/hierarchy/supply_pack/cargo_supply_pack_root = new()
var/list/decl/hierarchy/supply_pack/cargo_supply_packs

/decl/hierarchy/supply_pack
	name = "Supply Packs"
	/// Default vendor name
	var/vendor = "Resident Consignment"
	var/list/contains = list()
	var/manifest = ""
	var/cost = null
	var/containertype = /obj/structure/closet/crate
	var/containername = null
	var/access = null
	var/num_contained = 0
	var/supply_method = /decl/supply_method
	var/decl/security_level/security_level

/decl/hierarchy/supply_pack/New()
	..()
	if(is_hidden_category())
		// Don't init the manifest for category entries
		return

	if(!cargo_supply_packs)
		cargo_supply_packs = list()
	
	// Add all non-category supply packs to the list
	dd_insertObjectList(cargo_supply_packs, src)

	if(!num_contained)
		for(var/entry in contains)
			num_contained += max(1, contains[entry])

	var/decl/supply_method/sm = get_supply_method(supply_method)
	manifest = sm.setup_manifest(src)

/decl/hierarchy/supply_pack/proc/get_cost()
	if(cost == null && num_contained > 0)
		cost = 0

		for(var/entry in contains)
			var/atom/A = new entry()
			var/count = contains[entry] || 1

			cost += get_buy_price(A) * count

			qdel(A)
	
	return cost

/decl/hierarchy/supply_pack/proc/spawn_contents(location)
	var/decl/supply_method/sm = get_supply_method(supply_method)
	return sm.spawn_contents(src, location)

var/list/supply_methods_
/proc/get_supply_method(method_type)
	if(!supply_methods_)
		supply_methods_ = list()
	. = supply_methods_[method_type]
	if(!.)
		. = new method_type()
		supply_methods_[method_type] = .

/decl/supply_method/proc/spawn_contents(decl/hierarchy/supply_pack/sp, location)
	if(!sp || !location)
		return
	. = list()
	for(var/entry in sp.contains)
		if(locate(entry) in location)//for containers which self-spawn its content
			continue
		for(var/i = 1 to max(1, sp.contains[entry]))
			dd_insertObjectList(.,new entry(location))

/decl/supply_method/proc/setup_manifest(decl/hierarchy/supply_pack/sp)
	. = list()
	. += "<ul>"
	for(var/path in sp.contains)
		var/atom/A = path
		if(!ispath(A))
			continue
		. += "<li>[initial(A.name)]</li>"
	. += "</ul>"
	. = jointext(.,null)

/decl/supply_method/randomized/spawn_contents(decl/hierarchy/supply_pack/sp, location)
	if(!sp || !location)
		return
	. = list()
	for(var/j = 1 to sp.num_contained)
		var/picked = pick(sp.contains)
		. += new picked(location)

/decl/supply_method/randomized/setup_manifest(decl/hierarchy/supply_pack/sp)
	return "Contains any [sp.num_contained] of:" + ..()
