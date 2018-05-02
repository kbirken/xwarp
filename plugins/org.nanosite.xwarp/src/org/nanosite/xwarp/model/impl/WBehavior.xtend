package org.nanosite.xwarp.model.impl

import java.util.List
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IStep

class WBehavior extends WNamedElement implements IBehavior {
	
	List<WStep> steps = newArrayList
	
	WConsumer owner = null 
	
	new(String name) {
		super(name)
	}

	def setOwner(WConsumer owner) {
		this.owner = owner
	}

	override String getQualifiedName() {
		'''«owner.name»::«name»'''
	}
	
	def boolean addStep(WStep step) {
		step.owner = this
		val previous = steps.last
		steps.add(step)
		previous?.addSuccessor(step)
		true
	}
	
	override IStep getFirstStep() {
		if (steps.empty)
			null
		else
			steps.head
	}

	override boolean isLastStep(IStep step) {
		step == steps.last
	}

}
