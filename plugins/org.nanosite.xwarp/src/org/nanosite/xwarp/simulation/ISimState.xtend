package org.nanosite.xwarp.simulation

import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IPool
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.result.IResultRecorder

interface ISimState {
	
	def WActiveBehavior getActiveBehavior(IBehavior behavior, IScheduler scheduler, IResultRecorder recorder)
	def WActiveStep getActiveStep(IStep step, WActiveBehavior behavior)
	
	def WPoolState getPoolState(IPool pool)
}
