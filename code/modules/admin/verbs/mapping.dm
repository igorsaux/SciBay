//- Are all the floors with or without air, as they should be? (regular or airless)
//- Does the area have an APC?
//- Does the area have an Air Alarm?
//- Does the area have a Request Console?
//- Does the area have lights?
//- Does the area have a light switch?
//- Does the area have enough intercoms?
//- Does the area have enough security cameras? (Use the 'Camera Range Display' verb under Debug)
//- Is the area connected to the scrubbers air loop?
//- Is the area connected to the vent air loop? (vent pumps)
//- Is everything wired properly?
//- Does the area have a fire alarm and firedoors?
//- Do all pod doors work properly?
//- Are accesses set properly on doors, pod buttons, etc.
//- Are all items placed properly? (not below vents, scrubbers, tables)
//- Does the disposal system work properly from all the disposal units in this room and all the units, the pipes of which pass through this room?
//- Check for any misplaced or stacked piece of pipe (air and disposal)
//- Check for any misplaced or stacked piece of wire
//- Identify how hard it is to break into the area and where the weak points are
//- Check if the area has too much empty space. If so, make it smaller and replace the rest with maintenance tunnels.

var/camera_range_display_status = 0
var/intercom_range_display_status = 0

/obj/effect/debugging/camera_range
	icon = 'icons/480x480.dmi'
	icon_state = "25percent"

	New()
		src.pixel_x = -224
		src.pixel_y = -224

/obj/effect/debugging/marker
	icon = 'icons/turf/areas.dmi'
	icon_state = "yellow"

/obj/effect/debugging/marker/Move()
	return 0

var/list/debug_verbs = list (
		,/client/proc/Cell
		,/client/proc/atmosscan
		,/client/proc/powerdebug
		,/client/proc/count_objects_on_z_level
		,/client/proc/count_objects_all
		,/client/proc/cmd_assume_direct_control
		,/client/proc/ticklag
		,/client/proc/cmd_admin_grantfullaccess
		,/client/proc/cmd_admin_areatest
		,/client/proc/cmd_admin_rejuvenate
		,/client/proc/Zone_Info
		,/client/proc/Test_ZAS_Connection
		,/client/proc/rebootAirMaster
		,/client/proc/hide_debug_verbs
		,/client/proc/testZAScolors
		,/client/proc/testZAScolors_remove
		,/client/proc/atmos_toggle_debug
	)


/client/proc/enable_debug_verbs()
	set category = "Debug"
	set name = "Debug verbs"

	if(!check_rights(R_DEBUG)) return

	verbs += debug_verbs

/client/proc/hide_debug_verbs()
	set category = "Debug"
	set name = "Hide Debug verbs"

	if(!check_rights(R_DEBUG)) return

	verbs -= debug_verbs

/client/var/list/testZAScolors_turfs = list()
/client/var/list/testZAScolors_zones = list()
/client/var/usedZAScolors = 0
/client/var/list/image/ZAScolors = list()

/client/proc/recurse_zone(zone/Z, recurse_level =1)
	testZAScolors_zones += Z
	if(recurse_level > 10)
		return

	for(var/turf/T in Z.contents)
		images += get_zas_image(T, "yellow")
		testZAScolors_turfs += T
	for(var/connection_edge/zone/edge in Z.edges)
		var/zone/connected = edge.get_connected_zone(Z)
		if(connected in testZAScolors_zones)
			continue
		recurse_zone(connected,recurse_level+1)


