package org.nanosite.xwarp.tests.base

import org.nanosite.xwarp.tests.base.ISimConfig
import org.nanosite.xwarp.simulation.WSimulator

class SetTimeLimit implements ISimConfig {

	val long tLimit
	
	new(long tLimit) {
		this.tLimit = tLimit
	}
	
	override applyTo(WSimulator simulator) {
		simulator.timeLimit = tLimit
	}
}
