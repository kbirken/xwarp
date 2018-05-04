package org.nanosite.xwarp.simulation

import java.util.Map
import org.nanosite.xwarp.model.IResource
import org.nanosite.xwarp.result.StepInstance

interface IJob {

	def String getQualifiedName()
	def boolean isWaiting()

	def boolean hasResourceNeeds()
	def Map<IResource, Long> getResourceNeeds()
	
	def void useResource(IResource resource, long amount)
	
	def boolean isDone()
	
	def void exitActions()
	
	def void traceWaiting(long timestamp)
	def void traceReady(long timestamp)
	def void traceRunning(long timestamp)
	def void traceDone(long timestamp)

	def StepInstance clearResult()
}
