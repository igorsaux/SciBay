/obj/item/nullspace_container
	name = "Nullspace Container"

/obj/item/nullspace_container/Initialize()
	. = ..()
	
	ASSERT(Z_CHEM_CREATE(src))

/obj/item/nullspace_container/Destroy()
	ASSERT(Z_CHEM_DESTROY(src))

	. = ..()

var/obj/item/nullspace_container/nullspace_container = new()

/obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = ITEM_SIZE_SMALL
	var/amount_per_transfer_from_this = 50
	var/possible_transfer_amounts = "50;100;150;250;300"
	var/volume = 0.3 LITERS
	/// Area of the bottom of the cylinder in m^2
	var/bottom_area = 0.006
	/// Area of the neck opening for gas exchange. If null, bottom_area is used.
	var/neck_area = null
	/// Baseline heat capacity of the container itself (e.g., a glass beaker) in J/K.
	var/heat_capacity = 180
	// Pa
	var/max_pressure = 34473
	var/label_text
	var/can_be_splashed = FALSE
	var/alist/startswith // List of reagents to start with

	var/__stratification = 0.0
	var/__stirring = 0.0

	var/__last_think = 0

	var/__cached_height = 0
	var/__cached_area = 0

/obj/item/reagent_containers/Initialize(mapload, spawn_empty = FALSE)
	. = ..(mapload)

	if(!possible_transfer_amounts)
		src.verbs -= /obj/item/reagent_containers/verb/set_APTFT

	ASSERT(Z_CHEM_CREATE(src))
	update_geometry()
	ASSERT(Z_CHEM_SET_HEAT_CAPACITY(src, heat_capacity))

	if(length(startswith) && !spawn_empty)
		for(var/molecule in startswith)
			if(islist(startswith[molecule]))
				var/list/data = startswith[molecule]
				var/target_volume = data[1]
				var/particle_diameter = data[2]
				
				ASSERT(Z_CHEM_ADD_VOLUME(src, molecule, target_volume, particle_diameter))
			else
				var/target_volume = startswith[molecule]

				ASSERT(Z_CHEM_ADD_VOLUME(src, molecule,target_volume, 0))

		startswith = null // Unnecessary lists bad
		update_icon()

	ASSERT(Z_CHEM_ENSURE_HEADSPACE(src, volume, nullspace_container) != null)
	ASSERT(Z_CHEM_CLEAR(nullspace_container))
	ASSERT(Z_CHEM_RESET_GAS(src, volume))
	ASSERT(Z_CHEM_SET_TEMPERATURE(src, 20 CELSIUS, volume))

	__last_think = world.time
	set_next_think(__last_think + world.tick_lag)

/obj/item/reagent_containers/Destroy()
	ASSERT(Z_CHEM_DESTROY(src))

	. = ..()

/obj/item/reagent_containers/proc/set_stirring(value)
	__stirring = clamp(value, 0.0, 1.0)

	if(__stirring > 0.0)
		__stratification = 0.0
	
	ASSERT(Z_CHEM_SET_STIRRING(src, __stirring) != null)

/obj/item/reagent_containers/proc/adjust_stirring(delta)
	set_stirring(__stirring + delta)

/obj/item/reagent_containers/proc/set_stratification(value)
	if(__stirring > 0.0)
		__stratification = 0.0
	else
		__stratification = clamp(value, 0.0, 1.0)

/obj/item/reagent_containers/proc/adjust_stratification(delta)
	set_stratification(__stratification + delta)

/obj/item/reagent_containers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in usr

	var/N = tgui_input_list(usr, "Amount per transfer from this:", "[src]", cached_number_list_decode(possible_transfer_amounts))
	if(N)
		amount_per_transfer_from_this = N

/obj/item/reagent_containers/proc/update_geometry()
	// Volume in m^3 (Liters * 0.001)
	var/vol_m3 = volume * 0.001
	__cached_height = vol_m3 / bottom_area
	
	// Total surface area of a cylinder: 2*base + circumference*height
	var/circumference = 2 * sqrt(M_PI * bottom_area)
	__cached_area = (2 * bottom_area) + (circumference * __cached_height)

	ASSERT(Z_CHEM_SET_GAS_CONTACT_AREA(src, neck_area || bottom_area))

