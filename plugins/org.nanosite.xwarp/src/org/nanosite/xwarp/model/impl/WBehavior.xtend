package org.nanosite.xwarp.model.impl

import java.util.List
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IStep
import com.google.common.collect.ImmutableList
import org.nanosite.xwarp.model.WQueueConfig
import org.nanosite.xwarp.model.ITrigger

class WBehavior extends WNamedElement implements IBehavior {
	
	val WQueueConfig queueConfig
	
	val int nIterations
	val boolean addToken
	
	var WStep unlessCondition = null
	
	List<WStep> steps = newArrayList
	List<WTrigger> sendTriggers = newArrayList
	
	// number of execution cycles needed for validating incoming messages
	var int nRequiredCycles = 1
	
	WConsumer owner = null 
	
	new(String name, boolean addToken) {
		this(name, WQueueConfig.STANDARD, 1, addToken)
	}
	
	new(String name, WQueueConfig queueConfig, boolean addToken) {
		this(name, queueConfig, 1, addToken)
	}
	
	new(String name, int nIterations, boolean addToken) {
		this(name, WQueueConfig.STANDARD, nIterations, addToken)
	}
	
	new(
		String name,
		WQueueConfig queueConfig,
		int nIterations,
		boolean addToken
	) {
		super(name)
		this.queueConfig = queueConfig
		this.nIterations = nIterations
		this.addToken = addToken
	}

	def setNRequiredCycles(int nRequiredCycles) {
		this.nRequiredCycles = nRequiredCycles	
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
	
	override WQueueConfig getQueueConfig() {
		queueConfig
	}
	
	override int getNIterations() {
		nIterations
	}
	
	override int getNRequiredCycles() {
		nRequiredCycles
	}
	
	override IStep getUnlessCondition() {
		unlessCondition
	}
	
	def boolean setUnlessCondition(WStep step) {
		this.unlessCondition = step
		
		// add to successors of step in order to be notified if unless-condition is active
		step.addSuccessor(this)

		true
	}
	
	def boolean addStep(WStep step) {
		step.owner = this
		val previous = steps.last
		steps.add(step)
		previous?.addSuccessor(step)
		true
	}

	def boolean addSendTrigger(IBehavior behavior, int inputIndex) {
		sendTriggers.add(new WTrigger(behavior, inputIndex))
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

	override List<ITrigger> getSendTriggers() {
		ImmutableList.copyOf(sendTriggers)
	}

	override String toString() {
		'''WBehavior(«if (owner!==null) qualifiedName else name»)'''
	}
}
