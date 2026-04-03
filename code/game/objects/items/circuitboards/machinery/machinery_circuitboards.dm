#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/cell_charger
	name = T_BOARD("cell charger")
	icon_state = "id_mod_orange"
	build_path = /obj/machinery/cell_charger
	board_type = "machine"
	origin_tech = list(TECH_POWER = 2, TECH_ENGINEERING = 2)
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/sleeper
	name = T_BOARD("sleeper")
	icon_state = "id_mod_cyan"
	build_path = /obj/machinery/sleeper
	board_type = "machine"
	origin_tech = list(TECH_MAGNET = 2, TECH_BIO = 2, TECH_ENGINEERING = 2)
	req_components = list(
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/reagent_containers/vessel/beaker/large = 1)

/obj/item/circuitboard/sauna
	name = T_BOARD("sauna")
	icon_state = "id_mod_yellow"
	build_path = /obj/machinery/sauna
	board_type = "machine"
	origin_tech = list(TECH_POWER = 2, TECH_ENGINEERING = 2)
	req_components = list(
							/obj/item/reagent_containers/vessel/beaker/large = 1,
							/obj/item/stock_parts/capacitor = 1)
