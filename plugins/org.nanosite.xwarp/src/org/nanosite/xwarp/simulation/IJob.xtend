package org.nanosite.xwarp.simulation

import java.util.Map
import org.nanosite.xwarp.model.IConsumableAmount
import org.nanosite.xwarp.model.IPool
import org.nanosite.xwarp.model.IResource
import org.nanosite.xwarp.model.IScheduledConsumable
import org.nanosite.xwarp.result.IResultRecorder
import org.nanosite.xwarp.result.StepInstance

interface IJob {

	def String getQualifiedName()
	def boolean isWaiting()

	def boolean hasConsumableNeeds()
	def Map<IScheduledConsumable, IConsumableAmount> getConsumableNeeds()
	def long getConsumableNeed(IScheduledConsumable consumable)
	def long getResourcePenalty(IResource resource)
	
	def void useConsumable(IScheduledConsumable resource, long amount)
	
	def Map<IPool, Long> getPoolNeeds()
	
	def boolean isDone()
	
	def void exitActions(IResultRecorder recorder)
	def void notifyKilled()
	
	def boolean isPartOfNoProgressInfiniteLoop()
	
	def void traceWaiting(long timestamp)
	def void traceReady(long timestamp)
	def void traceRunning(long timestamp)
	def void traceDone(long timestamp)
	
	def void traceNMissingCycles(int nMissingCycles)

	def boolean shouldLog()
	
	def StepInstance getResult()
}
