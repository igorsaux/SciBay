#define FLIPPING_DURATION	7
#define FLIPPING_ROTATION	360
#define FLIPPING_INCREMENT	FLIPPING_ROTATION / 8

// -= Vessels =-
// A very basic, default type for *vesselous* types of reagent containers - drinking glasses, bottles, buckets, beakers etc.

/obj/item/reagent_containers/vessel
	name = "vessel"
	desc = "It can store liquids. Or, maybe, solids."
	icon = 'icons/obj/reagent_containers/vessels.dmi'
	icon_state = ""
	item_state = "null"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand_vessels.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand_vessels.dmi',
		)

	volume = 0.5 LITERS
	amount_per_transfer_from_this = 100
	possible_transfer_amounts = "5;10;15;25;30;60"
	w_class = ITEM_SIZE_SMALL
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	unacidable = TRUE // Most of these are made of glass
	pickup_sound = SFX_PICKUP_BOTTLE
	drop_sound = SFX_DROP_BOTTLE
	can_be_splashed = TRUE

	var/brittle = FALSE
	var/smash_weaken = 0 // Decides how much weakening it may inflict (if any) when smashing someone's head

	var/base_name = null // Name to put in front of stuff, i.e. "[base_name] of [contents]"
	var/base_desc = null
	var/base_icon = null // Base icon name for fill states
	var/filling_states   // List of percentages full that have icons
	var/overlay_icon = FALSE // Overlay drawn over the filling overlay, behind the label and lid overlays. Default values are TRUE/FALSE, actual state generates upon initialization if set to TRUE.

	var/dynamic_name = FALSE // Should it become a "vessel of something" when not empty.
	var/precise_measurement = FALSE // Decides whether one can measure contents' volume precisely.

	var/lid_type = /datum/vessel_lid/lid
	var/datum/vessel_lid/lid = null
	var/override_lid_state = null // Overrides the lid's default state if not null.
	var/override_lid_icon = null // Overrides the lid's generated icon_state if not null.

	var/start_label = null
	var/has_label = FALSE
	var/label_icon = FALSE

	//bottle flipping
	var/can_flip = FALSE
	var/last_flipping = 0
	var/image/flipping = null

	var/list/can_be_placed_into = list(
		/obj/structure/table,
		/obj/structure/closet,
		/obj/structure/sink,
		/obj/item/storage,
		/obj/machinery/atmospherics/unary/cryo_cell,
		/obj/item/storage/secure/safe,
		/obj/structure/iv_drip,
		/obj/machinery/disposal,
		/obj/machinery/sleeper,
		/obj/machinery/constructable_frame,
	)

/obj/item/reagent_containers/vessel/Initialize()
	. = ..()
	
	if(!base_icon)
		base_icon = icon_state
	if(!base_name)
		base_name = name
	if(!base_desc)
		base_desc = desc

	if(lid_type)
		lid = new lid_type()
		lid.setup(src, override_lid_state, override_lid_icon)

	if(label_icon)
		label_icon = "label_[base_icon]"
	if(overlay_icon)
		overlay_icon = "over_[base_icon]"

	if(start_label)
		SetName(base_name)
		AddComponent(/datum/component/label, start_label) // So the name isn't hardcoded and the label can be removed for reusability
	
	update_icon()

/obj/item/reagent_containers/vessel/Destroy()
	QDEL_NULL(lid)
	return ..()

/obj/item/reagent_containers/vessel/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/vessel/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/vessel/attack_hand()
	..()
	update_icon()

/obj/item/reagent_containers/vessel/post_attach_label(datum/component/label/L)
	has_label = TRUE
	label_text = L.label_name
	update_icon()

/obj/item/reagent_containers/vessel/post_remove_label(datum/component/label/L)
	..()
	has_label = FALSE
	desc = base_desc
	label_text = ""
	update_icon()