/obj/item/reagent_containers/think()
	var/dt = (world.time - __last_think) / 10

	update(dt)
	__last_think = world.time
	set_next_think(__last_think + world.tick_lag)

/obj/item/reagent_containers/proc/update(dt)
	var/turf/T = get_turf(src)

	if(T)
		var/datum/gas_mixture/M = T.return_air()

		ASSERT(Z_CHEM_EXCHANGE_HEAT(src, M.temperature, 10 * __cached_area, dt) != null)

	if(is_open_container())
		ASSERT(Z_CHEM_RESET_GAS(src, volume))

	if(istype(loc, /obj/item/bunsen))
		var/obj/item/bunsen/B = loc

		if(B.is_on)
			var/effective_flame_temp = 600 + (B.flame_temperature - 600) * B.strength
			var/conv = B.max_convection * (0.3 + 0.7 * B.strength)
			ASSERT(Z_CHEM_EXCHANGE_HEAT(src, effective_flame_temp, conv * bottom_area, dt) != null)

	ASSERT(Z_CHEM_UPDATE_PHASE_TRANSITIONS(src, dt, volume))
	ASSERT(Z_CHEM_INTEGRATE(src, dt, volume))
	ASSERT(Z_CHEM_SETTLE(src))

	if(is_open_container())
		ASSERT(Z_CHEM_ENSURE_HEADSPACE(src, volume, nullspace_container) != null)
		ASSERT(Z_CHEM_CLEAR(nullspace_container))
		ASSERT(Z_CHEM_SET_PRESSURE(src, 101325))
	else
		ASSERT(Z_CHEM_UPDATE_PRESSURE(src, volume))

		var/pressure = Z_CHEM_GET_PRESSURE(src)

		if((pressure - 101325) > max_pressure)
			visible_message("\the [src] explodes due to high pressure!")
			explosion(get_turf(src), 0, 0, 1, 0)
			qdel(src)

			return

	var/moles_boiled = Z_CHEM_GET_BOILED_MOLES(src)
	ASSERT(moles_boiled != null)

	if(moles_boiled)
		THROTTLE(boiling_sfx_cd, 8 SECOND)

		if(boiling_sfx_cd)
			playsound(src, 'sound/effects/bubbles2.ogg', 50, FALSE)

	var/solids = Z_CHEM_GET_SOLID_PHASES(src)
	var/liquids = Z_CHEM_GET_LIQUID_PHASES(src)

	ASSERT(solids != null)
	ASSERT(liquids != null)

	adjust_stratification(Z_CHEM_GET_STRATIFICATION_RATE(src, G0) * dt)

	var/new_stirring = __stirring * (0.9 ** dt)

	if(new_stirring < 0.01)
		new_stirring = 0.0

	adjust_stirring(new_stirring - __stirring)

	// TODO:
	// var/moles_evaporated = Z_CHEM_GET_EVAPORATED_MOLES(src)
	// ASSERT(moles_evaporated != null)
	// var/steam_intensity = moles_boiled + moles_evaporated
	// if(steam_intensity <= 0 || !is_open_container())
	// 	cut_overlay(steam_overlay)
	// 	steam_overlay = null
	// 	return
		
	update_icon()

/obj/item/reagent_containers/attack_self(mob/user)
	return

