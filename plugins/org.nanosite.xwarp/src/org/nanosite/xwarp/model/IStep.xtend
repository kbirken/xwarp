package org.nanosite.xwarp.model

import java.util.List
import java.util.Map

interface IStep extends IStepSuccessor {
	def String getQualifiedName()

	def List<IStepSuccessor> getSuccessors()
	
	def boolean hasResourceNeeds()
	def void copyResourceNeeds(Map<IResource, Long> resourceNeedsCopy)
	
}