/// Layers order:
// 1. Own icon_state
// 2. filling_states (if present)
// 3. overlay_icon (if present)
// 4. label_icon (if present)
// 5. lid.icon_state (if present)
/obj/item/reagent_containers/vessel/on_update_icon()
	ClearOverlays()
	// TODO: CHEM
	// 	if(dynamic_name)
	// 		var/datum/reagent/R = reagents.get_master_reagent()
	// 		update_name_label()
	// 		SetName("[name] of [R.glass_name ? R.glass_name : "something"]")
	// 		desc = R.glass_desc ? R.glass_desc : base_desc
	if(filling_states)
		var/image/filling = image(icon, src, "[base_icon][get_filling_state()]")
		filling.color = get_combined_color_hex_blended()
		AddOverlays(filling)

	if(overlay_icon)
		AddOverlays(image(icon, src, overlay_icon))

	if(has_label && label_icon)
		AddOverlays(image(icon, src, label_icon))

	if(lid)
		AddOverlays(image(lid.icon, src, lid.get_icon_state()))

/obj/item/reagent_containers/vessel/proc/get_filling_state()
	var/percent = round((get_used_volume() / volume) * 100)
	for(var/k in cached_number_list_decode(filling_states))
		if(percent <= k)
			return k

/obj/item/reagent_containers/vessel/update_name_label()
	if(!label_text || label_text == "")
		SetName(base_name)
	else
		SetName("[base_name] ([label_text])")

/obj/item/reagent_containers/vessel/examine(mob/user, infix)
	. = ..()

	. += "Can hold up to <b>[round(volume * 1000, 1)]</b> ml."

	if(get_dist(src, user) > 2)
		return

	var/used_volume = get_used_volume()

	if(precise_measurement)
		if(used_volume > 0.0)
			var/list/phases = list()

			if(Z_CHEM_GET_LIQUID_PHASES(src) > 0)
				phases += "liquid"
			if(Z_CHEM_GET_SOLID_PHASES(src) > 0)
				phases += "solid"

			if(length(phases))
				. += SPAN_NOTICE("It contains <b>[round(used_volume * 1000, 1)]</b>ml of [phases.Join(" and ")].")
			else
				. += SPAN_NOTICE("It is empty.")
		else
			. += SPAN_NOTICE("It is empty.")
	else
		var/ratio = used_volume / volume
		var/ratio_text = ""

		switch(ratio)
			if(0)
				ratio_text = "empty"
			if(0.01 to 0.25)
				ratio_text = "almost empty"
			if(0.25 to 0.66)
				ratio_text = "half full"
			if(0.66 to 0.90)
				ratio_text = "almost full"
			else
				ratio_text = "full"

		. += SPAN_NOTICE("\The [src] is <b>[ratio_text]</b>!")

	var/moles_boiled = Z_CHEM_GET_BOILED_MOLES(src)
	ASSERT(moles_boiled != null)

	var/moles_evaporated = Z_CHEM_GET_EVAPORATED_MOLES(src)
	ASSERT(moles_evaporated != null)

	var/evap_visible_threshold = 0.0001

	if(moles_boiled > evap_visible_threshold)
		. += SPAN_NOTICE("The contents are bubbling.")

	if(moles_evaporated > evap_visible_threshold)
		if(moles_boiled > evap_visible_threshold)
			. += SPAN_NOTICE("Thick steam billows from the opening.")
		else
			. += SPAN_NOTICE("Wisps of vapor rise from the opening.")

	if(lid)
		. += "[lid.get_examine_hint()]"

	if(Adjacent(user, src) && is_open_container())
		. += get_contents_smell_description()

	. += get_contents_visual_description()

