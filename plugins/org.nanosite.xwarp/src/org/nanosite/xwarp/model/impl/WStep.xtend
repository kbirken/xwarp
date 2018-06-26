package org.nanosite.xwarp.model.impl

import com.google.common.collect.ArrayListMultimap
import com.google.common.collect.ImmutableList
import com.google.common.collect.Multimap
import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.IConsumable
import org.nanosite.xwarp.model.IConsumableAmount
import org.nanosite.xwarp.model.IPool
import org.nanosite.xwarp.model.IResource
import org.nanosite.xwarp.model.IScheduledConsumable
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.model.IStepSuccessor

class WStep extends WNamedElement implements IStep {
	
	val Map<IScheduledConsumable, WAmount> scheduledNeeds = newHashMap
	val Map<IPool, Long> poolNeeds = newHashMap

	val Map<IResource, Long> averageCSTs = newHashMap
	
	WBehavior owner = null 
	
	List<IStepSuccessor> successors = newArrayList
	List<IStep> predecessors = newArrayList

	new(String name, long waitTime) {
		this(name, waitTime, null)
	}

	new(String name, Map<IConsumable, Long> resourceNeeds) {
		this(name, 0L, resourceNeeds)
	}
	
	new(String name, long waitTime, Map<IConsumable, Long> resourceNeeds) {
		super(name)

		// add wait request, if any
		if (waitTime>0L) {
			this.scheduledNeeds.put(WUnlimitedResource.waitResource, new WAmount(waitTime))
		}
			
		if (resourceNeeds!==null) {
			val Map<IResource, Multimap<Integer, Long>> resources = newHashMap
			for(rn : resourceNeeds.entrySet) {
				val consumable = rn.key
				val amount = rn.value
				if (consumable instanceof IPool) {
					// pool request, just store it
					this.poolNeeds.put(consumable, amount)
				} else if (consumable instanceof IScheduledConsumable) {
					if (consumable instanceof IStep.ResourceInterface) {
						val res = consumable.resource
						if (! resources.containsKey(res)) {
							resources.put(res, ArrayListMultimap.create)
						}
						resources.get(res).put(consumable.index, amount)
					} else {
						// scale needed loads and store it (this is for processors only)
						this.scheduledNeeds.put(consumable, new WAmount(amount))
					}
				}
			}
			
			// now compute needs for bandwidth-limited resources
			for(rn : resources.entrySet) {
				val res = rn.key
				val perInterface = rn.value
				var rv = 0L
				var cst = 0L
				for(pi : perInterface.entries) {
					val index = pi.key
					val amount = pi.value
					rv += amount
					val cstRI = amount * res.getCST(index)
					cst += cstRI
				}
				
				if (rv>0L) {
					// CST is averaged across all I/O activities on one resource
					// (if there is only one I/O activity, averageCST will be equal to its CST)
					val long averageCST = cst/rv
					averageCSTs.put(res, averageCST)
					this.scheduledNeeds.put(res, new WAmount(rv))
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
		!scheduledNeeds.empty
	}

	override void copyNonPoolNeeds(Map<IScheduledConsumable, IConsumableAmount> scheduledNeedsCopy) {
		scheduledNeedsCopy.clear
		scheduledNeeds.forEach[p1, p2 | scheduledNeedsCopy.put(p1, p2.clone)]
	}

	override long getResourcePenalty(IResource resource) {
		if (averageCSTs.containsKey(resource))
			averageCSTs.get(resource)
		else
			0L
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
