package org.nanosite.xwarp.model

import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.impl.WBehavior
import org.nanosite.xwarp.model.impl.WConsumer
import org.nanosite.xwarp.model.impl.WModel
import org.nanosite.xwarp.model.impl.WPool
import org.nanosite.xwarp.model.impl.WProcessor
import org.nanosite.xwarp.model.impl.WResource
import org.nanosite.xwarp.model.impl.WStep
import org.nanosite.xwarp.model.impl.WTrigger

class ModelBuilder {
	
	enum Unit {
		SECONDS,
		MILLISECONDS,
		MICROSECONDS
	}
	
	val Unit resourceLoadUnits 
	
	new(Unit resourceLoadUnits) {
		this.resourceLoadUnits = resourceLoadUnits
	}
	
	def IModel model() {
		new WModel
	}
	
	def void add(IModel model, INamed... items) {
		if (model instanceof WModel) {
			items.forEach[
				switch(it) {
					IScheduledConsumable: model.addScheduledConsumable(it)
					WPool: model.addPool(it)
					WConsumer: model.addConsumer(it)
					default: throw new RuntimeException("Unknown model item '" + it.name + "'")
				}
			]
		}
	}
	
	def ITrigger trigger(IBehavior behavior, int inputIndex) {
		new WTrigger(behavior, inputIndex)
	}

	def void addInitial(IModel model, ITrigger... triggers) {
		if (model instanceof WModel) {
			val valid = triggers.filter(WTrigger)
			valid.forEach[ model.addInitial(it) ]
		}
	}
	
	//@Deprecated
	def void addInitial(IModel model, IBehavior... behaviors) {
		if (model instanceof WModel) {
			behaviors.filter(WBehavior).forEach[ model.addInitial(it) ]
		}
	}
	
	def IProcessor processor(String name) {
		new WProcessor(name)
	}
	
	def IResource resource(String name, List<Integer> cst) {
		new WResource(name, cst)
	}
	
	def IPool pool(
		String name,
		long maxAmount,
		IAllocatingConsumable.ErrorAction onOverflow,
		IAllocatingConsumable.ErrorAction onUnderflow
	) {
		new WPool(name, maxAmount, onOverflow, onUnderflow)
	}
	
	def IConsumer consumer(String name) {
		new WConsumer(name)
	}

	def void add(IConsumer consumer, IBehavior behavior, IBehavior... behaviors) {
		if (consumer instanceof WConsumer) {
			if (behavior instanceof WBehavior)
				consumer.addBehavior(behavior)
			behaviors.filter(WBehavior).forEach[consumer.addBehavior(it)]
		}
	}
	
	def WQueueConfig queueConfig(int nQueues, WQueueConfig.Strategy strategy) {
		new WQueueConfig(nQueues, strategy)
	}
	
	def WQueueConfig queueConfig(int nInstant, int nQueues, WQueueConfig.Strategy strategy) {
		new WQueueConfig(nInstant, nQueues, strategy)
	}
	
	def IBehavior behavior(String name) {
		behavior(name, 1, false)
	}

	def IBehavior behavior(String name, WQueueConfig queueConfig) {
		behavior(name, queueConfig, 1, false)
	}

	def IBehavior behavior(String name, int nIterations) {
		behavior(name, nIterations, false)
	}

	def IBehavior behavior(
		String name,
		int nIterations,
		boolean shouldAddTokens
	) {
		val behavior = new WBehavior(name, nIterations, shouldAddTokens)
		justCreated(behavior)
		behavior
	}

	def IBehavior behavior(
		String name,
		WQueueConfig queueConfig,
		int nIterations,
		boolean shouldAddTokens
	) {
		val behavior = new WBehavior(name, queueConfig, nIterations, shouldAddTokens)
		justCreated(behavior)
		behavior
	}

	def protected void justCreated(IBehavior behavior) { }
	
	def void repeatUnless(IBehavior behavior, IStep unlessConditionStep) {
		if (behavior instanceof WBehavior) {
			if (unlessConditionStep instanceof WStep)
				behavior.setUnlessCondition = unlessConditionStep
		}
	}
	
	def void add(IBehavior behavior, IStep step, IStep... steps) {
		if (behavior instanceof WBehavior) {
			if (step instanceof WStep)
				behavior.addStep(step)
			steps.filter(WStep).forEach[behavior.addStep(it)]
		}
	}
	
	def void send(IBehavior behavior, IBehavior triggered) {
		send(behavior, triggered, 0)
	}
	
	def void send(IBehavior behavior, IBehavior triggered, int inputIndex) {
		if (behavior instanceof WBehavior) {
			behavior.addSendTrigger(triggered, inputIndex)
		}
	}
	
	def void setNRequiredCycles(IBehavior behavior, int nRequiredCycles) {
		if (behavior instanceof WBehavior) {
			behavior.setNRequiredCycles(nRequiredCycles)
		}
	}
	
	def IStep step(String name, long waitTime) {
		val step = new WStep(name, waitTime, scalingFactor)
		justCreated(step)
		step
	}

	def WStep.ResourceInterface ri(IResource res, int interfaceIndex) {
		new WStep.ResourceInterface(res, interfaceIndex)
	}

	def IStep step(String name, Map<IConsumable, Long> resourceNeeds) {
		val step = new WStep(name, resourceNeeds, scalingFactor)
		justCreated(step)
		step
	}

	def IStep step(String name, long waitTime, Map<IConsumable, Long> resourceNeeds) {
		val step = new WStep(name, waitTime, resourceNeeds, scalingFactor)
		justCreated(step)
		step
	}

	def private long getScalingFactor() {
		switch(resourceLoadUnits) {
			case SECONDS: 1000000L
			case MILLISECONDS: 1000L
			case MICROSECONDS: 1L
			default: throw new RuntimeException("Invalid scaling factor " + resourceLoadUnits)
		}
	}

	def protected void justCreated(IStep step) { }

	def void precondition(IStep step, IStep predecessor) {
		if (step instanceof WStep) {
			if (predecessor instanceof WStep) {
				predecessor.addSuccessor(step)
			}
		}
	}
}
