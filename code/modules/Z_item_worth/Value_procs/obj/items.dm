/obj/item/reagent_containers/Value()
	// TODO: CHEM
	. = ..()

/obj/item/stack/Value(base)
	return base * amount

/obj/item/stack/material/Value()
	if(!material)
		return ..()
	return material.value * amount

/obj/item/material/Value()
	return material.value * worth_multiplier