/obj/item/reagent_containers/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/pen) || istype(W, /obj/item/device/flashlight/pen))
		var/tmp_label = sanitizeSafe(input(user, "Enter a label for [name]", "Label", label_text), MAX_NAME_LEN)

		if(length(tmp_label) > 10)
			to_chat(user, "<span class='notice'>The label can be at most 10 characters long.</span>")
		else
			to_chat(user, "<span class='notice'>You set the label to \"[tmp_label]\".</span>")
			label_text = tmp_label
			update_name_label()
	else if(istype(W, /obj/item/lacmus))
		var/obj/item/lacmus/L = W

		if(!is_open_container())
			to_chat(user, SPAN_WARNING("\The [src] is not open."))
			return

		if(L.used)
			to_chat(user, SPAN_WARNING("\The [L] has already been used and cannot give accurate readings."))
			return

		var/liquid_phases = Z_CHEM_GET_LIQUID_PHASES(src)

		if(liquid_phases == 0)
			to_chat(user, SPAN_NOTICE("\The [src] contains no liquid to test."))
			return
		
		for(var/i = 0 to liquid_phases - 1)
			// TODO: maybe check a water concentration
			var/has_water = Z_CHEM_LIQUID_PHASE_HAS(src, i, Z_MOL_OXIDANE)
			ASSERT(has_water != null)

			if(!has_water)
				continue
			
			user.visible_message(
				SPAN_NOTICE("[user] dips \the [L] into \the [src]."),
				SPAN_NOTICE("You dip \the [L] into \the [src] and watch it change color.")
			)

			var/ph = Z_CHEM_LIQUID_PHASE_PH(src, i)

			var/deviation = rand() * 0.6 - 0.3
			L.ph = clamp(ph + deviation, 0, 14)
			L.used = TRUE
			L.update_icon()

			return
		
		user.visible_message(
			SPAN_NOTICE("[user] dips \the [L] into \the [src]."),
			SPAN_NOTICE("You dip \the [L] into \the [src] and nothing changes.")
		)

		return
	else if(istype(W, /obj/item/thermometer))
		dip_thermometer(user, W)
		return
	else
		return ..()

/obj/item/reagent_containers/proc/dip_thermometer(mob/user, obj/item/thermometer/T)
	if(!is_open_container())
		to_chat(user, SPAN_WARNING("\The [src] is not open."))
		return FALSE

	user.visible_message(
		SPAN_NOTICE("[user] carefully holds \the [T] in \the [src], waiting for the reading to stabilize."),
		SPAN_NOTICE("You dip \the [T] into \the [src] and wait for the reading to stabilize...")
	)

	if(!do_after(user, 6 SECONDS, src, TRUE))
		return FALSE
	
	var/temp = Z_CHEM_GET_TEMPERATURE(src)
	to_chat(user, SPAN_NOTICE("The thermometer reads [round(CONV_KELVIN_CELSIUS(temp), 0.1)]°C ([round(temp, 0.1)] K)."))

	return TRUE

/obj/item/reagent_containers/proc/update_name_label()
	if(label_text == "")
		SetName(initial(name))
	else
		SetName("[initial(name)] ([label_text])")

/obj/item/reagent_containers/proc/standard_pour_into(mob/user, obj/item/reagent_containers/target, transfer_amount = null)
	if(!Z_CHEM_HAS_CONTENTS(target))
		return FALSE

	if(!target.is_open_container())
		to_chat(user, SPAN_NOTICE("\The [target] is closed."))
		return TRUE

	if(is_empty())
		to_chat(user, SPAN_NOTICE("\The [src] is empty."))
		return TRUE

	var/to_transfer = transfer_amount || (amount_per_transfer_from_this / 1000)
	var/total_trans = Z_CHEM_POUR(src, target, to_transfer, target.volume, __stratification)
	ASSERT(total_trans != null)

	if(total_trans <= 0.0)
		to_chat(user, SPAN_NOTICE("There is no more room in \the [target]."))
		return TRUE

	playsound(target, 'sound/effects/using/bottles/transfer1.ogg')
	to_chat(user, SPAN_NOTICE("You transfer [round(total_trans * 1000, 1)] ml of the solution to \the [target]."))

	update_icon()
	target.update_icon()
	target.on_poured_to()

	return TRUE

/obj/item/reagent_containers/proc/on_poured_to()
	set_stirring(0.0)
	set_stratification(0.0)

