// Roundstart landmarks.
/obj/effect/landmark/start
	name = "start"
	icon_state = "landmark_assistant"
	should_be_added = TRUE

// Latejoin landmarks.
/obj/effect/landmark/joinlate
	name = "JoinLate"
	icon_state = "landmark_late"
	delete_after = TRUE

/obj/effect/landmark/joinlate/New()
	switch(name)
		if("JoinLate")
			GLOB.latejoin += loc
			return
		if("JoinLateGateway")
			GLOB.latejoin_gateway += loc
			return
		if("JoinLateCryo")
			GLOB.latejoin_cryo += loc
			return
		if("JoinLateCyborg")
			GLOB.latejoin_cyborg += loc
			return
	return ..()

/obj/effect/landmark/joinlate/observer
	name = "Observer"
	icon_state = "landmark_observer"
	delete_after = FALSE
	should_be_added = TRUE
