/proc/get_odor_intensity_word(intensity)
	switch(intensity)
		if(0 to 0.15)
			return "faintly"
		if(0.15 to 0.35)
			return "slightly"
		if(0.35 to 0.65)
			return null
		if(0.65 to 0.85)
			return "strongly"
		else
			return "overwhelmingly"

/proc/get_color_intensity_word(intensity)
	switch(intensity)
		if(0 to 0.15)
			return "barely"
		if(0.15 to 0.35)
			return "slightly"
		if(0.35 to 0.65)
			return null
		if(0.65 to 0.85)
			return "richly"
		else
			return "deeply"

/proc/get_particle_size_word(diameter)
	switch(diameter)
		if(0 to 0.00001)
			return "fine powder"
		if(0.00001 to 0.0001)
			return "powder"
		if(0.0001 to 0.001)
			return "grains"
		if(0.001 to 0.005)
			return "granules"
		if(0.005 to 0.02)
			return "pebbles"
		else
			return "chunks"