/client/proc/testZAScolors()
	set category = "ZAS"
	set name = "Check ZAS connections"

	if(!check_rights(R_DEBUG)) return
	testZAScolors_remove()

	var/turf/simulated/location = get_turf(usr)

	if(!istype(location, /turf/simulated))
		to_chat(src, "<Span class='warning'>This debug tool can only be used while on a simulated turf.</span>")
		return

	if(!usedZAScolors)
		to_chat(src, "ZAS Test Colors")
		to_chat(src, "Green = Zone you are standing in")
		to_chat(src, "Blue = Connected zone to the zone you are standing in")
		to_chat(src, "Yellow = A zone that is connected but not one adjacent to your connected zone")
		to_chat(src, "Red = Not connected")
		usedZAScolors = 1

	testZAScolors_zones += location.zone
	for(var/turf/T in location.zone.contents)
		images += get_zas_image(T, "green")
		testZAScolors_turfs += T
	for(var/connection_edge/zone/edge in location.zone.edges)
		var/zone/Z = edge.get_connected_zone(location.zone)
		testZAScolors_zones += Z
		for(var/turf/T in Z.contents)
			images += get_zas_image(T, "blue")
			testZAScolors_turfs += T
		for(var/connection_edge/zone/z_edge in Z.edges)
			var/zone/connected = z_edge.get_connected_zone(Z)
			if(connected in testZAScolors_zones)
				continue
			recurse_zone(connected,1)

	for(var/turf/T in range(25,location))
		if(!istype(T))
			continue
		if(T in testZAScolors_turfs)
			continue
		images += get_zas_image(T, "red")
		testZAScolors_turfs += T

/client/proc/testZAScolors_remove()
	set category = "ZAS"
	set name = "Remove ZAS connection colors"

	testZAScolors_turfs.Cut()
	testZAScolors_zones.Cut()

	for(var/image/i in images)
		if(i.icon == 'icons/misc/debug_group.dmi')
			images.Remove(i)

/client/proc/rebootAirMaster()
	set category = "ZAS"
	set name = "Reboot ZAS"

	if(alert("This will destroy and remake all zone geometry on the whole map.","Reboot ZAS","Reboot ZAS","Nevermind") == "Reboot ZAS")
		SSair.reboot()


/client/proc/count_objects_on_z_level()
	set category = "Mapping"
	set name = "Count Objects On Level"
	var/level = input("Which z-level?","Level?") as text
	if(!level) return
	var/num_level = text2num(level)
	if(!num_level) return
	if(!isnum(num_level)) return

	var/type_text = input("Which type path?","Path?") as text
	if(!type_text) return
	var/type_path = text2path(type_text)
	if(!type_path) return

	var/count = 1

	var/list/atom/atom_list = list()

	for(var/atom/A in world)
		if(istype(A,type_path))
			var/atom/B = A
			while(!(isturf(B.loc)))
				if(B && B.loc)
					B = B.loc
				else
					break
			if(B)
				if(B.z == num_level)
					count++
					atom_list += A
	/*
	var/atom/temp_atom
	for(var/i = 0; i <= (atom_list.len/10); i++)
		var/line = ""
		for(var/j = 1; j <= 10; j++)
			if(i*10+j <= atom_list.len)
				temp_atom = atom_list[i*10+j]
				line += " no.[i+10+j]@\[[temp_atom.x], [temp_atom.y], [temp_atom.z]\]; "
		log_debug(line) */

	log_debug("There are [count] objects of type [type_path] on z-level [num_level]")

/client/proc/count_objects_all()
	set category = "Mapping"
	set name = "Count Objects All"

	var/type_text = input("Which type path?","") as text
	if(!type_text) return
	var/type_path = text2path(type_text)
	if(!type_path) return

	var/count = 0

	for(var/atom/A in world)
		if(istype(A,type_path))
			count++
	/*
	var/atom/temp_atom
	for(var/i = 0; i <= (atom_list.len/10); i++)
		var/line = ""
		for(var/j = 1; j <= 10; j++)
			if(i*10+j <= atom_list.len)
				temp_atom = atom_list[i*10+j]
				line += " no.[i+10+j]@\[[temp_atom.x], [temp_atom.y], [temp_atom.z]\]; "
		log_debug(line) */

	log_debug("There are [count] objects of type [type_path] in the game world")

/proc/get_zas_image(turf/T, icon_state)
	return image_repository.atom_image(T, 'icons/misc/debug_group.dmi', icon_state, plane = DEFAULT_PLANE, layer = ABOVE_TILE_LAYER)
