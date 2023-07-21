package org.nanosite.xwarp.result

import java.util.List
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IPool
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.simulation.WPoolState

/**
 * The API for accessing simulation results.</p>
 */
interface ISimResult {

	def int getNIterations()
	def List<IterationResult> getIterations()
	
	def boolean reachedMaxIterations()
	def boolean reachedTimeLimit()

	static class QueueOverflow {
		public IBehavior behavior
		public int inputIndex
		new(IBehavior behavior, int inputIndex) {
			this.behavior = behavior
			this.inputIndex = inputIndex
		}
	}

	def QueueOverflow getQueueOverflowAbort()
	
	def List<BehaviorInstance> getBehaviorInstances()
	def Iterable<BehaviorInstance> getKilledBehaviorInstances()
	def List<StepInstance> getStepInstances()
	def List<StepInstance> getStepInstances(IStep step)
	
	def List<WPoolState> getPoolStates()
	def WPoolState getPoolState(IPool pool)
	
	def List<IBehavior> getRemainingBehaviors()
	
	def void dump()
}
