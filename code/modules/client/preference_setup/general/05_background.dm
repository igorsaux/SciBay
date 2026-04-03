/datum/preferences
	var/memory = ""

/datum/category_item/player_setup_item/general/background
	name = "Background"
	sort_order = 5

/datum/category_item/player_setup_item/general/background/load_character(datum/pref_record_reader/R)
	pref.memory = R.read("memory")

/datum/category_item/player_setup_item/general/background/save_character(datum/pref_record_writer/W)
	W.write("memory", pref.memory)

/datum/category_item/player_setup_item/general/background/sanitize_character()
	return

/datum/category_item/player_setup_item/general/background/content(mob/user)
	. += "<br/><b>Records</b>:<br/>"
	. += "Memory:<br>"
	. += "<a href='?src=\ref[src];set_memory=1'>[TextPreview(pref.memory,40)]</a><br>"

/datum/category_item/player_setup_item/general/background/OnTopic(href,list/href_list, mob/user)
	if(href_list["set_memory"])
		var/memes = sanitize(tgui_input_pencode_editor(user,"Enter memorized information here.","Character Preference", html_decode(pref.memory)))
		if(!isnull(memes) && CanUseTopic(user))
			pref.memory = memes
		return TOPIC_REFRESH

	return ..()
