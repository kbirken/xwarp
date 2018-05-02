package org.nanosite.xwarp.model.impl

class WProcessor extends WResource {
	
	enum Scheduling {
		SCHED_PLAIN,
		SCHED_APS,
		SCHED_MULTICORE
	}

	new(String name) {
		super(name)
	}
	
}
