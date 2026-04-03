// Landmarks activating upon successful roundstart
/obj/effect/landmark/roundstart
	delete_after = FALSE

/obj/effect/landmark/roundstart/Initialize()
	. = ..()
	register_global_signal(SIGNAL_ROUNDSTART, nameof(.proc/activate))

/obj/effect/landmark/proc/activate()
	qdel_self()
