
/obj/item/backwear/reagent/welding
	name = "welding kit"
	desc = "An unwieldy, heavy backpack with two massive fuel tanks and a connected welding tool. Includes a connector for most models of portable welding tools."
	description_info = "This pack acts as a portable source of welding fuel. Use a welder on it to refill its tank - but make sure it's not lit! You can use this kit on a fuel tank or appropriate reagent dispenser to replenish its reserves."
	description_fluff = "The Shenzhen Chain of 2380 was an industrial accident of noteworthy infamy that occurred at Earth's L3 Lagrange Point. An apprentice welder, working for the Shenzhen Space Fabrication Group, failed to properly seal her fuel port, triggering a chain reaction that spread from laborer to laborer, instantly vaporizing a crew of fourteen. Don't let this happen to you!"
	description_antag = "In theory, you could hold an open flame to this pack and produce some pretty catastrophic results. The trick is getting out of the blast radius."
	icon_state = "fuel0"
	base_icon = "fuel"
	item_state = "backwear_welding"
	hitsound = 'sound/effects/fighting/smash.ogg'
	gear_detachable = FALSE
	gear = /obj/item/weldingtool/linked
	atom_flags = null
	origin_tech = list(TECH_ENGINEERING = 3)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_GLASS = 500)

/obj/item/backwear/reagent/welding/reattach_gear(mob/user)
	..()
	if(istype(gear, /obj/item/weldingtool/linked))
		var/obj/item/weldingtool/W = gear
		W.setWelding(0)

/obj/item/weldingtool/linked
	name = "welding tool"
	desc = "A lightweight welding tool connected to a welding kit."
	icon = 'icons/obj/backwear.dmi'
	icon_state = "welder"
	item_state = "welder"
	w_class = ITEM_SIZE_NORMAL
	force = 5.5
	mod_weight = 0.55
	mod_reach = 0.6
	mod_handy = 0.75
	canremove = FALSE
	force_drop = TRUE
	unacidable = 1 //TODO: make these replaceable so we won't need such ducttaping
	slot_flags = null
	tank = null
	matter = null
	var/obj/item/backwear/reagent/base_unit

/obj/item/weldingtool/linked/New(newloc, obj/item/backwear/base)
	base_unit = base
	..(newloc)

/obj/item/weldingtool/linked/Destroy() //it shouldn't happen unless the base unit is destroyed but still
	if(base_unit)
		if(base_unit.gear == src)
			base_unit.gear = null
			base_unit.update_icon()
		base_unit = null
	return ..()

/obj/item/weldingtool/linked/dropped(mob/user)
	..()
	if(base_unit)
		base_unit.reattach_gear(user)

/obj/item/weldingtool/linked/remove_fuel(amount = 1, mob/M = null)
	if(!welding)
		return 0
	if(get_fuel() >= amount)
		burn_fuel(amount)
		if(M)
			eyecheck(M)
			playsound(M.loc, 'sound/items/Welder.ogg', 20, 1)
		return 1
	else
		if(M)
			to_chat(M, "<span class='notice'>You need more welding fuel to complete this task.</span>")
		return 0

/obj/item/weldingtool/linked/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	..()

/obj/item/weldingtool/linked/attackby(obj/item/W, mob/user)
	if(welding)
		return
	if(isScrewdriver(W))
		return
	if(istype(W,/obj/item/pipe))
		return
	if(istype(W, /obj/item/welder_tank))
		return
	..()

/obj/item/weldingtool/linked/refuel_from_obj(obj/O, mob/user)
	return
