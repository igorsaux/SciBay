/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	dead_icon = "heart-off"
	w_class = ITEM_SIZE_SMALL
	organ_tag = BP_HEART
	parent_organ = BP_CHEST
	var/pulse = PULSE_NORM
	var/heartbeat = 0
	var/beat_sound = 'sound/effects/singlebeat.ogg'
	var/tmp/next_blood_squirt = 0
	relative_size = 15
	max_damage = 50
	min_bruised_damage = 15
	min_broken_damage = 35
	var/open

/obj/item/organ/internal/heart/attack_self(mob/user)
	. = ..()

/obj/item/organ/internal/heart/die()
	if(dead_icon)
		icon_state = dead_icon
	..()

/obj/item/organ/internal/heart/proc/handle_heartbeat()
	if(pulse >= PULSE_2FAST || owner.shock_stage >= 10 || is_below_sound_pressure(get_turf(owner)))
		//PULSE_THREADY - maximum value for pulse, currently it 5.
		//High pulse value corresponds to a fast rate of heartbeat.
		//Divided by 2, otherwise it is too slow.
		var/rate = (PULSE_THREADY - pulse)/2

		if(heartbeat >= rate)
			heartbeat = 0
			sound_to(owner, sound(beat_sound,0,0,0,50))
		else
			heartbeat++

/obj/item/organ/internal/heart/proc/is_working()
	if(!is_usable())
		return FALSE

	return pulse > PULSE_NONE || (owner.status_flags & FAKEDEATH)

/obj/item/organ/internal/heart/listen()
	if(!pulse || (owner.status_flags & FAKEDEATH))
		return "no pulse"

	var/pulsesound = "normal"
	if(is_bruised())
		pulsesound = "irregular"

	switch(pulse)
		if(PULSE_SLOW)
			pulsesound = "slow"
		if(PULSE_FAST)
			pulsesound = "fast"
		if(PULSE_2FAST)
			pulsesound = "very fast"
		if(PULSE_THREADY)
			pulsesound = "extremely fast and faint"

	. = "[pulsesound] pulse"
