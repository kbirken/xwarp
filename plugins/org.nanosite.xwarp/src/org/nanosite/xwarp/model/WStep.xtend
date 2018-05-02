package org.nanosite.xwarp.model

import com.google.common.collect.ImmutableList
import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.api.IStep
import org.nanosite.xwarp.model.api.IStepSuccessor
import org.nanosite.xwarp.simulation.WIntAccuracy

class WStep extends WNamedElement implements IStep {
	
	val Map<WResource, Long> resourceNeeds = newHashMap

	WBehavior owner = null 
	
	List<IStepSuccessor> successors = newArrayList

	new(String name, Map<WResource, Long> resourceNeeds) {
		super(name)
		
		// scale needed loads and store it
		for(rn : resourceNeeds.entrySet) {
			this.resourceNeeds.put(rn.key,
				WIntAccuracy.toCalc(Scaling.resourceUItoWarp * rn.value)
			)
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

	override void copyResourceNeeds(Map<WResource, Long> resourceNeedsCopy) {
		resourceNeedsCopy.clear
		resourceNeedsCopy.putAll(resourceNeeds)
	}
}
