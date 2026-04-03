/client/proc/debug_controller(controller as null|anything in list("Jobs","Sun","Radio","Evacuation","Configuration","pAI", "Cameras", "Transfer Controller", "Gas Data","Plants","Wireless","Observation","Alt Appearance Manager","Datacore","Military Branches"))
	set category = "Debug"
	set name = "Debug Controller"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder || !controller)
		return

	switch(controller)
		if("Jobs")
			debug_variables(job_master)
		if("Configuration")
			debug_variables(config)
		if("Gas Data")
			debug_variables(gas_data)
		if("Alt Appearance Manager")
			debug_variables(appearance_manager)
	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
	return
