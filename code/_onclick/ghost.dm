/mob/observer/ghost/DblClickOn(atom/A, params)
	if(can_reenter_corpse && mind && mind.current)
		if(A == mind.current || (mind.current in A)) // double click your corpse or whatever holds it
			reenter_corpse()						// (cloning scanner, body bag, closet, mech, etc)
			return

	// Things you might plausibly want to follow
	if(ismovable(A))
		ManualFollow(A)

	// Otherwise jump
	else if(A.loc)
		forceMove(get_turf(A))

/mob/observer/ghost/ClickOn(atom/A, params)
	if(!canClick())
		return

	setClickCooldown(DEFAULT_QUICK_COOLDOWN)

	// You are responsible for checking config.ghost.ghost_interaction when you override this function
	// Not all of them require checking, see below
	var/list/modifiers = params2list(params)
	if(modifiers["alt"])
		var/target_turf = get_turf(A)
		if(target_turf)
			AltClickOn(target_turf)

	if(modifiers["shift"])
		if(!inquisitiveness)
			examinate(A)

	A.attack_ghost(src)

// Oh by the way this didn't work with old click code which is why clicking shit didn't spam you
/atom/proc/attack_ghost(mob/observer/ghost/user)
	if(!istype(user))
		return
	if(user.client)
		if(user.gas_scan)
			print_atmos_analysis(user, atmosanalyzer_scan(src))
		if(user.inquisitiveness)
			user.examinate(src)
	return


// -------------------------------------------
// This was supposed to be used by adminghosts
// I think it is a *terrible* idea
// but I'm leaving it here anyway
// commented out, of course.
/*
/atom/proc/attack_admin(mob/user)
	if(!user || !user.client || !user.client.holder)
		return
	attack_hand(user)

*/
