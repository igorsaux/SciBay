/obj/item/organ/internal/bladder
	name = "bladder"
	desc = "Water's transitional station on its way between glass and porcelain."
	icon_state = "bladder"
	dead_icon = "bladder"
	w_class = ITEM_SIZE_SMALL
	organ_tag = BP_BLADDER
	parent_organ = BP_GROIN
	min_bruised_damage = 25
	min_broken_damage = 45
	max_damage = 70
	relative_size = 25
	var/waste_to_spawn = 0

/obj/item/organ/internal/bladder/proc/rupture()
	if(owner)
		owner.custom_pain("Your feel a burst of sudden, excruciating pain in your groin!", 30)
	// TODO: Abdominal cavity here
	return

/obj/item/organ/internal/bladder/take_internal_damage(amount, silent = FALSE, is_traumatic = FALSE)
	var/oldbroken = is_broken()
	. = ..()
	if(owner && !owner.stat)
		if(!oldbroken && is_broken())
			rupture()
