package org.nanosite.xwarp.result

import java.util.List
import org.nanosite.xwarp.simulation.WPoolState

class SimResult {

	List<IterationResult> iterations = newArrayList

	List<StepInstance> stepInstances = newArrayList
	List<WPoolState> poolStates = newArrayList
	
	def clear() {
		iterations.clear
		stepInstances.clear
		poolStates.clear
	}

	def addIteration(IterationResult iteration) {
		iterations.add(iteration)
	}
	
	def addInstance(StepInstance si) {
		stepInstances.add(si)
	}

	def addPoolState(WPoolState ps) {
		poolStates.add(ps)
	}
	
	def getIterations() {
		iterations
	}
	
	def getStepInstances() {
		stepInstances
	}

	def getPoolStates() {
		poolStates
	}

	def dump() {
		println("ITERATIONS: ")
		for(iter : iterations)
			iter.dump
			
		println("STEP INSTANCES: ")
		for(si : stepInstances)
			si.dump
	}
}
