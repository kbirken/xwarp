package org.nanosite.xwarp.simulation

import java.util.Map
import org.nanosite.xwarp.model.IResource

interface IJob {

	def String getQualifiedName()
	def boolean isWaiting()

	def boolean hasResourceNeeds()
	def Map<IResource, Long> getResourceNeeds()
	
	def void useResource(IResource resource, long amount)
	
	def boolean isDone()
	
	def void exitActions()
}
