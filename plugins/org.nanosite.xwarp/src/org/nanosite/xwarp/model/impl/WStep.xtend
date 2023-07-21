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

class WStep extends WAbstractStep {
	
	val Map<IScheduledConsumable, WAmount> scheduledNeeds = newHashMap
	val Map<IPool, Long> poolNeeds = newHashMap

	val Map<IResource, Long> averageCSTs = newHashMap
	
	List<IStepSuccessor> successors = newArrayList
	List<IStep> predecessors = newArrayList

	new(String name, long waitTime, long scalingFactor) {
		this(name, waitTime, null, scalingFactor)
	}

	new(String name, Map<IConsumable, Long> resourceNeeds, long scalingFactor) {
		this(name, 0L, resourceNeeds, scalingFactor)
	}

	/**
	 * The wait time and the resource needs of the step can be specified
	 * using a scaling factor:
	 * <ul>
	 *   <li>if the values are in microseconds, use scaling factor of 1</li>
	 *   <li>if the values are in milliseconds, use scaling factor of 1,000</li>
	 *   <li>if the values are in seconds, use scaling factor of 1,000,000</li>
	 * </ul>
	 * </p>
	 * 
	 * For pool-type resources, no scaling will be applied.</p>
	 * 
	 * @parameter scalingFactor factor for scaling the resource loads
	 */	
	new(String name, long waitTime, Map<IConsumable, Long> resourceNeeds, long scalingFactor) {
		super(name)

		// add wait request, if any
		if (waitTime>0L) {
			this.scheduledNeeds.put(
				WUnlimitedResource.waitResource,
				new WAmount(waitTime*scalingFactor)
			)
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
						resources.get(res).put(consumable.index, amount*scalingFactor)
					} else {
						// scale needed loads and store it (this is for processors only)
						this.scheduledNeeds.put(consumable, new WAmount(amount*scalingFactor))
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

	override Map<IPool, Long> getPoolNeeds() {
		poolNeeds
	}
	
	override shouldLog() {
		true
	}

	override String toString() {
		'''WStep(«if (owner!==null) qualifiedName else name»)'''
	}	
}
