package org.nanosite.xwarp.model.impl

import org.nanosite.xwarp.model.IProcessor

class WProcessor extends WResource implements IProcessor {
	
	enum Scheduling {
		SCHED_PLAIN,
		SCHED_APS,
		SCHED_MULTICORE
	}

	new(String name) {
		// processors are always limited resources
		super(name, true)
	}
	
}