/obj/item/reagent_containers/vessel/proc/get_contents_visual_description()
	var/list/descriptions = list()

	var/list/gas_flavor = Z_CHEM_GET_GAS_FLAVOR(src)
	ASSERT(gas_flavor != null)

	var/gas_desc = get_phase_color_description(gas_flavor, "vapor")

	if(gas_desc)
		descriptions += gas_desc

	var/liquid_phases = Z_CHEM_GET_LIQUID_PHASES(src)
	ASSERT(liquid_phases != null)

	var/list/visible_liquid_layers = list()

	for(var/i = 0 to liquid_phases - 1)
		var/list/liquid_flavor = Z_CHEM_GET_LIQUID_PHASE_FLAVOR(src, i)
		ASSERT(liquid_flavor != null)

		var/list/colors = liquid_flavor[1]
		var/list/intensities = liquid_flavor[2]

		if(colors && length(colors) && intensities && length(intensities))
			var/is_transparent = (colors[1] == Z_COLOR_TRANSPARENT)
			var/intensity = intensities[1]

			if(length(visible_liquid_layers))
				var/list/prev_layer = visible_liquid_layers[visible_liquid_layers.len]
				
				if(is_transparent && prev_layer["is_transparent"])
					if(abs(intensity - prev_layer["intensity"]) <= 0.1)
						continue

			visible_liquid_layers += list(list(
				"flavor" = liquid_flavor,
				"is_transparent" = is_transparent,
				"intensity" = intensity
			))

	var/visible_liquids_count = length(visible_liquid_layers)
	
	for(var/i = 1 to visible_liquids_count)
		var/list/layer_data = visible_liquid_layers[i]
		var/phase_name = visible_liquids_count > 1 ? "liquid layer [i]" : "liquid"
		var/liquid_desc = get_phase_color_description(layer_data["flavor"], phase_name)

		if(liquid_desc)
			descriptions += liquid_desc

	var/solid_phases = Z_CHEM_GET_SOLID_PHASES(src)
	ASSERT(solid_phases != null)

	for(var/i = 0 to solid_phases - 1)
		var/list/solid_flavor = Z_CHEM_GET_SOLID_PHASE_FLAVOR(src, i)
		var/diameter = Z_CHEM_GET_SOLID_PHASE_PARTICLE_DIAMETER(src, i)

		if(solid_flavor)
			var/solid_desc = get_solid_phase_description(solid_flavor, diameter, i, solid_phases)

			if(solid_desc)
				descriptions += solid_desc

	if(!length(descriptions))
		return null

	return descriptions.Join("\n")

/obj/item/reagent_containers/vessel/proc/get_phase_color_description(list/flavor, phase_name)
	if(!flavor || !length(flavor) || length(flavor) < 2)
		return null

	var/list/colors = flavor[1]
	var/list/color_intensities = flavor[2]

	if(!colors || !length(colors))
		return null

	var/primary_color = colors[1]
	if(primary_color == Z_COLOR_TRANSPARENT)
		return null

	var/primary_intensity = color_intensities[1]
	var/intensity_word = get_color_intensity_word(primary_intensity)
	var/color_name = __z_color_names[primary_color + 1]
	var/color_hex = __z_color_hex[primary_color + 1]

	var/desc = "The [phase_name] is "
	if(intensity_word)
		desc += "[intensity_word] "

	desc += "<font color='[color_hex]'><b>[color_name]</b></font>"

	if(length(colors) > 1 && colors[2] != Z_COLOR_TRANSPARENT)
		var/secondary_color = colors[2]
		var/secondary_hex = __z_color_hex[secondary_color + 1]
		var/secondary_name = __z_color_names[secondary_color + 1]
		desc += " with a <font color='[secondary_hex]'><b>[secondary_name]</b></font> tint"

	desc += "."

	return desc

/obj/item/reagent_containers/vessel/proc/get_solid_phase_description(list/flavor, diameter, phase_idx, total_phases)
	if(!flavor || !length(flavor) || length(flavor) < 2)
		return null

	var/list/colors = flavor[1]
	var/list/color_intensities = flavor[2]

	if(!colors || !length(colors))
		return null

	var/size_word = get_particle_size_word(diameter)

	var/primary_color = colors[1]
	var/primary_intensity = color_intensities[1]
	var/intensity_word = get_color_intensity_word(primary_intensity)
	var/color_name = __z_color_names[primary_color + 1]
	var/color_hex = __z_color_hex[primary_color + 1]

	var/desc = "There is "
	if(intensity_word)
		desc += "[intensity_word] "

	desc += "<font color='[color_hex]'><b>[color_name]</b></font> [size_word]"

	if(length(colors) > 1 && colors[2] != Z_COLOR_TRANSPARENT)
		var/secondary_color = colors[2]
		var/secondary_hex = __z_color_hex[secondary_color + 1]
		var/secondary_name = __z_color_names[secondary_color + 1]
		desc += " with <font color='[secondary_hex]'><b>[secondary_name]</b></font> specks"

	desc += "."

	return desc

