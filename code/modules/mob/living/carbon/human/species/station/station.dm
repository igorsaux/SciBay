/datum/species/human
	name = SPECIES_HUMAN
	name_plural = "Humans"
	hair_key = SPECIES_HUMAN
	facial_hair_key = SPECIES_HUMAN
	primitive_form = "Monkey"
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/punch, /datum/unarmed_attack/bite)
	blurb = "A well known species."
	num_alternate_languages = 2
	secondary_langs = list(LANGUAGE_GALCOM)
	name_language = null // Use the first-name last-name generator rather than a language scrambler
	min_age = 18
	max_age = 100
	gluttonous = GLUT_TINY
	remains_type = /obj/item/remains/human

	body_builds = list(
		new /datum/body_build,
		new /datum/body_build/slim,
		new /datum/body_build/slim/alt,
		new /datum/body_build/slim/flat,
		new /datum/body_build/slim/male,
		new /datum/body_build/fat
	)

	spawn_flags = SPECIES_CAN_JOIN
	species_appearance_flags = HAS_HAIR_COLOR | HAS_SKIN_TONE_NORMAL | HAS_LIPS | HAS_UNDERWEAR | HAS_EYE_COLOR

	sexybits_location = BP_GROIN

/datum/species/human/handle_npc(mob/living/carbon/human/H)
	if(H.stat != CONSCIOUS)
		return

	if(H.get_shock() && H.shock_stage < 40 && prob(3))
		H.emote(pick("moan","groan"))

	if(H.shock_stage > 10 && prob(3))
		H.emote(pick("cry","whimper"))

	if(H.shock_stage >= 40 && prob(3))
		H.emote("scream")

	if(!H.restrained() && H.lying && H.shock_stage >= 60 && prob(3))
		H.visible_emote("thrashes in agony.")

	if(!H.restrained() && H.shock_stage < 40 && prob(3))
		var/maxdam = 0
		var/obj/item/organ/external/damaged_organ = null
		for(var/obj/item/organ/external/E in H.external_organs)
			if(!E.can_feel_pain()) continue
			var/dam = E.get_damage()
			// make the choice of the organ depend on damage,
			// but also sometimes use one of the less damaged ones
			if(dam > maxdam && (maxdam == 0 || prob(50)) )
				damaged_organ = E
				maxdam = dam
		var/datum/gender/T = gender_datums[H.get_gender()]
		if(damaged_organ)
			if(damaged_organ.status & ORGAN_BLEEDING)
				H.visible_emote("clutches [T.his] [damaged_organ.name], trying to stop the blood.")
			else if(damaged_organ.status & ORGAN_BROKEN)
				H.visible_emote("holds [T.his] [damaged_organ.name] carefully.")
			else if(damaged_organ.burn_dam > damaged_organ.brute_dam && damaged_organ.organ_tag != BP_HEAD)
				H.visible_emote("blows on [T.his] [damaged_organ.name] carefully.")
			else
				H.visible_emote("rubs [T.his] [damaged_organ.name] carefully.")

		for(var/obj/item/organ/I in H.internal_organs)
			if((I.status & ORGAN_DEAD)) continue
			if(I.damage > 2) if(prob(2))
				var/obj/item/organ/external/parent = H.get_organ(I.parent_organ)
				H.visible_emote("clutches [T.his] [parent.name]!")

/datum/species/human/get_ssd(mob/living/carbon/human/H)
	if(H.stat == CONSCIOUS)
		return "staring blankly, not reacting to your presence"
	return ..()
