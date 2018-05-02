package org.nanosite.xwarp.model

import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.impl.WResource

interface IStep extends IStepSuccessor {
	def String getQualifiedName()

	def List<IStepSuccessor> getSuccessors()
	
	def boolean hasResourceNeeds()
	def void copyResourceNeeds(Map<WResource, Long> resourceNeedsCopy)
	
}