/obj/item/reagent_containers/vessel/proc/get_contents_smell_description()
	var/list/flavor = Z_CHEM_GET_ODOR(src)
	ASSERT(flavor != null)

	var/list/odors = flavor[3]
	var/list/odors_intensity = flavor[4]

	if(!odors || !length(odors))
		return "It doesn't smell like anything."

	if(odors[1] == Z_ODOR_NONE && (length(odors) < 2 || odors[2] == Z_ODOR_NONE))
		return "It doesn't smell like anything."

	var/list/odor_descriptions = list()

	for(var/i = 1 to length(odors))
		var/odor = odors[i]

		if(odor == Z_ODOR_NONE)
			continue

		var/odor_name = __z_odor_names[odor + 1]
		var/intensity = odors_intensity[i]
		var/intensity_word = get_odor_intensity_word(intensity)

		if(intensity_word)
			odor_descriptions += "[intensity_word] [odor_name]"
		else
			odor_descriptions += odor_name

	if(!length(odor_descriptions))
		return "It doesn't smell like anything."

	var/smell_string = "It smells "

	if(length(odor_descriptions) == 1)
		smell_string += "[SPAN_NOTICE(odor_descriptions[1])]."
	else
		smell_string += "[SPAN_NOTICE(odor_descriptions[1])] with a hint of [SPAN_NOTICE(odor_descriptions[2])]."

	return smell_string

/obj/item/reagent_containers/vessel/proc/get_combined_color_hex_blended()
	var/total_r = 0
	var/total_g = 0
	var/total_b = 0
	var/total_weight = 0
	var/colored_weight = 0

	var/liquid_phases = Z_CHEM_GET_LIQUID_PHASES(src)
	if(liquid_phases)
		for(var/i = 0 to liquid_phases - 1)
			var/list/flavor = Z_CHEM_GET_LIQUID_PHASE_FLAVOR(src, i)
			ASSERT(flavor != null)

			var/list/colors = flavor[1]
			var/list/intensities = flavor[2]

			for(var/j = 1 to min(length(colors), liquid_phases))
				var/color_id = colors[j]
				var/weight = intensities[j] * (j == 1 ? 1.0 : 0.3)

				if(color_id == Z_COLOR_TRANSPARENT)
					total_weight += 1.0
					continue

				var/hex = __z_color_hex[color_id + 1]

				total_r += hex2num(copytext(hex, 2, 4)) * weight
				total_g += hex2num(copytext(hex, 4, 6)) * weight
				total_b += hex2num(copytext(hex, 6, 8)) * weight
				total_weight += weight
				colored_weight += weight

	var/solid_phases = Z_CHEM_GET_SOLID_PHASES(src)
	if(solid_phases)
		for(var/i = 0 to solid_phases - 1)
			var/list/flavor = Z_CHEM_GET_SOLID_PHASE_FLAVOR(src, i)
			ASSERT(flavor != null)

			var/list/colors = flavor[1]
			var/list/intensities = flavor[2]

			for(var/j = 1 to min(length(colors), solid_phases))
				var/color_id = colors[j]
				var/weight = intensities[j] * (j == 1 ? 0.7 : 0.2)

				if(color_id == Z_COLOR_TRANSPARENT)
					total_weight += 1.0
					continue

				var/hex = __z_color_hex[color_id + 1]

				total_r += hex2num(copytext(hex, 2, 4)) * weight
				total_g += hex2num(copytext(hex, 4, 6)) * weight
				total_b += hex2num(copytext(hex, 6, 8)) * weight
				total_weight += weight
				colored_weight += weight

	if(total_weight <= 0)
		return "#FFFFFF00"

	if(colored_weight <= 0)
		return "#FFFFFF00"

	var/base_r = total_r / colored_weight
	var/base_g = total_g / colored_weight
	var/base_b = total_b / colored_weight

	var/color_ratio = colored_weight / total_weight

	var/r = clamp(round(255 + (base_r - 255) * color_ratio), 0, 255)
	var/g = clamp(round(255 + (base_g - 255) * color_ratio), 0, 255)
	var/b = clamp(round(255 + (base_b - 255) * color_ratio), 0, 255)

	return "#[num2hex(r, 2)][num2hex(g, 2)][num2hex(b, 2)]"

/obj/item/reagent_containers/vessel/attack_self(mob/user)
	..()
	if(lid?.toggle(user))
		ASSERT(Z_CHEM_ENSURE_HEADSPACE(src, volume, nullspace_container) != null)
		ASSERT(Z_CHEM_CLEAR(nullspace_container))
		update_icon()
		return

