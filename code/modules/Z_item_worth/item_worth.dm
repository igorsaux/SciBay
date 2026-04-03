// Global margins for dynamic economy. Can be randomized at round start.
GLOBAL_VAR_INIT(economy_buy_margin, 1.15)  // 15% markup when players buy
GLOBAL_VAR_INIT(economy_sell_margin, 0.85) // 15% markdown when players sell

GLOBAL_LIST_EMPTY(price_cache)

// Get the raw base value of an item, including its specific modifier
/proc/get_base_value(atom/A)
	var/atom/t = ispath(A) ? A : A.type
	while(!(t in worths))
		t = PARENT(t)
		if(!t)
			return 0
			
	var/value = worths[t]
	var/item_modifier = 1
	
	// If it's an instantiated item, check for its specific modifier
	if(!ispath(A) && istype(A, /obj/item))
		var/obj/item/I = A
		if(I.price_modifier)
			item_modifier = I.price_modifier

	if(value >= 0)
		return value * item_modifier
	else 
		if(ispath(A))
			t = A
			if(!GLOB.price_cache[A])
				A = new A
				GLOB.price_cache[A.type] = A.Value(-value)
				qdel(A)
			return GLOB.price_cache[t] * item_modifier
		else
			return A.Value(-value) * item_modifier

// Price when ordering from cargo
/proc/get_buy_price(atom/A)
	return ceil(get_base_value(A) * GLOB.economy_buy_margin)

// Price when selling to cargo
/proc/get_sell_price(atom/A)
	return ceil(get_base_value(A) * GLOB.economy_sell_margin)
