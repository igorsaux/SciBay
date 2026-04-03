/obj/item/modular_computer/examine(mob/user, infix)
	. = ..()

	if(damage > broken_damage)
		. += SPAN_DANGER("It is heavily damaged!")
	else if(damage)
		. += "It is damaged."

/obj/item/modular_computer/proc/break_apart()
	visible_message("\The [src] breaks apart!")
	var/turf/newloc = get_turf(src)
	new /obj/item/stack/material/steel(newloc, round(steel_sheet_cost/2))
	for(var/obj/item/computer_hardware/H in get_all_components())
		uninstall_component(null, H)
		H.forceMove(newloc)
		if(prob(25))
			H.take_damage(rand(10,30))
	qdel(src)

/obj/item/modular_computer/proc/take_damage(amount, component_probability, damage_casing = 1, randomize = 1)
	if(randomize)
		// 75%-125%, rand() works with integers, apparently.
		amount *= (rand(75, 125) / 100.0)
	amount = round(amount)
	if(damage_casing)
		damage += amount
		damage = between(0, damage, max_damage)

	if(component_probability)
		for(var/obj/item/computer_hardware/H in get_all_components())
			if(prob(component_probability))
				H.take_damage(round(amount / 2))

	if(damage >= max_damage)
		break_apart()

// Stronger explosions cause serious damage to internal components
// Minor explosions are mostly mitigitated by casing.
/obj/item/modular_computer/ex_act(severity)
	switch(severity)
		if(1)
			break_apart()
		if(2)
			take_damage(rand(100,200), 30)
		if(3)
			take_damage(rand(50, 100), 15)
