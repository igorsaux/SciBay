////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/pill
	name = "pill"
	desc = "A pill."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	item_state = "pill"
	randpixel = 7
	possible_transfer_amounts = null
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	volume = 30
	var/mimic_color = FALSE

	drop_sound = SFX_DROP_FOOD
	pickup_sound = SFX_PICKUP_FOOD

/obj/item/reagent_containers/pill/Initialize()
	. = ..()
	if(!icon_state)
		icon_state = "pill[rand(1, 5)]" //preset pills only use colour changing or unique icons

	// TODO: CHEM
	// if(mimic_color)
	// 	color = reagents.get_color()

/obj/item/reagent_containers/pill/afterattack(obj/target, mob/user, proximity)
	if(!proximity) return

	// TODO: CHEM
	// if(target.is_open_container() && target.reagents)
	// 	if(!target.reagents.total_volume)
	// 		to_chat(user, "<span class='notice'>[target] is empty. Can't dissolve \the [src].</span>")
	// 		return
	// 	to_chat(user, "<span class='notice'>You dissolve \the [src] in [target].</span>")

	// 	admin_attacker_log(user, "spiked \a [target] with a pill. Reagents: [reagentlist()]")
	// 	reagents.trans_to(target, reagents.total_volume)
	// 	for(var/mob/O in viewers(2, user))
	// 		O.show_message("<span class='warning'>[user] puts something in \the [target].</span>", 1)
	// 	qdel(src)
	return

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//We lied - it's pills all the way down
/obj/item/reagent_containers/pill/tox
	name = "toxins pill"
	desc = "Highly toxic."
	icon_state = "pill4"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/cyanide
	name = "strange pill"
	desc = "It's marked 'KCN'. Smells vaguely of almonds."
	icon_state = "pill9"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/adminordrazine
	name = "Adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pillA"

/obj/item/reagent_containers/pill/stox
	name = "Soporific (15 ml)"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill3"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/kelotane
	name = "Kelotane (15 ml)"
	desc = "Used to treat burns."
	icon_state = "pill2"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/paracetamol
	name = "Paracetamol (15 ml)"
	desc = "A painkiller for the ages. Chewables!"
	icon_state = "pill3"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/tramadol
	name = "Tramadol (15 ml)"
	desc = "A simple painkiller."
	icon_state = "pill3"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/inaprovaline
	name = "Inaprovaline (30 ml)"
	desc = "Used to stabilize patients."
	icon_state = "pill1"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/dexalin
	name = "Dexalin (15ml)"
	desc = "Used to treat oxygen deprivation."
	icon_state = "pill1"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/dexalin_plus
	name = "Dexalin Plus (15 ml)"
	desc = "Used to treat extreme oxygen deprivation."
	icon_state = "pill2"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/dermaline
	name = "Dermaline (15 ml)"
	desc = "Used to treat burn wounds."
	icon_state = "pill2"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/dylovene
	name = "Dylovene (15 ml)"
	desc = "A broad-spectrum anti-toxin."
	icon_state = "pill1"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/bicaridine
	name = "Bicaridine (20 ml)"
	desc = "Used to treat physical injuries."
	icon_state = "pill2"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/happy
	name = "happy pill"
	desc = "Happy happy joy joy!"
	icon_state = "pill4"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/zoom
	name = "zoom pill"
	desc = "Zoooom!"
	icon_state = "pill4"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/spaceacillin
	name = "Spaceacillin (10 ml)"
	desc = "Contains antiviral agents."
	icon_state = "pill3"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/diet
	name = "diet pill"
	desc = "Guaranteed to get you slim!"
	icon_state = "pill4"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/noexcutite
	name = "Noexcutite (15 ml)"
	desc = "Feeling jittery? This should calm you down."
	icon_state = "pill4"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/antidexafen
	name = "Antidexafen (15 ml)"
	desc = "Common cold mediciation. Safe for babies!"
	icon_state = "pill4"
	mimic_color = TRUE

//Psychiatry pills.
/obj/item/reagent_containers/pill/methylphenidate
	name = "Methylphenidate (15 ml)"
	desc = "Improves the ability to concentrate."
	icon_state = "pill2"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/citalopram
	name = "Citalopram (15 ml)"
	desc = "Mild anti-depressant."
	icon_state = "pill4"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/paroxetine
	name = "Paroxetine (10 ml)"
	desc = "Before you swallow a bullet: try swallowing this!"
	icon_state = "pill4"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/hyronalin
	name = "Hyronalin (10 ml)"
	desc = "Got some rads? Eat this!"
	icon_state = "pill4"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/glucose
	name = "Glucose (20 ml)"
	desc = "Used to treat blood loss"
	icon_state = "pill4"
	mimic_color = TRUE

//Mining pills.
/obj/item/reagent_containers/pill/leporazine
	name = "Thermostabilizine"
	desc = "Contents 15 ml of leporazine. Effectively stabilizes body temperature."
	icon_state = "pill2"
	mimic_color = TRUE

//Not actually a pill, but pills type provide everything needed for this
/obj/item/reagent_containers/pill/sugar_cube
	name = "sugar cube"
	desc = "Sugar pressed together in block shape that is used to sweeten drinks."
	icon_state = "sugar_cubes"
	mimic_color = TRUE

//Not actually a pill, but pills type provide everything needed for this
/obj/item/reagent_containers/pill/cleanerpod
	name = "space cleaner pod"
	desc = "BLAM!-brand non-foaming space cleaner in concentrated form! Use one pod per half a liter water. Should not be consumed, but hey I'm not your mom nor a doctor."
	icon_state = "cleanerpod"
	mimic_color = FALSE

//Pills that probably won't be used anywhere, except in merchants or mapping, but who cares?

/obj/item/reagent_containers/pill/oxycodone
	name = "Oxycodone (15 ml)"
	desc = "A complex painkiller."
	icon_state = "pill3"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/metazine
	name = "Metazine (10 ml)"
	desc = "A combat painkiller."
	icon_state = "pill24"
	mimic_color = FALSE

/obj/item/reagent_containers/pill/tricordrazine
	name = "Tricordrazine (20 ml)"
	desc = "Used to slowly treat external injuries."
	icon_state = "pill2"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/alkysine
	name = "Alkysine (5 ml)"
	desc = "Do you have a headache? Just eat me!"
	icon_state = "pill2"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/imidazoline
	name = "Imidazoline (10 ml)"
	desc = "Used to treat eye injuries."
	icon_state = "pill2"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/ryetalyn
	name = "Ryetalyn (5 ml)"
	desc = "Used for genetic defects, including cataracts."
	icon_state = "pill3"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/peridaxon
	name = "Peridaxon (10 ml)"
	desc = "Used to restore the internal organs and nervous system."
	icon_state = "pill2"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/albumin
	name = "Albumin (20 ml)"
	desc = "Used to restore blood loss."
	icon_state = "pill3"
	mimic_color = TRUE

/obj/item/reagent_containers/pill/emezoline
	name = "Emezoline (15 ml)"
	desc = "Used to prevent vomiting."
	icon_state = "pill4"
	mimic_color = TRUE
