#define BRAIN_DAMAGE_THRESHOLD 10

/obj/item/organ/internal/cerebrum/brain
	name = "\improper Brain"
	desc = "A piece of juicy meat found in a person's head."
	w_class = ITEM_SIZE_NORMAL

	max_damage = 100
	relative_size = 70
	traumatic_damage_multiplier = 2.0

	var/damage_threshold_value
	var/healed_threshold = 1

/obj/item/organ/internal/cerebrum/brain/Initialize()
	. = ..()

	if(species)
		max_damage = species.total_health

	min_bruised_damage = max_damage * 0.25
	min_broken_damage = max_damage * 0.75

	damage_threshold_value = round(max_damage / BRAIN_DAMAGE_THRESHOLD)

/obj/item/organ/internal/cerebrum/brain/update_desc()
	desc = initial(desc)
	if(brainmob?.is_ic_dead())
		desc += SPAN("deadsay", "\nThis one seems particularly lifeless. Perhaps it will regain some of its luster later...")
	else if(brainmob?.ssd_check())
		desc += SPAN("deadsay", "\nYou can feel the small spark of life still left in this one.")

/obj/item/organ/internal/cerebrum/brain/_setup_brainmob(mob/living/brain_self, mob/living/carbon/old_self)
	brain_self.dna = old_self.dna.Clone()
	brain_self.languages = old_self.languages
	for(var/datum/modifier/M in old_self.modifiers)
		if(!(M.flags & MODIFIER_GENETIC))
			continue
		brain_self.add_modifier(M.type)
	return ..()

/obj/item/organ/internal/cerebrum/brain/proc/replace_self_with(replace_path)
	var/mob/living/carbon/human/tmp_owner = owner
	qdel(src)
	if(tmp_owner)
		tmp_owner.internal_organs_by_name[organ_tag] = new replace_path(tmp_owner, tmp_owner)
		tmp_owner = null

/obj/item/organ/internal/cerebrum/brain/getToxLoss()
	return 0

/obj/item/organ/internal/cerebrum/brain/proc/get_current_damage_threshold()
	return round(damage / damage_threshold_value)

/obj/item/organ/internal/cerebrum/brain/proc/past_damage_threshold(threshold)
	return (get_current_damage_threshold() > threshold)

/obj/item/organ/internal/cerebrum/brain/proc/handle_disabilities()
	if(owner.stat)
		return

	if((owner.disabilities & EPILEPSY) && prob(1))
		to_chat(owner, SPAN("warning", "You have a seizure!"))
		owner.visible_message(SPAN("danger", "\The [owner] starts having a seizure!"))
		owner.Paralyse(10)
		owner.make_jittery(1000)
	else if((owner.disabilities & TOURETTES) && prob(10))
		owner.Stun(10)
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
		owner.make_jittery(100)
	else if((owner.disabilities & NERVOUS) && prob(10))
		owner.stuttering = max(10, owner.stuttering)

/obj/item/organ/internal/cerebrum/brain/proc/handle_damage_effects()
	if(owner.stat)
		return

	if(damage > 0.1 * max_damage && prob(1))
		owner.custom_pain(SPAN("warning", "Your head feels numb and painful."), 10)

	if(is_bruised() && prob(1) && owner.eye_blurry <= 0)
		to_chat(owner, SPAN("warning", "It becomes hard to see for some reason."))
		owner.eye_blurry = 10

	if(damage >= 0.5 * max_damage && prob(1) && (owner.get_active_hand() || owner.get_inactive_hand()))
		to_chat(owner, SPAN("danger", "Your hand won't respond properly, and you drop what you are holding!"))
		owner.drop_active_hand()
		owner.drop_inactive_hand()

	if(damage >= 0.6 * max_damage)
		owner.slurring = max(owner.slurring, 2)

	if(is_broken())
		if(!owner.lying)
			to_chat(owner, SPAN("danger", "You black out!"))
		owner.Paralyse(10)

/obj/item/organ/internal/cerebrum/brain/xeno
	name = "thinkpan"
	desc = "It looks kind of like an enormous wad of purple bubblegum."
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"

/obj/item/organ/internal/cerebrum/brain/metroid
	name = "metroid core"
	desc = "A complex, organic knot of jelly and crystalline particles."
	icon = 'icons/mob/metroids.dmi'
	icon_state = "green metroid extract"

/obj/item/organ/internal/cerebrum/brain/golem
	name = "adamantite brain"
	desc = "What else could be inside the adamantite creature's head?"
	icon = 'icons/obj/materials.dmi'
	icon_state = "adamantine"
