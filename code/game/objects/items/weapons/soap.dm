/obj/item/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	w_class = ITEM_SIZE_SMALL
	throwforce = 0
	throw_range = 20
	var/key_data

//attack_as_weapon
/obj/item/soap/attack(mob/living/target, mob/living/user, target_zone)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == BP_MOUTH)
		user.visible_message(SPAN("danger", "\The [user] washes \the [target]'s mouth out with soap!"))
		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN) //prevent spam
		return
	..()

/obj/item/soap/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/key))
		if(!key_data)
			to_chat(user, SPAN("notice", "You imprint \the [I] into \the [src]."))
			var/obj/item/key/K = I
			key_data = K.key_data
			update_icon()
		return
	..()

/obj/item/soap/on_update_icon()
	ClearOverlays()
	if(key_data)
		AddOverlays(image('icons/obj/items.dmi', icon_state = "soap_key_overlay"))

/obj/item/soap/nanotrasen
	desc = "A NanoTrasen-brand bar of soap. Smells of plasma."
	icon_state = "soapnt"

/obj/item/soap/deluxe
	icon_state = "soapdeluxe"

/obj/item/soap/deluxe/New()
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of [pick("lavender", "vanilla", "strawberry", "chocolate" ,"space")]."
	..()

/obj/item/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"

/obj/item/soap/gold
	desc = "One true soap to rule them all."
	icon_state = "soapgold"

/obj/item/soap/brig
	desc = "Train your security guards!"
	icon_state = "soapbrig"
