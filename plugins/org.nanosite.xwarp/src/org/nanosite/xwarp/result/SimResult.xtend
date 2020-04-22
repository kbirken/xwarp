package org.nanosite.xwarp.result

import java.util.List
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IPool
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.simulation.WPoolState

class SimResult implements IResultRecorder {

	List<IterationResult> iterations = newArrayList

	List<BehaviorInstance> behaviorInstances = newArrayList
	List<StepInstance> stepInstances = newArrayList
	List<WPoolState> poolStates = newArrayList

	List<IBehavior> remainingBehaviors = newArrayList
		
	def clear() {
		iterations.clear
		behaviorInstances.clear
		stepInstances.clear
		poolStates.clear
	}

	def addIteration(IterationResult iteration) {
		iterations.add(iteration)
	}
	
	override addBehaviorResult(BehaviorInstance bi) {
		behaviorInstances.add(bi)
	}

	override addStepResult(StepInstance si) {
		stepInstances.add(si)
	}

	def addPoolState(WPoolState ps) {
		poolStates.add(ps.clone)
	}
	
	def addRemainingBehaviors(Iterable<IBehavior> behaviors) {
		remainingBehaviors.addAll(behaviors)
	}
	
	def getNIterations() {
		iterations.size
	}
	
	def getIterations() {
		iterations
	}
	
	def getBehaviorInstances() {
		behaviorInstances
	}
	
	def getKilledBehaviorInstances() {
		behaviorInstances.filter[wasKilled]
	}
	
	def getStepInstances() {
		stepInstances
	}
	
	def List<StepInstance> getStepInstances(IStep step) {
		// TODO: introduce multimap for performance
		stepInstances.filter[it.step==step].toList
	}

	def getPoolStates() {
		poolStates
	}
	
	def getPoolState(IPool pool) {
		// TODO: introduce map for performance
		poolStates.findFirst[it.pool==pool]
	}
	
	def getRemainingBehaviors() {
		remainingBehaviors
	}

	def dump() {
		println("ITERATIONS: ")
		for(iter : iterations)
			iter.dump
			
		println("\nBEHAVIOR INSTANCES: ")
		for(bi : behaviorInstances)
			bi.dump

		println("\nSTEP INSTANCES: ")
		for(si : stepInstances)
			si.dump
	}
}
