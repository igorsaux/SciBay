var/list/organ_cache = list()

/obj/item/organ
	name = "organ"
	icon = 'icons/mob/human_races/organs/human.dmi'
	w_class = ITEM_SIZE_TINY
	dir = SOUTH

	// Strings.
	var/organ_tag = "organ"           // Unique identifier.
	var/parent_organ = BP_CHEST       // Organ holding this object.

	// Status tracking.
	var/status = 0                    // Various status flags (such as robotic)
	var/vital                         // Lose a vital limb, die immediately.

	// Reference data.
	var/mob/living/carbon/human/owner // Current mob owning the organ.
	var/datum/dna/dna                 // Original DNA.
	var/datum/species/species         // Original species.

	// Damage vars.
	var/damage = 0                    // Current damage to the organ
	var/min_broken_damage = 0         // Damage before becoming broken
	var/max_damage = 60               // Damage cap
	var/rejecting                     // Is this organ already being rejected?
	var/no_pain = FALSE

	var/death_time

	var/food_organ_type				  // path of food made from organ, ex.
	var/disable_food_organ = FALSE // used to override food_organ's creation and using

	/// List of installed augmentations.
	var/list/organ_modules = list()
	/// Types of modules without which this organ will not work. Applies ONLY to prosthetic limbs.
	var/list/necessary_organ_modules

	var/max_module_size = 1
	var/occupied_space = 0

	drop_sound = SFX_DROP_FLESH
	pickup_sound = SFX_PICKUP_FLESH

/obj/item/organ/Initialize()
	. = ..()

	if(!min_broken_damage)
		min_broken_damage = Floor(max_damage / 2)

	if(ishuman(loc))
		owner = loc
		w_class = max(w_class + mob_size_difference(owner.mob_size, MOB_MEDIUM), 1) //smaller mobs have smaller organs.
		dna = owner.dna ? owner.dna.Clone() : null

	if(dna)
		species = all_species[dna.species]
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[dna.unique_enzymes] = dna.b_type
	else
		species = all_species[SPECIES_HUMAN]
		log_debug("[src] spawned in [owner] without a proper DNA.")

/obj/item/organ/Destroy()
	owner = null
	dna = null

	QDEL_NULL_LIST(organ_modules)

	if(ismob(loc))
		var/mob/M = loc
		M.drop(src, force = TRUE, changing_slots = TRUE) // Changing_slots prevents drop_sound from playing

	return ..()

/obj/item/organ/think()
	if(loc != owner)
		owner = null

	//dead already, no need for more processing
	if(status & ORGAN_DEAD)
		return

	//Process infections
	if((owner?.species?.species_flags & SPECIES_FLAG_IS_PLANT))
		// If `think()` is called not by the owner in `handle_organs()` but on his own.
		if(NEXT_THINK)
			set_next_think(world.time + 1 SECOND)
		return

	if(owner)
		if(owner.bodytemperature >= 170)
			handle_rejection()

	//check if we've hit max_damage
	if(damage >= max_damage)
		die()

	// If `think()` is called not by the owner in `handle_organs()` but on his own.
	if(NEXT_THINK)
		set_next_think(world.time + 1 SECOND)

/obj/item/organ/proc/organ_eaten(mob/user)
	qdel(src)

/obj/item/organ/proc/is_broken()
	return (damage >= min_broken_damage || (status & ORGAN_CUT_AWAY) || (status & ORGAN_BROKEN))

/obj/item/organ/proc/set_dna(datum/dna/new_dna)
	if(!new_dna)
		return
	dna = new_dna.Clone()
	if(!blood_DNA)
		blood_DNA = list()
	blood_DNA.Cut()
	blood_DNA[dna.unique_enzymes] = dna.b_type
	species = all_species[new_dna.species]

/obj/item/organ/proc/die()
	if(status & ORGAN_DEAD)
		return FALSE // Already dead
	damage = max_damage
	status |= ORGAN_DEAD
	set_next_think(0)
	death_time = world.time
	if(owner && vital)
		owner.death()
	return TRUE