/obj/item/reagent_containers/vessel/attack(mob/M, mob/user, def_zone)
	if(force && !(item_flags & ITEM_FLAG_NO_BLUDGEON) && user.a_intent == I_HURT)
		return ..()

	return FALSE
/obj/item/reagent_containers/vessel/standard_pour_into(mob/user, atom/target)
	if(!is_open_container())
		to_chat(user, SPAN("notice", "You need to open \the [src] first."))
		return TRUE
	return ..()

/obj/item/reagent_containers/vessel/afterattack(obj/target, mob/user, proximity)
	if(!is_open_container() || !proximity) //Is the container open & are they next to whatever they're clicking?
		return //If not, do nothing.
	for(var/type in can_be_placed_into) //Is it something it can be placed into?
		if(istype(target, type))
			return
	if(standard_pour_into(user, target)) //Pouring into another beaker?
		return
	return ..()

//when thrown on impact, brittle containers smash and spill their contents
/obj/item/reagent_containers/vessel/throw_impact(atom/hit_atom, datum/thrownthing/TT)
	..()
	if(brittle && TT.thrower && TT.thrower.a_intent != I_HELP)
		if(TT.speed < throw_speed || smash_check(TT.dist_travelled)) // not as reliable as smashing directly
			smash(loc, hit_atom)

/obj/item/reagent_containers/vessel/proc/smash_check(distance)
	if(!brittle)
		return FALSE

	var/list/chance_table = list(95, 95, 90, 85, 75, 60, 40, 15) //starting from distance 0
	var/idx = max(distance + 1, 1) //since list indices start at 1
	if(idx > chance_table.len)
		return FALSE
	return prob(chance_table[idx])

