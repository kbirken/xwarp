package org.nanosite.xwarp.result

import java.util.List
import org.nanosite.xwarp.simulation.WPoolState

class SimResult {

	List<StepInstance> stepInstances = newArrayList
	List<WPoolState> poolStates = newArrayList
	
	def clear() {
		stepInstances.clear
		poolStates.clear
	}

	def addInstance(StepInstance si) {
		stepInstances.add(si)
	}

	def getStepInstances() {
		stepInstances
	}

	def addPoolState(WPoolState ps) {
		poolStates.add(ps)
	}
	
	def getPoolStates() {
		poolStates
	}

	def dump() {
		for(si : stepInstances)
			si.dump
	}
}
