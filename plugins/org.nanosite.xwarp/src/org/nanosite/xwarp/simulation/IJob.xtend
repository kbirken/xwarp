package org.nanosite.xwarp.simulation

import java.util.Map
import org.nanosite.xwarp.model.WResource

interface IJob {

	def String getQualifiedName()
	def boolean isWaiting()

	def boolean hasResourceNeeds()
	def Map<WResource, Long> getResourceNeeds()
	
	def void useResource(WResource resource, long amount)
	
	def boolean isDone()
	
	def void exitActions()
}
