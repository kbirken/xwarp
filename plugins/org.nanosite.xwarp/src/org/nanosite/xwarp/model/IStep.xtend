package org.nanosite.xwarp.model

import java.util.List
import java.util.Map

interface IStep extends IStepSuccessor, INamed {
	def String getQualifiedName()
	
	static class ResourceInterface implements IScheduledConsumable {
		val IResource resource
		val int index
		new(IResource resource, int index) {
			this.resource = resource
			this.index = index
		}
		
		override getName() {
			resource.name + ":" + index
		}
		
		override isLimited() {
			resource.limited
		}
		
		def IResource getResource() {
			resource
		}
		
		def int getIndex() {
			index
		}
	}
	
	def IBehavior getOwner()
	def boolean isFirst()

	def List<IStepSuccessor> getSuccessors()
	def List<IStep> getPredecessors()
	
	def boolean hasNonPoolNeeds()
	def void copyNonPoolNeeds(Map<IScheduledConsumable, IConsumableAmount> nonPoolNeedsCopy)
	def long getResourcePenalty(IResource resource)

	def Map<IPool, Long> getPoolNeeds()

	def boolean hasSameBehavior(IStep other)
	
	def boolean shouldLog()	
}
