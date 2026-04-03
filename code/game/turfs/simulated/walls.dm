/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/wall_masks.dmi'
	icon_state = "generic"
	opacity = 1
	density = 1
	blocks_air = 1
	plane = DEFAULT_PLANE // TURF_PLANE is for floors, but here we need structure-like rendering.
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall
	hitby_sound = 'sound/effects/metalhit2.ogg'
	explosion_block = 1

	rad_resist_type = /datum/rad_resist/wall

	var/damage = 0
	var/damage_overlay = 0
	var/global/damage_overlays[16]
	var/active
	var/can_open = 0
	var/material/material
	var/material/reinf_material
	var/last_state
	var/construction_stage
	var/ricochet_id = 0
	var/hitsound = 'sound/effects/fighting/Genhit.ogg'
	var/wall_connections = 0 // Sum of connected dirs
	var/floor_type = /turf/simulated/floor/plating //turf it leaves after destruction
	var/masks_icon = 'icons/turf/wall_masks.dmi'
	var/static/list/mask_overlay_states = list()

	///The current number of bulletholes in this turf
	var/current_bulletholes = 0
	///A reference to the current bullethole overlay image, this is added and deleted as needed
	var/image/bullethole_overlay
	/**
	 * The variation set we're using
	 * There are 10 sets and it gets picked randomly the first time a wall is shot
	 * It corresponds to the first number in the icon_state (bhole_[**bullethole_variation**]_[current_bulletholes])
	 * Gets reset to 0 if the wall reaches maximum health, so a new variation is picked when the wall gets shot again
	 */
	var/bullethole_variation = 0

/datum/rad_resist/wall
	alpha_particle_resist = 100 MEGA ELECTRONVOLT
	beta_particle_resist = 20.2 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/turf/simulated/wall/Initialize(mapload, materialtype, rmaterialtype)
	. = ..(mapload)
	if(GLOB.using_map.legacy_mode)
		masks_icon = 'icons/turf/wall_masks_legacy.dmi'
	icon_state = "blank"
	if(!materialtype)
		materialtype = DEFAULT_WALL_MATERIAL
	material = get_material_by_name(materialtype)
	if(!isnull(rmaterialtype))
		reinf_material = get_material_by_name(rmaterialtype)
	update_material()
	hitsound = material.hitsound

/turf/simulated/wall/Destroy()
	QDEL_NULL(bullethole_overlay)
	return ..()

// Walls always hide the stuff below them.
/turf/simulated/wall/levelupdate()
	for(var/obj/O in src)
		O.hide(O.hides_inside_walls())

/turf/simulated/wall/protects_atom(atom/A)
	var/obj/O = A
	return (istype(O) && O.hides_under_flooring()) || ..()

/turf/simulated/wall/proc/get_material()
	return material

/turf/simulated/wall/hitby(atom/movable/AM, datum/thrownthing/TT, nomsg)
	..()
	play_hitby_sound(AM)
	if(!isobj(AM))
		return

	var/obj/O = AM
	var/tforce = O.throwforce * (TT.speed / THROWFORCE_SPEED_DIVISOR)
	if(tforce < 17.5)
		if(!nomsg)
			visible_message("[AM] bounces off \the [src].")
	else
		if(!nomsg)
			visible_message(SPAN("warning", "[src] was hit by [AM]."))
		take_damage(tforce)

/turf/simulated/wall/proc/clear_plants()
	for(var/obj/effect/overlay/wallrot/WR in src)
		qdel(WR)

/turf/simulated/wall/ChangeTurf(turf/N, tell_universe = TRUE, force_lighting_update = FALSE)
	clear_plants()
	return ..()

//Appearance
/turf/simulated/wall/examine(mob/user, infix)
	. = ..()
	if(!damage)
		. += SPAN_NOTICE("It looks fully intact.")
	else
		var/dam = damage / material.integrity
		if(dam <= 0.3)
			. += SPAN_WARNING("It looks slightly damaged.")
		else if(dam <= 0.6)
			. += SPAN_WARNING("It looks moderately damaged.")
		else
			. += SPAN_WARNING("It looks heavily damaged.")

	if(locate(/obj/effect/overlay/wallrot) in src)
		. += SPAN_WARNING("There is fungus growing on [src].")

