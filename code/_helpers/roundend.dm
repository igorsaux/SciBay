GLOBAL_LIST_EMPTY(common_report)

/datum/controller/subsystem/ticker/proc/personal_report(client/C, popcount)
	var/list/parts = list()
	var/mob/Player = C.mob
	if(Player.mind && !isnewplayer(Player))
		if(!Player.is_ooc_dead() && !isbrain(Player))
			var/turf/playerTurf = get_turf(Player)
			if(isAdminLevel(playerTurf.z))
				parts += "<div class='panel greenborder'>"
				parts += "<span class='greentext'>You successfully underwent crew transfer after events on [station_name()] as [Player.real_name].</span>"
			else
				parts += "<div class='panel greenborder'>"
				parts += "<span class='greentext'>You got through just another workday on [station_name()] as [Player.real_name].</span>"

		else
			var/mob/observer/ghost/O = Player
			if(!istype(O) || (istype(O) && !O.started_as_observer))
				parts += "<div class='panel redborder'>"
				parts += "<span class='redtext'>You did not survive the events on [station_name()]...</span>"
	else
		parts += "<div class='panel stationborder'>"
	parts += "<br>"
	parts += "</div>"

	return parts.Join()

/datum/controller/subsystem/ticker/proc/_last_words_report()
	if(!length(GLOB.last_words))
		return

	var/list/parts = list()

	parts += "<div class='panel stationborder'><span class='marooned'><b>Last words of the first victims:</b></span><br>"

	for(var/index = 1 to min(length(GLOB.last_words), 4))
		var/datum/last_words_data/data = GLOB.last_words[index]

		parts += "<b>[data.real_name]</b>, the <b>[data.job_title]</b>: \"[data.words]\"<br>"

	parts += "</div>"

	return parts

//Common part of the report
/datum/controller/subsystem/ticker/proc/build_roundend_report()
	var/list/parts = list()

	CHECK_TICK

	parts += mode.special_report()

	CHECK_TICK

	parts += _last_words_report()

	listclearnulls(parts)

	CHECK_TICK

	return parts.Join()

/datum/controller/subsystem/ticker/proc/display_report()
	GLOB.common_report = build_roundend_report()

	//taken from to_chat(), processes all explanded \icon macros since they don't work in minibrowser (they only work in text output)
	var/static/regex/icon_replacer = new(@/<IMG CLASS=icon SRC=(\[[^]]+])(?: ICONSTATE='([^']+)')?>/, "g")	//syntax highlighter fix -> '
	while(icon_replacer.Find(GLOB.common_report))
		GLOB.common_report =\
			copytext(GLOB.common_report,1,icon_replacer.index) +\
			icon2html(locate(icon_replacer.group[1]), target = world, icon_state=icon_replacer.group[2]) +\
			copytext(GLOB.common_report,icon_replacer.next)


	for(var/client/C in GLOB.clients)
		show_roundend_report(C)
		give_show_report_button(C)
		CHECK_TICK
	log_roundend(GLOB.common_report)

/datum/controller/subsystem/ticker/proc/give_show_report_button(client/C)
	if(!istype(C.mob, /mob/living))
		return

	var/datum/action/report/R = new
	R.Grant(C.mob)
	to_chat(C,"<a href='?src=\ref[R];report=1'>Show roundend report again</a>")

/datum/action/report
	name = "Show roundend report"
	button_icon_state = "round_end"

/datum/action/report/Trigger()
	if(owner && GLOB.common_report)
		SSticker.show_roundend_report(owner.client, TRUE)

/datum/action/report/IsAvailable()
	return 1

/datum/action/report/Topic(href,href_list)
	if(usr != owner)
		return
	if(href_list["report"])
		Trigger()
		return

/client/proc/roundend_report_file()
	return "data/roundend_reports/[ckey].html"

/datum/controller/subsystem/ticker/proc/show_roundend_report(client/C, previous = FALSE)
	var/datum/browser/roundend_report = new(C.mob, "roundend")
	roundend_report.width = 800
	roundend_report.height = 600
	var/content
	var/filename = C.roundend_report_file()
	if(!previous)
		var/list/report_parts = list(personal_report(C), GLOB.common_report)
		content = report_parts.Join()
		fdel(filename)
		text2file(content, filename)
	else
		content = file2text(filename)
	roundend_report.set_content(content)
	roundend_report.stylesheets = list()
	roundend_report.add_stylesheet("roundend", 'html/browser/roundend.css')
	roundend_report.add_stylesheet("font-awesome", 'html/font-awesome/css/all.min.css')
	to_chat(C, content)
	roundend_report.open(FALSE)
