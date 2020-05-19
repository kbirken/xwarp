package org.nanosite.xwarp.result

import java.util.List
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IPool
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.simulation.WPoolState

class SimResult implements IResultRecorder, ISimResult {

	List<IterationResult> iterations = newArrayList

	boolean reachedMaxIterations = false
	boolean reachedTimeLimit = false
	
	QueueOverflow queueOverflowAbort = null
	
	List<BehaviorInstance> behaviorInstances = newArrayList
	List<StepInstance> stepInstances = newArrayList
	List<WPoolState> poolStates = newArrayList

	List<IBehavior> remainingBehaviors = newArrayList

	def clear() {
		iterations.clear
		reachedMaxIterations = false
		reachedTimeLimit = false
		queueOverflowAbort = null
		behaviorInstances.clear
		stepInstances.clear
		poolStates.clear
		remainingBehaviors.clear
	}

	def addIteration(IterationResult iteration) {
		iterations.add(iteration)
	}
	
	def setReachedMaxIterations() {
		reachedMaxIterations = true
	}
	
	def setReachedTimeLimit() {
		reachedTimeLimit = true
	}
	
	def setQueueOverflowAbort(IBehavior behavior, int inputIndex) {
		queueOverflowAbort = new QueueOverflow(behavior, inputIndex)
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
	
	override getNIterations() {
		iterations.size
	}
	
	override getIterations() {
		iterations
	}
	
	override reachedMaxIterations() {
		reachedMaxIterations
	}
	
	override reachedTimeLimit() {
		reachedTimeLimit
	}
	
	override getQueueOverflowAbort() {
		queueOverflowAbort
	}
	
	override getBehaviorInstances() {
		behaviorInstances
	}
	
	override getKilledBehaviorInstances() {
		behaviorInstances.filter[wasKilled]
	}
	
	override getStepInstances() {
		stepInstances
	}
	
	override List<StepInstance> getStepInstances(IStep step) {
		// TODO: introduce multimap for performance
		stepInstances.filter[it.step==step].toList
	}

	override getPoolStates() {
		poolStates
	}
	
	override getPoolState(IPool pool) {
		// TODO: introduce map for performance
		poolStates.findFirst[it.pool==pool]
	}
	
	override getRemainingBehaviors() {
		remainingBehaviors
	}

	override dump() {
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
