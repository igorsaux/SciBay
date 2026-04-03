/proc/rand_hex_color()
	var/list/colors = list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f")
	var/color=""
	for(var/i in 0 to 5)
		color = color+pick(colors)
	return color