/obj/item/reagent_containers/MouseDrop_T(atom/movable/dropping, mob/living/user, params)
	. = ..()

	if(!istype(dropping, /obj/item/reagent_containers))
		return

	var/obj/item/filter/F = user.get_active_item()

	if(QDELETED(F) || !istype(F, /obj/item/filter))
		return
	
	F.filter_into(dropping, src, user)

/obj/item/reagent_containers/AltClick(mob/user)
	if(!CanPhysicallyInteract(user))
		return
	if(!possible_transfer_amounts)
		return

	var/list/modes = list()
	for(var/mode in params2list(possible_transfer_amounts))
		modes += text2num(mode)

	var/current_index = modes.Find(amount_per_transfer_from_this)
	if(current_index == modes.len)
		amount_per_transfer_from_this = modes[1]
	else
		amount_per_transfer_from_this = modes[current_index + 1]

	to_chat(user, SPAN("notice", "You set the next amount per tranfser from \the [name]: <b>[amount_per_transfer_from_this]<b>"))

/obj/item/reagent_containers/CtrlAltClick(mob/user)
	if(possible_transfer_amounts)
		if(CanPhysicallyInteract(user))
			set_APTFT()
	else
		return ..()

/// Volume in L
/obj/item/reagent_containers/proc/get_liquids_volume()
	return Z_CHEM_GET_LIQUIDS_VOLUME(src) || 0.0

/// Weight in g
/obj/item/reagent_containers/proc/get_liquids_weight()
	return Z_CHEM_GET_LIQUIDS_WEIGHT(src) || 0.0

/// Volume in L
/obj/item/reagent_containers/proc/get_solids_volume()
	return Z_CHEM_GET_SOLIDS_VOLUME(src) || 0.0

/// Weight in g
/obj/item/reagent_containers/proc/get_solids_weight()
	return Z_CHEM_GET_SOLIDS_WEIGHT(src) || 0.0

/// Volume in L
/obj/item/reagent_containers/proc/get_used_volume()
	return get_liquids_volume() + get_solids_volume()

/obj/item/reagent_containers/proc/get_free_space()
	return max(volume - get_used_volume(), 0.0)

/obj/item/reagent_containers/proc/is_empty()
	return get_used_volume() <= 0.0

/obj/item/reagent_containers/Value(base)
	. = base
	
	var/total_volume = get_used_volume()

	if(total_volume <= 0.0)
		. = ceil(.)

		return
	
	var/const/purity_power = 1.0

	var/liquid_phases = Z_CHEM_GET_LIQUID_PHASES(src)
	var/solid_phases = Z_CHEM_GET_SOLID_PHASES(src)

	for(var/i = 0 to liquid_phases - 1)
		for(var/j = 0 to length(__z_molecules_meta) - 1)
			var/moles = Z_CHEM_GET_LIQUID_PHASE_MOLES(src, i, j)

			if(moles <= 0.0)
				continue

			var/datum/molecule_meta/meta = __z_molecules_meta[j + 1]
			var/component_volume = moles * (meta.weight / (meta.density * 1000.0))
			var/purity = component_volume / total_volume
			
			. += __molecules_cost[j + 1] * moles * (purity ** purity_power)

	for(var/i = 0 to solid_phases - 1)
		var/moles = Z_CHEM_GET_SOLID_PHASE_MOLES(src, i)

		if(moles <= 0.0)
			continue

		var/molecule = Z_CHEM_GET_SOLID_PHASE_MOLECULE(src, i)
		var/datum/molecule_meta/meta = __z_molecules_meta[molecule + 1]
		var/component_volume = moles * (meta.weight / (meta.density * 1000.0))
		var/purity = component_volume / total_volume
		
		. += __molecules_cost[molecule + 1] * moles * (purity ** purity_power)

	. = ceil(.)

/client/proc/cmd_print_reagent_container_debug_info(obj/item/reagent_containers/R)
	set name = "Reagents Debug Info"

	if(!check_rights(R_DEBUG))
		return

	var/info = Z_CHEM_GET_DEBUG_INFO(R, R.volume)
	ASSERT(info != null)

	to_chat(usr, info)
