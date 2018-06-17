package org.nanosite.xwarp.model.impl

import com.google.common.collect.ImmutableList
import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.IConsumableAmount
import org.nanosite.xwarp.model.IPool
import org.nanosite.xwarp.model.IResource
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.model.IStepSuccessor

class WStep extends WNamedElement implements IStep {
	
	val Map<IResource, WAmount> nonPoolNeeds = newHashMap
	val Map<IPool, Long> poolNeeds = newHashMap

	WBehavior owner = null 
	
	List<IStepSuccessor> successors = newArrayList
	List<IStep> predecessors = newArrayList

	new(String name, long waitTime) {
		this(name, waitTime, null)
	}

	new(String name, Map<IResource, Long> resourceNeeds) {
		this(name, 0L, resourceNeeds)
	}
	
	new(String name, long waitTime, Map<IResource, Long> resourceNeeds) {
		super(name)

		// add wait request, if any
		if (waitTime>0L) {
			this.nonPoolNeeds.put(WResource.waitResource, new WAmount(waitTime))
		}
			
		if (resourceNeeds!==null) {
			for(rn : resourceNeeds.entrySet) {
				val type = rn.key
				if (type instanceof IPool) {
					// pool request, just store it
					this.poolNeeds.put(type, rn.value)
				} else {
					// scale needed loads and store it
					this.nonPoolNeeds.put(type, new WAmount(rn.value))
				}
			}
		}
	}
	
	def addSuccessor(IStepSuccessor successor) {
		successors.add(successor)
	}

	def finishInitialisation() {
		for(successor : successors.filter(WStep)) {
			successor.predecessors.add(this)
		}
	}
	
	override List<IStepSuccessor> getSuccessors() {
		ImmutableList.copyOf(successors)
	}

	override List<IStep> getPredecessors() {
		ImmutableList.copyOf(predecessors)
	}
	
	def setOwner(WBehavior owner) {
		this.owner = owner
	}

	override String getQualifiedName() {
		'''«owner.qualifiedName»::«name»'''
	}
	
	override boolean isFirst() {
		owner.firstStep == this
	}

	override boolean hasNonPoolNeeds() {
		!nonPoolNeeds.empty
	}

	override void copyNonPoolNeeds(Map<IResource, IConsumableAmount> nonPoolNeedsCopy) {
		nonPoolNeedsCopy.clear
		nonPoolNeeds.forEach[p1, p2 | nonPoolNeedsCopy.put(p1, p2.clone)]
	}

	override def Map<IPool, Long> getPoolNeeds() {
		poolNeeds
	}
	
	override boolean hasSameBehavior(IStep other) {
		if (other instanceof WStep)
			this.owner == other.owner
		else
			false
	}
	
	override String toString() {
		'''WStep(«if (owner!==null) qualifiedName else name»)'''
	}
}
