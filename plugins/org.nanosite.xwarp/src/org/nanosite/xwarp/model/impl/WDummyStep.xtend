package org.nanosite.xwarp.model.impl

import java.util.Map
import org.nanosite.xwarp.model.IScheduledConsumable
import org.nanosite.xwarp.model.IConsumableAmount
import org.nanosite.xwarp.model.IResource

class WDummyStep extends WAbstractStep {
	
	new() {
		super("__")
	}
	
	override getSuccessors() {
		newArrayList
	}
	
	override getPredecessors() {
		newArrayList
	}
	
	override hasNonPoolNeeds() {
		false
	}
	
	override copyNonPoolNeeds(Map<IScheduledConsumable, IConsumableAmount> nonPoolNeedsCopy) {
		nonPoolNeedsCopy.clear
	}
	
	override getResourcePenalty(IResource resource) {
		0L
	}
	
	override getPoolNeeds() {
		newHashMap
	}

	override shouldLog() {
		false
	}		

	override String toString() {
		'''WDummyStep(«if (owner!==null) owner.qualifiedName else name»)'''
	}	
}
