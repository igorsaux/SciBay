#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/turbine_control
	name = T_BOARD("turbine control console")
	icon_state = "id_mod_orange"
	build_path = /obj/machinery/computer/turbine_computer

/obj/item/circuitboard/rdservercontrol
	name = T_BOARD("R&D server control console")
	icon_state = "id_mod_purple"
	build_path = /obj/machinery/computer/rdservercontrol

/obj/item/circuitboard/crew
	name = T_BOARD("crew monitoring console")
	icon_state = "id_mod_cyan"
	build_path = /obj/machinery/computer/crew
	origin_tech = list(TECH_DATA = 3, TECH_BIO = 2, TECH_MAGNET = 2)

/obj/item/circuitboard/operating
	name = T_BOARD("patient monitoring console")
	icon_state = "id_mod_cyan"
	build_path = /obj/machinery/computer/operating
	origin_tech = list(TECH_DATA = 2, TECH_BIO = 2)

/obj/item/circuitboard/operating/small
	name = T_BOARD("surgical console")
	build_path = /obj/machinery/computer/operating/small

/obj/item/circuitboard/area_atmos
	name = T_BOARD("area air control console")
	icon_state = "id_mod_orange"
	build_path = /obj/machinery/computer/area_atmos
	origin_tech = list(TECH_DATA = 2)
