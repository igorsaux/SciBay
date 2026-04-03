/obj/item/organ/internal/intestines
	name = "intestines"
	desc = "A few meters of sausage casing."
	gender = PLURAL
	icon_state = "intestines"
	dead_icon = "intestines"
	w_class = ITEM_SIZE_NORMAL
	organ_tag = BP_INTESTINES
	parent_organ = BP_GROIN
	min_bruised_damage = 25
	min_broken_damage = 60
	max_damage = 90
	relative_size = 60
	var/next_processing = 0
	var/waste_stored = 0 // We store it as a number for performance and simplicity, only spawning a reagent when absolutely needed.
	var/waste_capacity = STOMACH_FULLNESS_CAP

/obj/item/organ/internal/intestines/proc/store_item(obj/item/I)
	if(QDELETED(I))
		return
	I.forceMove(src)

/obj/item/organ/internal/intestines/proc/get_fullness()
	var/ret = waste_stored
	for(var/obj/item/I in contents)
		ret += get_storage_cost() * 15
	return (ret / waste_capacity) * 100

/obj/item/organ/internal/intestines/proc/rupture()
	if(owner)
		owner?.custom_pain("Your feel a burst of sudden, excruciating pain in your guts!", 30)
	// TODO: Abdominal cavity here
	return

/obj/item/organ/internal/intestines/take_internal_damage(amount, silent = FALSE, is_traumatic = FALSE)
	var/oldbroken = is_broken()
	. = ..()
	if(owner && !owner.stat)
		if(!oldbroken && is_broken())
			rupture()

/obj/item/organ/internal/intestines/think()
	..()

	if(!owner)
		return

	if(world.time > next_processing)
		next_processing = world.time + 5 SECONDS

		// Ruptured intestines, chance to send stuff into the abdominal cavity.
		if(contents.len > 1 && is_broken() && prob((damage - min_broken_damage) / 10))
			for(var/obj/item/I in contents)
				// TODO: Abdominal cavity here
			owner.custom_pain("Your guts cramp agonizingly!", 20)
			// TODO: Waste to the abdominal cavity here

		// Simulation disabled, let's just despawn food chunks and decrease waste. Non-edible items will be waiting for a surgeon though.
		if(!config.health.simulate_digestion)
			for(var/obj/item/I in contents)
				if(!istype(I, /obj/item/reagent_containers))
					continue
				qdel(I)
			waste_stored = clamp(waste_stored - 1, 0, waste_capacity)

		// Simulation enabled, warning the owner if needed.
		else if(!owner.stat)
			var/fullness = get_fullness()
			if(fullness >= 100)
				if(prob(50))
					owner.custom_pain("You feel like your guts are about to burst!", 1)
			else if(fullness >= 80)
				if(prob(10))
					to_chat(owner, SPAN("warning", "Your feel like your guts are full."))
			else if(fullness >= 60)
				if(prob(3))
					to_chat(owner, SPAN("notice", "You feel like you could visit a restroom."))
