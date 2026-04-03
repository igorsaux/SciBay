
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.
//Notes by TobyThorne: This code is such a piece of shit i just can't. Rewrite it from scratch !!!as soon as possible!!!

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/reagent_containers/vessel/condiment
	name = "Condiment Container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/reagent_containers/condiments.dmi'
	icon_state = "emptycondiment"
	item_state = "emptycondiment"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	center_of_mass = "x=16;y=6"
	volume = 0.3 LITERS
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;50;60;100;150;250;300"
	lid_type = null
	can_flip = TRUE

/obj/item/reagent_containers/vessel/condiment/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/pen) || istype(W, /obj/item/device/flashlight/pen))
		var/tmp_label = sanitizeSafe(input(user, "Enter a label for [name]", "Label", label_text), MAX_NAME_LEN)
		if(tmp_label == label_text)
			return
		if(length(tmp_label) > 10)
			to_chat(user, "<span class='notice'>The label can be at most 10 characters long.</span>")
		else
			if(length(tmp_label))
				to_chat(user, "<span class='notice'>You set the label to \"[tmp_label]\".</span>")
				label_text = tmp_label
				name = addtext(name," ([label_text])")
			else
				to_chat(user, "<span class='notice'>You remove the label.</span>")
				label_text = null
		return



/obj/item/reagent_containers/vessel/condiment/attack_self(mob/user as mob)
	return

/obj/item/reagent_containers/vessel/condiment/attack(mob/M as mob, mob/user as mob, def_zone)
	return

/obj/item/reagent_containers/vessel/condiment/afterattack(obj/target, mob/user, proximity)
	if(!is_open_container() || !proximity) //Is the container open & are they next to whatever they're clicking?
		return //If not, do nothing.

	if(standard_pour_into(user, target))
		return

	..()

/obj/item/reagent_containers/vessel/condiment/enzyme
	name = "Universal Enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"

/obj/item/reagent_containers/vessel/condiment/barbecue
	name = "Barbecue Sauce"
	desc = "Barbecue sauce, it's labeled 'sweet and spicy'"
	icon_state = "barbecue"

/obj/item/reagent_containers/vessel/condiment/sugar

/obj/item/reagent_containers/vessel/condiment/small
	volume = 0.1 LITERS
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = "1;5;10;15;25;30;50;60;100"

/obj/item/reagent_containers/vessel/condiment/small/saltshaker
	name = "salt shaker"
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	center_of_mass = "x=16;y=9"

/obj/item/reagent_containers/vessel/condiment/small/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	center_of_mass = "x=16;y=8"

/obj/item/reagent_containers/vessel/condiment/small/sugar
	name = "sugar"
	desc = "Sweetness in a bottle"
	icon_state = "sugarsmall"
	center_of_mass = "x=17;y=9"

/obj/item/reagent_containers/vessel/condiment/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon_state = "flour"
	item_state = "flour"
	randpixel = 10
	volume = 1.0 LITER
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = "50;60;100;150;250;300;1000"


/obj/item/reagent_containers/vessel/condiment/astrotame
	name = "astrotame pack"

/obj/item/reagent_containers/vessel/condiment/creamer
	name = "creamer"

//Condiment packs. Packed sauces and sugar.

/obj/item/reagent_containers/vessel/condiment/pack
	name = "condiment pack"
	desc = "A small plastic pack with condiments to put on your food."
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list()

/obj/item/reagent_containers/vessel/condiment/pack/attack(mob/M, mob/user, def_zone)
	return // Well you can't really eat it

/obj/item/reagent_containers/vessel/condiment/pack/ketchup
	name = "ketchup pack"

/obj/item/reagent_containers/vessel/condiment/pack/hotsauce
	name = "hotsauce pack"

/obj/item/reagent_containers/vessel/condiment/pack/astrotame
	name = "astrotame pack"

/obj/item/reagent_containers/vessel/condiment/pack/bbqsauce
	name = "bbq sauce pack"

/obj/item/reagent_containers/vessel/condiment/pack/sugar
	name = "sugar pack"

/obj/item/reagent_containers/vessel/condiment/pack/creamer
	name = "creamer"
