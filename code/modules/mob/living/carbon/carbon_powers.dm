/**
 *  Attempt to devour victim
 *
 *  Returns TRUE on success, FALSE on failure
 */
/mob/living/carbon/proc/devour(atom/movable/victim)
	var/can_eat = can_devour(victim)
	if(!can_eat)
		return FALSE
	var/eat_speed = 100
	if(can_eat == DEVOUR_FAST)
		eat_speed = 30
	visible_message("<span class='danger'>\The [src] is attempting to devour \the [victim]!</span>")
	var/mob/target = victim
	if(isobj(victim))
		target = src
	if(!do_mob(src,target,eat_speed))
		return FALSE
	visible_message("<span class='danger'>\The [src] devours \the [victim]!</span>")
	if(ismob(victim))
		admin_attack_log(src, victim, "Devoured.", "Was devoured by.", "devoured")
	else
		drop(victim)
	victim.forceMove(src)

	return TRUE
