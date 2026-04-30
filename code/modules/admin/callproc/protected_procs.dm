
/proc/is_proc_protected(procname)
    var/static/list/protected_procs = list(
		"shutdown"
    )
    return procname in protected_procs
