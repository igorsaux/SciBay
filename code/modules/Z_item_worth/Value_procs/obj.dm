/obj/Value(base)
	. = ..(base)
	for(var/a in contents)
		. += get_base_value(a)
