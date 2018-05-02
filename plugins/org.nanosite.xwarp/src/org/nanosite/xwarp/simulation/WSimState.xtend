package org.nanosite.xwarp.simulation

import java.util.Map
import org.nanosite.xwarp.model.api.IBehavior
import org.nanosite.xwarp.model.api.IStep

class WSimState implements ISimState {

	val ILogger logger
	
	val Map<IBehavior, WActiveBehavior> activeBehaviors = newHashMap
	val Map<IStep, WActiveStep> activeSteps = newHashMap

	new (ILogger logger) {
		this.logger = logger
	}
	
	def clear() {
		activeBehaviors.clear
		activeSteps.clear
	}

	override getActiveBehavior(IBehavior behavior, IScheduler scheduler) {
		if (activeBehaviors.containsKey(behavior)) {
			activeBehaviors.get(behavior)
		} else {
			val activeBehavior = new WActiveBehavior(behavior, this, scheduler, logger)
			activeBehaviors.put(behavior, activeBehavior)
			activeBehavior
		}
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

}
