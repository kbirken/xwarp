package org.nanosite.xwarp.model.impl

import com.google.common.collect.ImmutableList
import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.IResource
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.model.IStepSuccessor
import org.nanosite.xwarp.simulation.WIntAccuracy

class WStep extends WNamedElement implements IStep {
	
	val Map<WResource, Long> resourceNeeds = newHashMap

	WBehavior owner = null 
	
	List<IStepSuccessor> successors = newArrayList

	new(String name, Map<IResource, Long> resourceNeeds) {
		super(name)
		
		// scale needed loads and store it
		for(rn : resourceNeeds.entrySet) {
			val res = rn.key
			if (res instanceof WResource) {
				val amount = WIntAccuracy.toCalc(Scaling.resourceUItoWarp * rn.value) 
				this.resourceNeeds.put(res, amount)
			}
		}
	}

	def addSuccessor(IStepSuccessor successor) {
		successors.add(successor)
		
		if(successor instanceof WStep) {
//			if (_bhvr == step->_bhvr) {
//				// remember as direct predecessor in behavior
//				// will be added to _waitFor during prepareExecution()
//				step->_directPredecessor = this;
//			} else {
//				// this is a precondition or some other condition
//				step->waitFor(this);
//			}
		}
	}

	override List<IStepSuccessor> getSuccessors() {
		ImmutableList.copyOf(successors)
	}
	
	def setOwner(WBehavior owner) {
		this.owner = owner
	}

	override String getQualifiedName() {
		'''«owner.qualifiedName»::«name»'''
	}
	
	override boolean hasResourceNeeds() {
		!resourceNeeds.empty
	}

	override void copyResourceNeeds(Map<IResource, Long> resourceNeedsCopy) {
		resourceNeedsCopy.clear
		resourceNeedsCopy.putAll(resourceNeeds)
	}
}
