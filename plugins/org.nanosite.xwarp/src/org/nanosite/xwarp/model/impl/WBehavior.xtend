package org.nanosite.xwarp.model.impl

import java.util.List
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IStep
import com.google.common.collect.ImmutableList

class WBehavior extends WNamedElement implements IBehavior {
	
	val int nIterations
	val boolean addToken
		
	List<WStep> steps = newArrayList
	List<IBehavior> sendTriggers = newArrayList
	
	WConsumer owner = null 
	
	new(String name, boolean addToken) {
		this(name, 1, addToken)
	}
	
	new(String name, int nIterations, boolean addToken) {
		super(name)
		this.nIterations = nIterations
		this.addToken = addToken
	}

	def setOwner(WConsumer owner) {
		this.owner = owner
	}

	def void finishInitialisation() {
		steps.forEach[finishInitialisation]
	}
	
	override String getQualifiedName() {
		if (owner!==null)
			'''«owner.name»::«name»'''
		else 
			'''??::«name»'''
	}
	
	override boolean shouldAddToken() {
		addToken
	}
	
	override int getNIterations() {
		nIterations
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

	override IStep getLastStep() {
		if (steps.empty)
			null
		else
			steps.last
	}

	override boolean isLastStep(IStep step) {
		step == steps.last
	}

	override List<IBehavior> getSendTriggers() {
		ImmutableList.copyOf(sendTriggers)
	}

	override String toString() {
		'''WBehavior(«if (owner!==null) qualifiedName else name»)'''
	}
}
