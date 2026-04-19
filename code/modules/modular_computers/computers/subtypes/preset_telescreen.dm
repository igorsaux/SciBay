/obj/item/modular_computer/telescreen/preset/install_default_hardware()
	..()
	processor_unit = new /obj/item/computer_hardware/processor_unit(src)
	tesla_link = new /obj/item/computer_hardware/tesla_link(src)
	hard_drive = new /obj/item/computer_hardware/hard_drive(src)
	network_card = new /obj/item/computer_hardware/network_card(src)

/obj/item/modular_computer/telescreen/preset/generic/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/chatclient())
	hard_drive.store_file(new /datum/computer_file/program/email_client())
	set_autorun("cammon")

// Civilian
/obj/item/modular_computer/telescreen/preset/civilian/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/chatclient())
	hard_drive.store_file(new /datum/computer_file/program/nttransfer())
	hard_drive.store_file(new /datum/computer_file/program/email_client())
	hard_drive.store_file(new /datum/computer_file/program/records())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())

// Medical
/obj/item/modular_computer/telescreen/preset/medical/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/suit_sensors())
	hard_drive.store_file(new /datum/computer_file/program/records())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())
	set_autorun("crewrecords")
