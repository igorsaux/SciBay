/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////
/obj/effect/effect/smoke/chem
	icon = 'icons/effects/chemsmoke.dmi'
	layer = ABOVE_PROJECTILE_LAYER
	time_to_live = 300
	pass_flags = PASS_FLAG_TABLE | PASS_FLAG_GRILLE | PASS_FLAG_GLASS //PASS_FLAG_GLASS is fine here, it's just so the visual effect can "flow" around glass
	var/splash_amount = 10 //atoms moving through a smoke cloud get splashed with up to 10 units of reagent
	var/turf/destination

/obj/effect/effect/smoke/chem/New(newloc, smoke_duration, turf/dest_turf = null, icon/cached_icon = null)
	time_to_live = smoke_duration

	..()

	if(cached_icon)
		icon = cached_icon

	set_dir(pick(GLOB.cardinal))

	//float over to our destination, if we have one
	destination = dest_turf
	if(destination)
		walk_to(src, destination)

/obj/effect/effect/smoke/chem/Move(newloc, direct)
	. = ..()
	if(!.)
		return

/////////////////////////////////////////////
// Chem Smoke Effect System
/////////////////////////////////////////////
/datum/effect/effect/system/smoke_spread/chem
	smoke_type = /obj/effect/effect/smoke/chem
	var/obj/chemholder
	var/range
	var/list/targetTurfs
	var/list/wallList
	var/density
	var/show_log = 1

//Sets up the chem smoke effect
// Calculates the max range smoke can travel, then gets all turfs in that view range.
// Culls the selected turfs to a (roughly) circle shape, then calls smokeFlow() to make
// sure the smoke can actually path to the turfs. This culls any turfs it can't reach.
/datum/effect/effect/system/smoke_spread/chem/set_up(n = 10, c = 0, loca, direct)
	range = n * 0.3
	cardinals = c

	if(istype(loca, /turf/))
		location = loca
	else
		location = get_turf(loca)
	if(!location)
		return

	targetTurfs = new()

	//build affected area list
	for(var/turf/T in view(range, location))
		//cull turfs to circle
		if(sqrt((T.x - location.x)**2 + (T.y - location.y)**2) <= range)
			targetTurfs += T

	wallList = new()

	smokeFlow() //pathing check

	//set the density of the cloud - for diluting reagents
	density = max(1, targetTurfs.len / 4) //clamp the cloud density minimum to 1 so it cant multiply the reagents

//Runs the chem smoke effect
// Spawns damage over time loop for each reagent held in the cloud.
// Applies reagents to walls that affect walls (only thermite and plant-b-gone at the moment).
// Also calculates target locations to spawn the visual smoke effect on, so the whole area
// is covered fairly evenly.
/datum/effect/effect/system/smoke_spread/chem/start()
	if(!location)
		return

	//Calculate smoke duration
	var/smoke_duration = 150

	var/pressure = 0
	var/datum/gas_mixture/environment = location.return_air()
	if(environment) pressure = environment.return_pressure()
	smoke_duration = between(5, smoke_duration*pressure/(ONE_ATMOSPHERE/3), smoke_duration)

	var/const/arcLength = 2.3559 //distance between each smoke cloud

	for(var/i = 0, i < range, i++) //calculate positions for smoke coverage - then spawn smoke
		var/radius = i * 1.5
		if(!radius)
			continue

		var/offset = 0
		var/points = round((radius * 2 * M_PI) / arcLength)
		var/angle = round(ToDegrees(arcLength / radius), 1)

		if(!IsInteger(radius))
			offset = 45		//degrees

		for(var/j = 0, j < points, j++)
			var/a = (angle * j) + offset
			var/x = round(radius * cos(a) + location.x, 1)
			var/y = round(radius * sin(a) + location.y, 1)
			var/turf/T = locate(x,y,location.z)
			if(!T)
				continue

/datum/effect/effect/system/smoke_spread/chem/proc/smokeFlow() // Smoke pathfinder. Uses a flood fill method based on zones to quickly check what turfs the smoke (airflow) can actually reach.

	var/list/pending = new()
	var/list/complete = new()

	pending += location

	var/airblock
	while(pending.len)
		for(var/turf/current in pending)
			for(var/D in GLOB.cardinal)
				var/turf/target = get_step(current, D)
				if(wallList)
					if(istype(target, /turf/simulated/wall))
						if(!(target in wallList))
							wallList += target
						continue

				if(target in pending)
					continue
				if(target in complete)
					continue
				if(!(target in targetTurfs))
					continue

				ATMOS_CANPASS_TURF(airblock, current, target)
				if(airblock)
					continue

				ATMOS_CANPASS_TURF(airblock, target, current)
				if(airblock)
					continue

				pending += target

			pending -= current
			complete += current

	targetTurfs = complete

	return
