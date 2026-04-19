/obj/item/modular_computer/console/preset
	var/default_processor_unit = /obj/item/computer_hardware/processor_unit
	var/default_hard_drive = /obj/item/computer_hardware/hard_drive/super

/obj/item/modular_computer/console/preset/install_default_hardware()
	..()
	processor_unit = new default_processor_unit(src)
	tesla_link = new /obj/item/computer_hardware/tesla_link(src)
	hard_drive = new default_hard_drive(src)
	network_card = new /obj/item/computer_hardware/network_card/wired(src)

// Engineering
/obj/item/modular_computer/console/preset/engineering/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/engineering/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())

// Medical
/obj/item/modular_computer/console/preset/medical/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/medical/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/suit_sensors())
	hard_drive.store_file(new /datum/computer_file/program/records())
	hard_drive.store_file(new /datum/computer_file/program/records/medical())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())
	set_autorun("sensormonitor")

// Research
/obj/item/modular_computer/console/preset/research/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/research/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/ntnetmonitor())
	hard_drive.store_file(new /datum/computer_file/program/nttransfer())
	hard_drive.store_file(new /datum/computer_file/program/chatclient())
	hard_drive.store_file(new /datum/computer_file/program/email_client())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())

// Administrator
/obj/item/modular_computer/console/preset/sysadmin/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/sysadmin/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/ntnetmonitor())
	hard_drive.store_file(new /datum/computer_file/program/nttransfer())
	hard_drive.store_file(new /datum/computer_file/program/chatclient())
	hard_drive.store_file(new /datum/computer_file/program/email_client())
	hard_drive.store_file(new /datum/computer_file/program/email_administration())
	hard_drive.store_file(new /datum/computer_file/program/records())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())

// Command
/obj/item/modular_computer/console/preset/command/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)
	card_slot = new /obj/item/computer_hardware/card_slot(src)

/obj/item/modular_computer/console/preset/command/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/chatclient())
	hard_drive.store_file(new /datum/computer_file/program/card_mod())
	hard_drive.store_file(new /datum/computer_file/program/hire_tool())
	hard_drive.store_file(new /datum/computer_file/program/email_client())
	hard_drive.store_file(new /datum/computer_file/program/records())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())

// Security
/obj/item/modular_computer/console/preset/security/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/security/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/records())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())

// Civilian
/obj/item/modular_computer/console/preset/civilian/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/civilian/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/chatclient())
	hard_drive.store_file(new /datum/computer_file/program/nttransfer())
	hard_drive.store_file(new /datum/computer_file/program/email_client())
	hard_drive.store_file(new /datum/computer_file/program/records())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())

// Offices
/obj/item/modular_computer/console/preset/civilian/professional/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)

//Dock control
/obj/item/modular_computer/console/preset/dock/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/dock/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/nttransfer())
	hard_drive.store_file(new /datum/computer_file/program/email_client())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())

// ERT
/obj/item/modular_computer/console/preset/ert/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)
	card_slot = new /obj/item/computer_hardware/card_slot(src)

/obj/item/modular_computer/console/preset/ert/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/nttransfer())
	hard_drive.store_file(new /datum/computer_file/program/records())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())

// Syndicate
/obj/item/modular_computer/console/preset/syndicate/
	computer_emagged = TRUE

/obj/item/modular_computer/console/preset/syndicate/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)
	card_slot = new /obj/item/computer_hardware/card_slot(src)

// Merchant
/obj/item/modular_computer/console/preset/merchant/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/merchant/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())

// Library
/obj/item/modular_computer/console/preset/library/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/library/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/nttransfer())
	hard_drive.store_file(new /datum/computer_file/program/email_client())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())

// AI Supercomputer
/obj/item/modular_computer/console/preset/ai
	default_processor_unit = /obj/item/computer_hardware/processor_unit/photonic
	default_hard_drive = /obj/item/computer_hardware/hard_drive/cluster

/obj/item/modular_computer/console/preset/ai/install_default_hardware()
	..()
	nano_printer = new /obj/item/computer_hardware/nano_printer(src)

/obj/item/modular_computer/console/preset/ai/install_default_programs()
	..()
	hard_drive.store_file(new /datum/computer_file/program/chatclient())
	hard_drive.store_file(new /datum/computer_file/program/card_mod())
	hard_drive.store_file(new /datum/computer_file/program/hire_tool())
	hard_drive.store_file(new /datum/computer_file/program/email_client())
	hard_drive.store_file(new /datum/computer_file/program/records())
	hard_drive.store_file(new /datum/computer_file/program/wordprocessor())
	hard_drive.store_file(new /datum/computer_file/program/ntnetmonitor())
	hard_drive.store_file(new /datum/computer_file/program/nttransfer())
	hard_drive.store_file(new /datum/computer_file/program/suit_sensors())
	hard_drive.store_file(new /datum/computer_file/program/records())
	hard_drive.store_file(new /datum/computer_file/program/records/medical())
