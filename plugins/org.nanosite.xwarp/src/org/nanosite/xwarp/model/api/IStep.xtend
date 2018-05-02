package org.nanosite.xwarp.model.api

import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.WResource

interface IStep extends IStepSuccessor {
	def String getQualifiedName()

	def List<IStepSuccessor> getSuccessors()
	
	def boolean hasResourceNeeds()
	def void copyResourceNeeds(Map<WResource, Long> resourceNeedsCopy)
	
}
