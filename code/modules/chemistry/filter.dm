/obj/item/filter
	name = "Filter"
	desc = "A device used to separate substances by particle size."
	icon = 'icons/chemistry.dmi'

	var/pore_size = 0.001 METERS
	var/clogged = 0.0
	var/clog_capacity = 0.02
	var/consumable = TRUE
	var/flow_rate = 1.0

/obj/item/filter/Value(base)
	. = ..(base)

	return ceil(base * max(1 - clogged, 0.1))

/obj/item/filter/proc/filter_into(obj/item/reagent_containers/source, obj/item/reagent_containers/dist, mob/activator = null)
	if(consumable && clogged >= 1.0)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [src] is completely clogged and must be replaced!"))

		return FALSE

	if(!source.is_open_container())
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [source] is closed."))

		return FALSE

	if(!dist.is_open_container())
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [dist] is closed."))

		return FALSE

	if(source.is_empty())
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [source] is empty."))

		return FALSE

	var/dist_free_space = dist.get_free_space()

	if(dist_free_space <= 0)
		if(activator)
			to_chat(activator, SPAN_WARNING("\The [dist] is full."))
		return FALSE

	var/flow_efficiency = consumable ? (1.0 - clogged) : 1.0
	var/target_transfer_vol = (source.amount_per_transfer_from_this / 1000) * flow_efficiency * flow_rate
	
	if(target_transfer_vol <= 0.001) // Prevent micro-transfers when nearly clogged
		if(activator)
			to_chat(activator, SPAN_WARNING("The flow through \the [src] is too restricted!"))

		return FALSE

	var/total_transferred = 0.0
	var/total_blocked_vol = 0.0

	var/liquids_vol = source.get_liquids_volume()

	if(liquids_vol > 0)
		var/liquid_to_transfer = min(target_transfer_vol, liquids_vol)
		var/liquid_transferred = Z_CHEM_TRANSFER_LIQUID_VOLUME(source, dist, liquid_to_transfer, dist.volume)
		ASSERT(liquid_transferred != null)

		total_transferred += liquid_transferred
		target_transfer_vol -= liquid_transferred
		dist_free_space -= liquid_transferred

	var/source_solids_volume = source.get_solids_volume()
	
	if(source_solids_volume > 0 && target_transfer_vol > 0 && dist_free_space > 0)
		var/actual_solid_transfer = min(target_transfer_vol, dist_free_space, source_solids_volume)
		var/transfer_fraction = actual_solid_transfer / source_solids_volume
		
		var/solid_phases = Z_CHEM_GET_SOLID_PHASES(source)
		ASSERT(solid_phases != null)

		for(var/i = solid_phases - 1; i >= 0; i--)
			var/moles = Z_CHEM_GET_SOLID_PHASE_MOLES(source, i)
			ASSERT(moles != null)

			if(moles <= 0)
				continue

			var/molecule = Z_CHEM_GET_SOLID_PHASE_MOLECULE(source, i)
			ASSERT(molecule != null)

			var/datum/molecule_meta/meta = __z_molecules_meta[molecule + 1]
			var/phase_volume = moles * (meta.weight / (meta.density * 1000.0))
			var/vol_to_process = phase_volume * transfer_fraction

			var/diameter = Z_CHEM_GET_SOLID_PHASE_PARTICLE_DIAMETER(source, i)
			ASSERT(diameter != null)

			if(diameter <= pore_size)
				var/transferred = Z_CHEM_TRANSFER_SOLID_PHASE_VOLUME(source, dist, i, vol_to_process, dist.volume)
				ASSERT(transferred != null)
				
				total_transferred += transferred
			else
				total_blocked_vol += vol_to_process

	if(total_blocked_vol > 0 && consumable)
		clogged = min(1.0, clogged + (total_blocked_vol / clog_capacity))

	if(total_transferred > 0)
		if(activator)
			// TODO: better sound
			playsound(dist, 'sound/effects/using/bottles/transfer1.ogg', 50, FALSE)
			
			var/flow_desc = "filters"
			if(consumable && clogged > 0.75)
				flow_desc = "slowly drips"
				
			activator.visible_message(
				SPAN_NOTICE("[activator] [flow_desc] the contents of \the [source] into \the [dist]."),
				SPAN_NOTICE("You successfully filter [round(total_transferred * 1000, 1)] ml of solution into \the [dist].")
			)

		source.update_icon()
		dist.update_icon()
	else if(total_blocked_vol > 0)
		if(activator)
			to_chat(activator, SPAN_WARNING("The remaining solids in \the [source] are too large to pass through \the [src]!"))

	if(consumable && clogged >= 1.0 && activator)
		to_chat(activator, SPAN_WARNING("\The [src] has become completely clogged with large particles!"))

	return TRUE

/obj/item/filter/examine(mob/user, infix)
	. = ..()

	var/readable_pore_size = ""
	if(pore_size >= 0.001)
		readable_pore_size = "[pore_size * 1000] mm"
	else
		readable_pore_size = "[pore_size * 1000000] &mu;m"

	. += "Pore size: <b>[readable_pore_size]</b>."

	var/speed_desc = "moderate"
	if(flow_rate >= 2.0)
		speed_desc = "very fast"
	else if(flow_rate >= 1.0)
		speed_desc = "moderate"
	else if(flow_rate >= 0.5)
		speed_desc = "slow"
	else
		speed_desc = "very slow"

	. += "Base flow rate: <b>[speed_desc]</b>."

	if(!consumable)
		. += SPAN_NOTICE("It is made of durable material and acts as a permanent barrier. It will not clog.")
	else
		if(clogged >= 1.0)
			. += SPAN_WARNING("It is completely clogged with particles and must be replaced!")
		else if(clogged >= 0.75)
			. += SPAN_WARNING("It is heavily clogged. Liquid will pass through very slowly.")
		else if(clogged >= 0.25)
			. += SPAN_NOTICE("It is partially clogged with trapped solids.")
		else if(clogged > 0.0)
			. += SPAN_NOTICE("It is slightly dirty, but still flows well.")
		else
			. += SPAN_NOTICE("It is completely clean.")


/obj/item/filter/sieve
	name = "Sieve"
	icon_state = "filter_sieve"
	pore_size = 0.002 METERS
	consumable = FALSE
	flow_rate = 2.0

/obj/item/filter/cloth
	name = "Cloth Filter"
	icon_state = "filter_cloth"
	pore_size = 0.0002 METERS
	clog_capacity = 0.1
	flow_rate = 1.0

/obj/item/filter/paper
	name = "Filter Paper"
	icon_state = "filter_paper"
	pore_size = 0.00001 METERS
	clog_capacity = 0.02
	flow_rate = 0.6

/obj/item/filter/membrane
	name = "Microscopic Membrane"
	icon_state = "filter_membrane"
	pore_size = 0.0000002 METERS
	clog_capacity = 0.005
	flow_rate = 0.2
