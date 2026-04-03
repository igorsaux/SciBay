/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting flammable items."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter1"
	var/id = null
	var/on = 0
	anchored = 1
	var/_wifi_id
	var/datum/wifi/receiver/button/igniter/wifi_receiver

/obj/machinery/igniter/Initialize()
	. = ..()
	update_icon()
	if(_wifi_id)
		wifi_receiver = new(_wifi_id, src)

/obj/machinery/igniter/on_update_icon()
	..()
	icon_state = "igniter[on]"

/obj/machinery/igniter/Destroy()
	qdel(wifi_receiver)
	wifi_receiver = null
	return ..()

/obj/machinery/igniter/attack_hand(mob/user as mob)
	if(..())
		return
	ignite()

/obj/machinery/igniter/Process()
	var/turf/location = src.loc
	if (isturf(location))
		location.hotspot_expose(1000,500,1)
	return 1

/obj/machinery/igniter/proc/ignite()
	on = !on
	if(on)
		START_PROCESSING(SSmachines, src)
	else
		STOP_PROCESSING(SSmachines, src)
	update_icon()

// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "Mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	var/id = null
	var/disable = 0
	var/last_spark = 0
	var/base_state = "migniter"
	anchored = 1
	var/_wifi_id
	var/datum/wifi/receiver/button/sparker/wifi_receiver

/obj/machinery/sparker/Initialize()
	. = ..()
	if(_wifi_id)
		wifi_receiver = new(_wifi_id, src)

/obj/machinery/sparker/Destroy()
	qdel(wifi_receiver)
	wifi_receiver = null
	return ..()

/obj/machinery/sparker/on_update_icon()
	..()
	if(disable)
		icon_state = "migniter-d"
	else
		icon_state = "migniter"
//		src.sd_SetLuminosity(2)

/obj/machinery/sparker/attackby(obj/item/W as obj, mob/user as mob)
	if(isScrewdriver(W))
		add_fingerprint(user)
		disable = !disable
		if(disable)
			user.visible_message("<span class='warning'>[user] has disabled the [src]!</span>", "<span class='warning'>You disable the connection to the [src].</span>")
		else if(!disable)
			user.visible_message("<span class='warning'>[user] has reconnected the [src]!</span>", "<span class='warning'>You fix the connection to the [src].</span>")
		update_icon()
	else
		..()

/obj/machinery/sparker/proc/ignite()
	if (disable || (last_spark && world.time < last_spark + 50))
		return


	flick("migniter-spark", src)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, src)
	s.start()
	src.last_spark = world.time
	var/turf/location = src.loc
	if (isturf(location))
		location.hotspot_expose(1000,500,1)
	return 1

/obj/machinery/button/ignition
	name = "ignition switch"
	desc = "A remote control switch for a mounted igniter."

/obj/machinery/button/ignition/attack_hand(mob/user as mob)

	if(..())
		return

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/sparker/M in SSmachines.machinery)
		if (M.id == id)
			spawn( 0 )
				M.ignite()

	for(var/obj/machinery/igniter/M in SSmachines.machinery)
		if(M.id == id)
			M.ignite()

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return
