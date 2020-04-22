package org.nanosite.xwarp.simulation

import java.util.Collection
import java.util.Map
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IPool
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.result.IResultRecorder

/***
 * Representation of the current simulation state.</p>
 * 
 * It maintains a mapping of model elements (e.g., behaviors, steps, pools)
 * to their active counterparts in the simulation engine.</p> 
 */
class WSimState implements ISimState {

	val ILogger logger
	
	val Map<IBehavior, WActiveBehavior> activeBehaviors = newHashMap
	val Map<IStep, WActiveStep> activeSteps = newHashMap

	val Map<IPool, WPoolState> poolStates = newHashMap

	new (ILogger logger) {
		this.logger = logger
	}
	
	def clear() {
		activeBehaviors.clear
		activeSteps.clear
		
		poolStates.clear
	}

	def Collection<WPoolState> getPoolStates() {
		poolStates.values
	}

	override getActiveBehavior(IBehavior behavior, IScheduler scheduler, IResultRecorder recorder) {
		if (activeBehaviors.containsKey(behavior)) {
			activeBehaviors.get(behavior)
		} else {
			val activeBehavior = new WActiveBehavior(behavior, this, scheduler, logger, recorder)
			activeBehaviors.put(behavior, activeBehavior)
			activeBehavior
		}
	}
	
	def getActiveBehaviors() {
		activeBehaviors
	}
	
	override getActiveStep(IStep step, WActiveBehavior behavior) {
		if (activeSteps.containsKey(step)) {
			activeSteps.get(step)
		} else {
			val activeStep = new WActiveStep(step, behavior)
			activeSteps.put(step, activeStep)
			activeStep
		}
	}

	override WPoolState getPoolState(IPool pool) {
		if (poolStates.containsKey(pool)) {
			poolStates.get(pool)
		} else {
			val poolState = new WPoolState(pool, logger)
			poolStates.put(pool, poolState)
			poolState
		}
	}
}
