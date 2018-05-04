package org.nanosite.xwarp.model.impl

import java.util.List
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IStep
import com.google.common.collect.ImmutableList

class WBehavior extends WNamedElement implements IBehavior {
	
	val boolean addToken
		
	List<WStep> steps = newArrayList
	List<IBehavior> sendTriggers = newArrayList
	
	WConsumer owner = null 
	
	new(String name, boolean addToken) {
		super(name)
		this.addToken = addToken
	}

	def setOwner(WConsumer owner) {
		this.owner = owner
	}

	override String getQualifiedName() {
		'''«owner.name»::«name»'''
	}
	
	override boolean shouldAddToken() {
		addToken
	}
	
	def boolean addStep(WStep step) {
		step.owner = this
		val previous = steps.last
		steps.add(step)
		previous?.addSuccessor(step)
		true
	}

	def boolean addSendTrigger(IBehavior behavior) {
		sendTriggers.add(behavior)
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

	override List<IBehavior> getSendTriggers() {
		ImmutableList.copyOf(sendTriggers)
	}
}
