/obj/item/organ/internal/stomach
	name = "stomach"
	desc = "Gross. This is hard to stomach."
	icon_state = "stomach"
	dead_icon = "stomach"
	w_class = ITEM_SIZE_SMALL
	organ_tag = BP_STOMACH
	parent_organ = BP_CHEST
	min_bruised_damage = 20
	min_broken_damage = 45
	max_damage = 70
	relative_size = 40
	var/next_cramp = 0
	var/volume_softcap = 0.75 LITERS // Above this point we'll start feeling bad.
	var/volume_hardcap = 1.5 LITERS // At this point our only option is vomiting left and right.
	var/list/processing = list()
	var/obj/item/currently_processing = null
	var/next_processing = 0
	var/items_volume = 0

/obj/item/organ/internal/stomach/Destroy()
	QDEL_NULL(currently_processing)
	QDEL_NULL_LIST(processing)
	. = ..()

/obj/item/organ/internal/stomach/proc/ingest(obj/item/I)
	if(QDELETED(I))
		return
	I.forceMove(src)
	processing.Add(I)
	recalc_items_volume()

/obj/item/organ/internal/stomach/proc/recalc_items_volume()
	items_volume = 0
	if(!length(processing))
		return
	for(var/obj/item/I in processing)
		items_volume += I.get_storage_cost() * 50
