////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/hypospray //obsolete, use hypospray/vial for the actual hypospray item
	name = "hypospray"
	desc = "The DeForest Medical Corporation, a subsidiary of Zeng-Hu Pharmaceuticals, hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "hypo"
	origin_tech = list(TECH_MATERIAL = 4, TECH_BIO = 5)
	amount_per_transfer_from_this = 5
	unacidable = 1
	volume = 0.030 LITERS
	possible_transfer_amounts = null
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	slot_flags = SLOT_BELT

	drop_sound = SFX_DROP_GUN
	pickup_sound = SFX_PICKUP_GUN

/obj/item/reagent_containers/hypospray/attack(mob/living/M as mob, mob/user as mob)
	to_chat(user, "<span class='warning'>[src] is empty.</span>")

/obj/item/reagent_containers/hypospray/vial
	name = "hypospray"
	desc = "The DeForest Medical Corporation, a subsidiary of Zeng-Hu Pharmaceuticals, hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients. Uses a replaceable 50 ml vial."
	var/obj/item/reagent_containers/vessel/beaker/vial/loaded_vial
	volume = 0

/obj/item/reagent_containers/hypospray/vial/Initialize()
	. = ..()
	loaded_vial = new /obj/item/reagent_containers/vessel/beaker/vial(src)
	volume = loaded_vial.volume


/obj/item/reagent_containers/hypospray/autoinjector
	name = "autoinjector"
	desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	icon_state = "injector_blue"
	amount_per_transfer_from_this = 15
	volume = 0.015 LITERS
	origin_tech = list(TECH_MATERIAL = 2, TECH_BIO = 2)
	atom_flags = null
	var/content_desc = "Inaprovaline 15ml. Use to stabilize an injured person."

/obj/item/reagent_containers/hypospray/autoinjector/Initialize()
	. = ..()
	update_icon()
	if(content_desc)
		desc += " The label reads, \"[content_desc]\"."
	return

/obj/item/reagent_containers/hypospray/autoinjector/attack(mob/M as mob, mob/user as mob)
	..()
	update_icon()
	return

/obj/item/reagent_containers/hypospray/autoinjector/on_update_icon()
	update_held_icon()

/obj/item/reagent_containers/hypospray/autoinjector/examine(mob/user, infix)
	. = ..()

	. += SPAN_NOTICE("It is spent.")

/obj/item/reagent_containers/hypospray/autoinjector/detox
	icon_state = "injector_green"
	content_desc = "Dylovene 15ml. Use in case of poisoning."

/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine
	icon_state = "injector_lightpurple"
	content_desc = "Tricordrazine 15ml. Use to speed up recovery from physical trauma."

/obj/item/reagent_containers/hypospray/autoinjector/pain
	icon_state = "injector_purple"
	content_desc = "Tramadol 15ml. Highly potent painkiller. Warning: Do Not Mix With Alcohol!"

/obj/item/reagent_containers/hypospray/autoinjector/combatpain
	icon_state = "injector_black"
	content_desc = "Metazine 5ml. Used for immediate and temporary pain relief."
	amount_per_transfer_from_this = 5
	volume = 5

/obj/item/reagent_containers/hypospray/autoinjector/mindbreaker
	icon_state = "injector_black"
	content_desc = ""
	amount_per_transfer_from_this = 5
	volume = 5

/obj/item/reagent_containers/hypospray/autoinjector/antirad
	icon_state = "injector_orange"
	content_desc = "Hyronalin 15ml. Use in case of radiation poisoning."

/obj/item/reagent_containers/hypospray/autoinjector/antirad/mine
	name = "Radfi-X"
	desc = "A rapid way to administer a mix of radiation-purging drugs by untrained personnel. Severe radiation poisoning may require multiple doses."
	content_desc = "#1 brand among uranium miners across the galaxy!"
	icon_state = "injector_mine"

/obj/item/reagent_containers/hypospray/autoinjector/dexalinp
	icon_state = "injector_darkblue"
	content_desc = "Dexalin plus 15ml. Used for hypoxia. Increases oxygenation to almost 85%!"

/obj/item/reagent_containers/hypospray/autoinjector/bicaridine
	icon_state = "injector_red"
	content_desc = "Bicaridine 15ml. Used to treat serious physical wounds."

/obj/item/reagent_containers/hypospray/autoinjector/dermaline
	icon_state = "injector_yellow"
	content_desc = "Dermaline 15ml. Used to treat burn wounds."

/obj/item/reagent_containers/hypospray/autoinjector/adrenaline
	icon_state = "injector_pink"
	content_desc = "Adrenaline 15ml. Used to treat cardiac arrest."
