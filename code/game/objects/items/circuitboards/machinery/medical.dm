#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/cryo_cell
	name = T_BOARD("cryo chamber")
	icon_state = "id_mod_cyan"
	build_path = /obj/machinery/atmospherics/unary/cryo_cell
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 1, TECH_BIO = 3, TECH_DATA = 3)
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/manipulator = 3,
							)

/obj/item/circuitboard/body_scanner
	name = T_BOARD("body scanner")
	icon_state = "id_mod_cyan"
	build_path = /obj/machinery/bodyscanner
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 5, TECH_DATA = 5)
	req_components = list(
							/obj/item/stock_parts/scanning_module = 3,
							/obj/item/stock_parts/manipulator = 4,
							)

/obj/item/circuitboard/optable
	name = T_BOARD("operating table")
	icon_state = "id_mod_cyan"
	build_path = /obj/machinery/optable
	board_type = "machine"
	origin_tech = list(TECH_ENGINEERING = 3, TECH_BIO = 3)
	req_components = list(/obj/item/stock_parts/manipulator = 4)