//Damage

/turf/simulated/wall/melt()

	if(!can_melt())
		return

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	if(!F)
		return
	F.burn_tile()
	F.icon_state = "wall_thermite"
	visible_message("<span class='danger'>\The [src] spontaneously combusts!.</span>") //!!OH SHIT!!
	return

/turf/simulated/wall/proc/take_damage(dam)
	if(dam)
		damage = max(0, damage + dam)
		update_damage()
	return

/turf/simulated/wall/proc/update_damage()
	var/cap = material.integrity
	if(reinf_material)
		cap += reinf_material.integrity

	if(locate(/obj/effect/overlay/wallrot) in src)
		cap = cap / 10

	if(damage >= cap)
		dismantle_wall()
	else
		update_icon()

	return

/turf/simulated/wall/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	burn(exposed_temperature)

/turf/simulated/wall/adjacent_fire_act(turf/simulated/floor/adj_turf, datum/gas_mixture/adj_air, adj_temp, adj_volume)
	burn(adj_temp)
	if(adj_temp > material.melting_point)
		take_damage(log(RAND_F(0.9, 1.1) * (adj_temp - material.melting_point)))

	return ..()

/turf/simulated/wall/proc/dismantle_wall(devastated, explode, no_product)

	playsound(src, 'sound/items/Deconstruct.ogg', 100, 1)
	if(!no_product)
		if(reinf_material)
			reinf_material.place_dismantled_girder(src, reinf_material)
		else
			material.place_dismantled_girder(src)
		material.place_dismantled_product(src,devastated)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O,/obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.forceMove(src)

	clear_plants()
	material = get_material_by_name("placeholder")
	reinf_material = null
	update_connections(1)

	ChangeTurf(floor_type)

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1.0)
			src.ChangeTurf(get_base_turf_by_area(src))
			return
		if(2.0)
			if(prob(75))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1,1)
		if(3.0)
			take_damage(rand(0, 250))
	return

// Wall-rot effect, a nasty fungus that destroys walls.
/turf/simulated/wall/proc/rot()
	if(locate(/obj/effect/overlay/wallrot) in src)
		return
	var/number_rots = rand(2,3)
	for(var/i=0, i<number_rots, i++)
		new /obj/effect/overlay/wallrot(src)

/turf/simulated/wall/proc/can_melt()
	if(material.material_flags & MATERIAL_UNMELTABLE)
		return 0
	return 1

/turf/simulated/wall/proc/thermitemelt(mob/user as mob)
	if(!can_melt())
		return
	var/obj/effect/overlay/O = new /obj/effect/overlay( src )
	O.SetName("Thermite")
	O.desc = "Looks hot."
	O.icon = 'icons/effects/fire.dmi'
	O.icon_state = "2"
	O.anchored = 1
	O.set_density(1)
	O.plane = LIGHTING_PLANE
	O.layer = FIRE_LAYER

	src.ChangeTurf(/turf/simulated/floor/plating)

	var/turf/simulated/floor/F = src
	F.burn_tile()
	F.icon_state = "wall_thermite"
	to_chat(user, "<span class='warning'>The thermite starts melting through the wall.</span>")

	spawn(100)
		if(O)
			qdel(O)
//	F.sd_LumReset()		//TODO: ~Carn
	return

/turf/simulated/wall/proc/CheckPenetration(base_chance, damage)
	return round(damage/material.integrity*180)

/turf/simulated/wall/proc/burn(temperature)
	if(material.combustion_effect(src, temperature, 0.7))
		spawn(2)
			new /obj/structure/girder(src)
			src.ChangeTurf(/turf/simulated/floor)
			for(var/turf/simulated/wall/W in range(3,src))
				W.burn((temperature/4))
			for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
				D.ignite(temperature/4)
