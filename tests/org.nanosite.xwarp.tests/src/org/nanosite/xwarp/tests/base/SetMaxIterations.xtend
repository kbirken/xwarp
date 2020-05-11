package org.nanosite.xwarp.tests.base

import org.nanosite.xwarp.tests.base.ISimConfig
import org.nanosite.xwarp.simulation.WSimulator

class SetMaxIterations implements ISimConfig {

	val int nMaxIter
	
	new(int nMaxIter) {
		this.nMaxIter = nMaxIter
	}
	
	override applyTo(WSimulator simulator) {
		simulator.NMaxIterations = nMaxIter
	}
}
