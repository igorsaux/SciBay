/mob/living/carbon/Life()
	if(!..())
		return

	UpdateStasis()

	if(!is_ic_dead() && !InStasis())
		//Breathing, if applicable
		handle_breathing()

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Random events (vomiting etc)
		handle_random_events()

		//stuff in the stomach
		handle_stomach()

		// eye, ear, brain damages
		handle_disabilities()

		//all special effects, stunned, weakened, jitteryness, hallucination, sleeping, etc
		handle_statuses()

		. = 1

		if(!client && !mind && species)
			species.handle_npc(src)
