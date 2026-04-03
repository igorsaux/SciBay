//replaces our stun baton code with /tg/station's code
/obj/item/melee/baton
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	item_state = "baton"
	icon = 'icons/obj/weapons.dmi'
	slot_flags = SLOT_BELT
	force = 15
	sharp = 0
	edge = 0
	throwforce = 7
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.25
	mod_reach = 1.25
	mod_handy = 1.45
	origin_tech = list(TECH_COMBAT = 2)
	attack_verb = list("beaten")
	var/stunforce = 6
	var/agonyforce = 75
	var/status = 0		//whether the thing is on or not
	var/obj/item/cell/bcell
	var/hitcost = 10

/obj/item/melee/baton/loaded
	bcell = /obj/item/cell/device/high

/obj/item/melee/baton/New()
	if(ispath(bcell))
		bcell = new bcell(src)
		update_icon()
	..()

/obj/item/melee/baton/Destroy()
	if(bcell && !ispath(bcell))
		qdel(bcell)
		bcell = null
	return ..()

/obj/item/melee/baton/proc/deductcharge(chrgdeductamt)
	if(bcell)
		if(bcell.checked_use(chrgdeductamt))
			return 1
		else
			status = 0
			update_icon()
			return 0
	return null

/obj/item/melee/baton/on_update_icon()
	if(status)
		icon_state = "[initial(name)]_active"
	else if(!bcell)
		icon_state = "[initial(name)]_nocell"
	else
		icon_state = "[initial(name)]"

	if(icon_state == "[initial(name)]_active")
		set_light(0.4, 0.1, 1, 2, "#ff6a00")
	else
		set_light(0)

/obj/item/melee/baton/examine(mob/user, infix)
	. = ..()

	if(get_dist(src, user) > 1)
		return

	. += "[examine_cell()]"

// Addition made by Techhead0, thanks for fullfilling the todo!
/obj/item/melee/baton/proc/examine_cell()
	if(bcell)
		return "<span class='notice'>The baton is [round(CELL_PERCENT(bcell))]% charged.</span>"
	else
		return "<span class='warning'>The baton does not have a power source installed.</span>"

/obj/item/melee/baton/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/cell/device))
		if(!bcell && user.drop(W, src))
			bcell = W
			to_chat(user, "<span class='notice'>You install a cell into the [src].</span>")
			update_icon()
		else
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
	else if(isScrewdriver(W))
		if(bcell)
			bcell.update_icon()
			bcell.dropInto(loc)
			bcell = null
			to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")
			status = 0
			update_icon()
	else
		..()

/obj/item/melee/baton/attack_self(mob/user)
	set_status(!status, user)
	add_fingerprint(user)

/obj/item/melee/baton/proc/set_status(newstatus, mob/user)
	if(bcell && bcell.charge >= hitcost)
		if(status != newstatus)
			change_status(newstatus)
			to_chat(user, "<span class='notice'>[src] is now [status ? "on" : "off"].</span>")
			playsound(loc, pick('sound/effects/electric/spark8.ogg', 'sound/effects/electric/spark9.ogg', 'sound/effects/electric/spark10.ogg'), 70, FALSE, -1)
	else
		change_status(0)
		if(!bcell)
			to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		else
			to_chat(user,  "<span class='warning'>[src] is out of charge.</span>")

// Proc to -actually- change the status, and update the icons as well.
// Also exists to ease "helpful" admin-abuse in case an bug prevents attack_self
// to occur would appear. Hopefully it wasn't necessary.
/obj/item/melee/baton/proc/change_status(s)
	if (status != s)
		status = s
		update_icon()

/obj/item/melee/baton/attack(mob/M, mob/user)
	if(is_pacifist(user))
		to_chat(user, SPAN("warning", "You can't you're pacifist!"))
		return
	if(status && (MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='danger'>You accidentally hit yourself with the [src]!</span>")
		user.Weaken(30)
		user.Stun(30)
		deductcharge(hitcost)
		return
	return ..()

/obj/item/melee/baton/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	var/agony = agonyforce
	var/stun = stunforce
	var/obj/item/organ/external/affecting = null
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		affecting = H.get_organ(hit_zone)

	if(ishuman(target) && ishuman(user))
		var/mob/living/carbon/human/H = target
		var/mob/living/carbon/human/U = user
		if(H.parrying)
			if(H.handle_parry(U, src))
				return 0
		if(H.blocking)
			if(H.handle_block_weapon(U, src))
				return 0

	if(user.a_intent != I_HELP)
		. = ..()
		if(isnull(.))	//item/attack() does it's own messaging and logs
			return 0	// item/attack() will return 1 if they hit, 0 if they missed.

		//whacking someone causes a much poorer electrical contact than deliberately prodding them.
		stun *= 0.5
		if(status)		//Checks to see if the stunbaton is on.
			agony *= 0.5	//whacking someone causes a much poorer contact than prodding them.
		else
			agony = 0	//Shouldn't really stun if it's off, should it?
		//we can't really extract the actual hit zone from ..(), unfortunately. Just act like they attacked the area they intended to.

	else if(!status)
		if(affecting)
			target.visible_message("<span class='warning'>[target] has been prodded in the [affecting.name] with [src] by [user]. Luckily it was off.</span>")
		else
			target.visible_message("<span class='warning'>[target] has been prodded with [src] by [user]. Luckily it was off.</span>")
	else
		if(affecting)
			target.visible_message("<span class='danger'>[target] has been prodded in the [affecting.name] with [src] by [user]!</span>")
		else
			target.visible_message("<span class='danger'>[target] has been prodded with [src] by [user]!</span>")
		playsound(loc, SFX_STUNSTICK_HIT, 70, FALSE, -1)

	//stun effects
	if(status)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.handle_tasing(agony, stun, hit_zone, src)
		else
			target.stun_effect_act(stun, agony, hit_zone, src)
		msg_admin_attack("[key_name(user)] prodded [key_name(target)] with the [src].")

		deductcharge(hitcost)
	return 0

/obj/item/melee/baton/throw_impact(hit_atom, datum/thrownthing/TT)
	..()
	if(isliving(hit_atom) && status && prob(50))
		var/mob/living/L = hit_atom
		L.stun_effect_act(stun_amount = rand(2,5), agony_amount = rand(10, 90), def_zone = ran_zone(TT.target_zone, 30), used_weapon = src)
		playsound(L.loc, SFX_STUNSTICK_HIT, 70, FALSE, -1)
		deductcharge(hitcost)
