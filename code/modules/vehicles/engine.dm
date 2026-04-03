/obj/item/engine
	name = "engine"
	desc = "An engine used to power a small vehicle."
	icon = 'icons/obj/objects.dmi'
	w_class = ITEM_SIZE_HUGE
	var/stat = 0
	var/trail_type
	var/cost_per_move = 5

/obj/item/engine/proc/get_trail()
	if(trail_type)
		return new trail_type
	return null

/obj/item/engine/proc/prefill()
	return

/obj/item/engine/proc/use_power()
	return 0

/obj/item/engine/proc/rev_engine(atom/movable/M)
	return

/obj/item/engine/proc/putter(atom/movable/M)
	return

/obj/item/engine/electric
	name = "electric engine"
	desc = "A battery-powered engine used to power a small vehicle."
	icon_state = "engine_electric"
	trail_type = /datum/effect/effect/system/trail/ion
	cost_per_move = 200	// W
	var/obj/item/cell/cell

/obj/item/engine/electric/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/cell))
		if(cell)
			to_chat(user, "<span class='warning'>There is already a cell in \the [src].</span>")
		else if(user.drop(I, src))
			cell = I
		return 1
	else if(isCrowbar(I))
		if(cell)
			to_chat(user, "You pry out \the [cell].")
			cell.forceMove(get_turf(src))
			cell = null
			return 1
	..()

/obj/item/engine/electric/prefill()
	cell = new /obj/item/cell/high(src.loc)

/obj/item/engine/electric/use_power()
	if(!cell)
		return 0
	return cell.use(cost_per_move * CELLRATE)

/obj/item/engine/electric/rev_engine(atom/movable/M)
	M.audible_message("\The [M] beeps, spinning up.", splash_override = "*beeeeep*")

/obj/item/engine/electric/putter(atom/movable/M)
	M.audible_message("\The [M] makes one depressed beep before winding down.", splash_override = "*beep...*")

/obj/item/engine/thermal
	name = "thermal engine"
	desc = "A fuel-powered engine used to power a small vehicle."
	icon_state = "engine_fuel"
	trail_type = /datum/effect/effect/system/trail/thermal
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	var/obj/temp_reagents_holder
	var/fuel_points = 0
	//fuel points are determined by differing reagents

/obj/item/engine/thermal/prefill()
	fuel_points = 5000

/obj/item/engine/thermal/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/reagent_containers) && I.is_open_container())
		if(istype(I,/obj/item/reagent_containers/pill))
			return 0
		var/obj/item/reagent_containers/C = I
		C.standard_pour_into(user,src)
		return 1
	..()

/obj/item/engine/thermal/use_power()
	return 0

/obj/item/engine/thermal/rev_engine(atom/movable/M)
	M.audible_message("\The [M] rumbles to life.", splash_override = "*rumble*")

/obj/item/engine/electric/putter(atom/movable/M)
	M.audible_message("\The [M] putters before turning off.", splash_override = "*pshh...*")
