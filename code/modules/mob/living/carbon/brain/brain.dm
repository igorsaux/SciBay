//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/brain
	var/obj/item/container = null
	var/timeofhostdeath = 0
	var/emp_damage = 0//Handles a type of MMI damage
	var/alert = null
	use_me = 0 //Can't use the me verb, it's a freaking immobile brain
	icon = 'icons/mob/human_races/organs/human.dmi'
	icon_state = "brain1"
	species_language = LANGUAGE_GALCOM // galcom is default for sapient life in game.

/mob/living/carbon/brain/Destroy()
	if(key)				//If there is a mob connected to this thing. Have to check key twice to avoid false death reporting.
		if(stat!=DEAD)	//If not dead.
			death(1)	//Brains can die again. AND THEY SHOULD AHA HA HA HA HA HA
		ghostize()		//Ghostize checks for key so nothing else is necessary.
	. = ..()

/mob/living/carbon/brain/incapacitated(incapacitation_flags = INCAPACITATION_DEFAULT)
	return TRUE

/mob/living/carbon/brain/check_has_mouth()
	return 0

/mob/living/carbon/brain/Move(new_loc) //It moves the brain-mob along with the container in which it is stored.

	if(!istype(src.container))
		return FALSE
	
	var/old_turf = get_turf(loc)

	if(old_turf != new_loc)
		src.container.Move(new_loc)
		return TRUE
	
	return FALSE
