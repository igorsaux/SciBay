
/obj/item/backwear/reagent/extinguisher
	name = "firefighting kit"
	desc = "An unwieldy, heavy backpack with two massive foam tanks and a retractable fire hose. Includes a connector for most models of fire extinguishers."
	icon_state = "foam0"
	base_icon = "foam"
	item_state = "backwear_extinguisher"
	hitsound = 'sound/effects/fighting/smash.ogg'
	gear_detachable = FALSE
	gear = /obj/item/extinguisher/linked
	atom_flags = null
	origin_tech = list(TECH_ENGINEERING = 2)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_GLASS = 500)

/obj/item/extinguisher/linked
	name = "fire hose"
	desc = "Fire extinguisher's elder brother. Connected to a firefighting kit, it turns a mere spaceman into an entire fire brigade."
	icon = 'icons/obj/backwear.dmi'
	icon_state = "firehose"
	item_state = "firehose"
	hitsound = SFX_FIGHTING_SWING
	force = 6.5
	mod_handy = 0.7
	mod_weight = 0.65
	mod_reach = 0.6
	armor_penetration = 20
	w_class = ITEM_SIZE_NORMAL
	spray_amount = 1 LITER
	spray_cooldown = 1 SECOND
	max_volume = 0
	safety = 0
	external_source = TRUE
	slot_flags = null
	attack_verb = list("whacked", "smacked", "attacked")
	canremove = FALSE
	force_drop = TRUE
	matter = null
	var/obj/item/backwear/reagent/base_unit

/obj/item/extinguisher/linked/New(newloc, obj/item/backwear/base)
	base_unit = base
	..(newloc)

/obj/item/extinguisher/linked/Destroy() //it shouldn't happen unless the base unit is destroyed but still
	if(base_unit)
		if(base_unit.gear == src)
			base_unit.gear = null
			base_unit.update_icon()
		base_unit = null
	return ..()

/obj/item/extinguisher/linked/dropped(mob/user)
	..()
	if(base_unit)
		base_unit.reattach_gear(user)


/obj/item/extinguisher/linked/afterattack(atom/target, mob/user, flag)
	return