/obj/item/reagent_containers/vessel/proc/smash(newloc, atom/against = null)
	if(ismob(loc))
		var/mob/M = loc
		M.drop(src, force = TRUE)

	//Creates a shattering noise and replaces the vessel with a broken_bottle
	var/obj/item/broken_bottle/B = new /obj/item/broken_bottle(newloc)
	if(prob(w_class * 2.5))
		new /obj/item/material/shard(newloc) // Create a glass shard at the target's location!
	B.SetName("broken [base_name]")
	B.icon_state = icon_state
	B.w_class = w_class
	B.force = force
	B.mod_weight = mod_weight
	B.mod_reach = mod_reach
	B.mod_handy = mod_handy

	var/icon/I = new(src.icon, src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	playsound(src, SFX_BREAK_WINDOW, 70, 1)
	transfer_fingerprints_to(B)

	qdel(src)
	return B

/obj/item/reagent_containers/vessel/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	var/blocked = ..()

	if(user.a_intent != I_HURT)
		return
	if(!smash_check(1))
		return //won't always break on the first hit

	// You are going to knock someone out for longer if they are not wearing a helmet.
	var/weaken_duration = 0
	if(blocked < 100)
		weaken_duration = smash_weaken + min(0, force - target.get_flat_armor(hit_zone, "melee") + 10)

	var/mob/living/carbon/human/H = target
	if(istype(H) && H.headcheck(hit_zone))
		var/obj/item/organ/affecting = H.get_organ(hit_zone) // headcheck should ensure that affecting is not null
		user.visible_message(SPAN("danger", "[user] smashes [src] into [H]'s [affecting.name]!"))
		if(weaken_duration)
			if(prob(100 - H.poise)) // 50% if poise is full, 100% is poise is empty
				target.apply_effect(min(weaken_duration, 5), WEAKEN, blocked) // Never weaken more than a flash!
	else
		user.visible_message(SPAN("danger", "\The [user] smashes [src] into [target]!"))

	//Finally, smash the bottle. This kills (qdel) the vessel.
	var/obj/item/broken_bottle/B = smash(target.loc, target)
	user.pick_or_drop(B, target.loc)

	return blocked

/obj/item/reagent_containers/vessel/equipped(mob/user)
	. = ..()
	if(can_flip && (user.a_intent == I_GRAB))
		bottleflip(user)

/obj/item/reagent_containers/vessel/dropped(mob/user)
	. = ..()
	if(flipping)
		item_state = initial(item_state)
		last_flipping = world.time
		if(!(MUTATION_BARTENDER in user.mutations) && prob(50))
			var/turf/flip_turf = get_turf(flipping)
			if(brittle)
				smash(flip_turf, flip_turf)
			else
				throw_impact(flip_turf, 1)
		else
			playsound(src, 'sound/effects/slap.ogg', 100, 1, -2)
		QDEL_NULL(flipping)

/obj/item/reagent_containers/vessel/proc/bottleflip(mob/user)
	playsound(src, 'sound/effects/woosh.ogg', 50, 1, -2)
	last_flipping = world.time
	var/this_flipping = last_flipping
	item_state = "invisible"
	user.update_inv_l_hand()
	user.update_inv_r_hand()
	if(flipping)
		qdel(flipping)
	var/pixOffX = 0
	var/fliplay = user.layer + 1
	var/rotate = 1
	var/anim_icon_state = initial(item_state)
	if (!anim_icon_state)
		anim_icon_state = initial(icon_state)
	if(user.active_hand == ACTIVE_HAND_RIGHT)
		switch(user.dir)
			if (NORTH)
				pixOffX = 3
				fliplay = user.layer - 1
				rotate = -1
			if (SOUTH)
				pixOffX = -4
			if (WEST)
				pixOffX = -7
			if (EAST)
				pixOffX = 2
				rotate = -1
	else
		switch(user.dir)
			if (NORTH)
				pixOffX = -4
				fliplay = user.layer - 1
			if (SOUTH)
				pixOffX = 3
				rotate = -1
			if (WEST)
				pixOffX = -2
			if (EAST)
				pixOffX = 7
				rotate = -1
	flipping = image('icons/obj/bottleflip.dmi', user, anim_icon_state, fliplay, user.dir, pixOffX)
	flipping = anim(target = user, a_icon = 'icons/obj/bottleflip.dmi', a_icon_state = anim_icon_state, sleeptime = FLIPPING_DURATION, offX = pixOffX, lay = fliplay)
	animate(flipping, pixel_y = 12, transform = turn(matrix(), rotate*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 18, transform = turn(matrix(), rotate*2*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 21, transform = turn(matrix(), rotate*3*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 24, transform = turn(matrix(), rotate*4*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 21, transform = turn(matrix(), rotate*5*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 18, transform = turn(matrix(), rotate*6*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 12, transform = turn(matrix(), rotate*7*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	animate(pixel_y = 0, transform = turn(matrix(), rotate*8*FLIPPING_INCREMENT), time = FLIPPING_DURATION/8, easing = LINEAR_EASING)
	spawn(FLIPPING_DURATION)
		if(!flipping)
			return

		var/turf/flip_turf = get_turf(flipping)
		if(flip_turf != get_turf(user))
			to_chat(user, SPAN_WARNING("Your fail to catch back \the [src]."))
			user.drop(src, flip_turf, force = TRUE)
			QDEL_NULL(flipping)
			return

		if(loc == user && this_flipping == last_flipping) // Only the last flipping action will reset the bottle's vars
			if(!(MUTATION_BARTENDER in user.mutations) && prob(50))
				to_chat(user, SPAN_WARNING("Your fail to catch back \the [src]."))
				user.drop(src, flipping.loc, force = TRUE)
			else
				item_state = initial(item_state)
				user.update_inv_l_hand()
				user.update_inv_r_hand()
				user.ImmediateOverlayUpdate()
				playsound(src, 'sound/effects/slap.ogg', 50, 1, -2)
			QDEL_NULL(flipping)
			last_flipping = world.time

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/broken_bottle
	name = "Broken Bottle"
	desc = "What used to be a glass vessel earlier, with a sharp broken bottom."
	icon = 'icons/obj/reagent_containers/bottles.dmi'
	icon_state = "broken_bottle"
	force = 8.5
	mod_weight = 0.5
	mod_reach = 0.4
	mod_handy = 0.75
	armor_penetration = 20
	throwforce = 5
	throw_range = 5
	item_state = "beer"
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("stabbed", "slashed", "attacked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 1
	edge = 0
	unacidable = 1
	var/icon/broken_outline = icon('icons/obj/reagent_containers/vessels.dmi', "broken")

	drop_sound = SFX_DROP_GLASSSMALL
	pickup_sound = SFX_PICKUP_GLASSSMALL
