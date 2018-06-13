package org.nanosite.xwarp.model

import java.util.List
import java.util.Map

interface IStep extends IStepSuccessor, INamed {
	def String getQualifiedName()
	
	def boolean isFirst()

	def List<IStepSuccessor> getSuccessors()
	def List<IStep> getPredecessors()
	
	def boolean hasNonPoolNeeds()
	def void copyNonPoolNeeds(Map<IResource, IConsumableAmount> nonPoolNeedsCopy)

	def Map<IPool, Long> getPoolNeeds()
	 
	def boolean hasSameBehavior(IStep other)	
}
