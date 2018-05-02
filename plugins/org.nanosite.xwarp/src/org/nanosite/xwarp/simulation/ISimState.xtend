package org.nanosite.xwarp.simulation

import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IStep

interface ISimState {
	
	def WActiveBehavior getActiveBehavior(IBehavior behavior, IScheduler scheduler)
	def WActiveStep getActiveStep(IStep step, WActiveBehavior behavior)
	
}
