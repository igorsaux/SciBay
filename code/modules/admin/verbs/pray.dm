/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	if(isnewplayer(src))
		to_chat(src, SPAN_WARNING("This verb may only be used by living mobs, sorry."))
		return

	sanitize_and_communicate(/decl/communication_channel/pray, src, msg)
