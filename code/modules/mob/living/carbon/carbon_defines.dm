/mob/living/carbon/
	gender = MALE
	var/datum/species/species //Contains icon generation and language information, set during New().

	var/life_tick = 0      // The amount of life ticks that have processed on this mob.
	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	//Surgery info
	var/analgesic = 0 // when this is set, the mob isn't affected by shock or pain
	//Active emote/pose
	var/pose = null
	var/losebreath = 0 //if we failed to breathe last tick

	var/coughedtime = null

	var/cpr_time = 1.0
	var/lastpuke = 0
	var/last_nutrition_speed_update
	var/nutrition = 400
	var/last_hydration_speed_update
	var/hydration = 750

	var/toxic_buildup = 0.0 // Absolute value of the toxic damage buildup.
	var/toxic_severity = 0 // Effective value of the toxic damage buildup, with 100 representing the lethal amount.

	var/obj/item/tank/internal = null//Human/Monkey


	//these two help govern taste. The first is the last time a taste message was shown to the plaer.
	//the second is the message in question.
	var/last_taste_time = 0
	var/last_taste_text = ""

	// organ-related variables, see organ.dm and human_organs.dm
	var/list/internal_organs = list()
	var/list/external_organs = list()
	var/alist/external_organs_by_name = alist() // map organ names to organs
	var/alist/internal_organs_by_name = alist() // so internal organs have less ickiness too

	var/list/stasis_sources = list()
	var/stasis_value
	var/does_not_breathe = FALSE
	var/seeDarkness = FALSE
	var/should_update_healths = TRUE
	can_use_hands = TRUE // use only for short-term restrictions (climbing in ventilation, being in stasis, etc.)
