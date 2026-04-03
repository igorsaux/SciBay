//If we intercept it return true else return false
/atom/proc/RelayMouseDrag(atom/src_object, atom/over_object, src_location, over_location, src_control, over_control, params, mob/user)
	return FALSE

/mob/proc/OnMouseDrag(atom/src_object, atom/over_object, src_location, over_location, src_control, over_control, params)
	if(istype(loc, /atom))
		var/atom/A = loc
	
		if(A.RelayMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params, src))
			return TRUE

/mob/proc/OnMouseDown(atom/object, location, control, params)
	return FALSE

/mob/proc/OnMouseUp(atom/object, location, control, params)
	return FALSE