/obj/item/organ/proc/cook_organ()
	die()

/obj/item/organ/proc/is_preserved()
	if(istype(loc,/obj/item/organ))
		var/obj/item/organ/O = loc
		return O.is_preserved()

	return FALSE

/obj/item/organ/examine(mob/user, infix)
	. = ..()

	. += show_decay_status(user)

	if(get_dist(src, user) > 1)
		return

/obj/item/organ/proc/show_decay_status(mob/user)
	if(status & ORGAN_DEAD)
		return SPAN_NOTICE("\The [src] looks severely damaged.")

/obj/item/organ/proc/handle_rejection()
	if(!dna)
		return FALSE

	return TRUE

/obj/item/organ/proc/receive_chem(chemical as obj)
	return 0

/obj/item/organ/proc/remove_rejuv()
	qdel(src)

/obj/item/organ/proc/rejuvenate(ignore_prosthetic_prefs = FALSE)
	damage = 0
	status = 0

/obj/item/organ/proc/take_general_damage(amount, silent = FALSE)
	CRASH("Not Implemented")

/obj/item/organ/proc/heal_damage(amount)
	damage = between(0, damage - round(amount, 0.1), max_damage)

/**
 *  Remove an organ
 *
 *  drop_organ - if true, organ will be dropped at the loc of its former owner
 */
/obj/item/organ/proc/removed(mob/living/user, drop_organ = TRUE)
	if(!istype(owner))
		return

	if(drop_organ)
		dropInto(owner.loc)

	playsound(src, SFX_FIGHTING_CRUNCH, rand(65, 80), FALSE)

	// Start processing the organ on his own
	set_next_think(world.time)
	rejecting = null

	if(owner && vital)
		if(user)
			admin_attack_log(user, owner, "Removed a vital organ ([src]).", "Had a vital organ ([src]) removed.", "removed a vital organ ([src]) from")
		owner.death()

	owner = null

/obj/item/organ/proc/replaced(mob/living/carbon/human/target, obj/item/organ/external/affected)
	if(QDELETED(target))
		qdel_self()
		return FALSE
	owner = target
	forceMove(owner) //just in case

	return TRUE

/obj/item/organ/attack(mob/target, mob/user)
	if(status & ORGAN_ROBOTIC || !istype(target) || !istype(user) || (user != target && user.a_intent == I_HELP))
		return ..()

	if(alert("Do you really want to use this organ as food? It will be useless for anything else afterwards.",,"Ew, no.","Bon appetit!") == "Ew, no.")
		to_chat(user, SPAN_NOTICE("You successfully repress your cannibalistic tendencies."))
		return
	cook_organ()

	if(QDELETED(src))
		return

	target.attackby(return_item(), user)

/obj/item/organ/proc/can_feel_pain()
	return (!no_pain && owner && !owner.no_pain && (!species || !(species.species_flags & SPECIES_FLAG_NO_PAIN)))

/obj/item/organ/proc/is_usable()
	return (owner && !(status & (ORGAN_CUT_AWAY | ORGAN_MUTATED | ORGAN_DEAD)))

/obj/item/organ/proc/can_recover()
	return (!(status & ORGAN_DEAD) || death_time >= world.time - ORGAN_RECOVERY_THRESHOLD)

/obj/item/organ/proc/get_scan_results()
	. = list()

	if(status & ORGAN_CUT_AWAY)
		. += "Severed"
	if(status & ORGAN_MUTATED)
		. += "Genetic Deformation"
	if(status & ORGAN_DEAD)
		if(can_recover())
			. += "Critical"
		else
			. += "Destroyed"

	if(rejecting)
		. += "Transplant Rejection"

//used by stethoscope
/obj/item/organ/proc/listen()
	return

/obj/item/organ/proc/get_contents()
	. = list()

	LAZYDISTINCTADD(., organ_modules) // Should be covered by the above, but let's make sure.
	LAZYDISTINCTADD(., contents)

/obj/item/organ/proc/apply_snowflake(flags)
	if(flags & ORGAN_SNOWFLAKE_NO_PAIN)
		no_pain = TRUE
