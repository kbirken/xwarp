package org.nanosite.xwarp.simulation

import org.nanosite.xwarp.model.api.IBehavior
import org.nanosite.xwarp.model.api.IStep

interface ISimState {
	
	def WActiveBehavior getActiveBehavior(IBehavior behavior, IScheduler scheduler)
	def WActiveStep getActiveStep(IStep step, WActiveBehavior behavior)
	
}
