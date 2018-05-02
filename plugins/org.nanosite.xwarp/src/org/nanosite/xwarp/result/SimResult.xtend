package org.nanosite.xwarp.result

import java.util.List

class SimResult {

	List<StepInstance> stepInstances = newArrayList
	
	def clear() {
		stepInstances.clear
	}

	def addInstance(StepInstance si) {
		stepInstances.add(si)
	}

	def getStepInstances() {
		stepInstances
	}
	
	def dump() {
		for(si : stepInstances)
			si.dump
	}
}
