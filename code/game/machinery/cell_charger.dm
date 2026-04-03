/obj/machinery/cell_charger
	name = "heavy-duty cell charger"
	desc = "A much more powerful version of the standard recharger that is specially designed for charging power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger0"
	anchored = 1
	var/obj/item/cell/charging = null
	var/chargelevel = -1

	component_types = list(
		/obj/item/circuitboard/cell_charger,
		/obj/item/stock_parts/capacitor
	)

/obj/machinery/cell_charger/on_update_icon()
	icon_state = "ccharger[charging ? 1 : 0]"
	if(charging)
		ClearOverlays()
		if(charging.icon == icon)
			AddOverlays(charging.icon_state)
		else
			AddOverlays("cell")
		AddOverlays("ccharger-wires")
		if(!(stat & (BROKEN|NOPOWER)))
			chargelevel = round(CELL_PERCENT(charging) * 4.0 / 99)
			AddOverlays("ccharger-o[chargelevel]")
	else
		ClearOverlays()

/obj/machinery/cell_charger/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) > 5)
		return

	. += "There's [charging ? "a" : "no"] cell in the charger."

	if(charging)
		. += "Current charge: [charging.charge]"

/obj/machinery/cell_charger/attackby(obj/item/W, mob/user)
	if(stat & BROKEN)
		return

	if(istype(W, /obj/item/cell) && anchored)
		if(charging)
			to_chat(user, "<span class='warning'>There is already a cell in the charger.</span>")
			return
		else
			if(!user.drop(W, src))
				return
			charging = W
			START_PROCESSING(SSmachines, src)
			user.visible_message("[user] inserts a cell into the charger.", "You insert a cell into the charger.")
			chargelevel = -1
		queue_icon_update()

	if(isScrewdriver(W) || isCrowbar(W) || isWrench(W))
		if(charging)
			to_chat(user, "<span class='warning'>Remove the cell first!</span>")
			return
		if(default_deconstruction_screwdriver(user, W))
			return
		if(default_deconstruction_crowbar(user, W))
			return
		if(isWrench(W))
			anchored = !anchored
			to_chat(user, "You [anchored ? "attach" : "detach"] the cell charger [anchored ? "to" : "from"] the ground")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
	if(default_part_replacement(user, W))
		return

/obj/machinery/cell_charger/attack_hand(mob/user)
	if(charging)
		user.pick_or_drop(charging, loc)
		charging.add_fingerprint(user)
		charging.update_icon()

		src.charging = null
		user.visible_message("[user] removes the cell from the charger.", "You remove the cell from the charger.")
		chargelevel = -1
		update_icon()

/obj/machinery/cell_charger/Process()
	if(!charging)
		return PROCESS_KILL
	if(stat & NOPOWER)
		return
	update_icon()
