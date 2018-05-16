package org.nanosite.xwarp.model

import java.util.List
import java.util.Map

interface IStep extends IStepSuccessor, INamed {
	def String getQualifiedName()
	
	def boolean isFirst()

	def List<IStepSuccessor> getSuccessors()
	def List<IStep> getPredecessors()
	
	def boolean hasResourceNeeds()
	def void copyResourceNeeds(Map<IResource, IConsumableAmount> resourceNeedsCopy)

	def boolean hasSameBehavior(IStep other)	
}
