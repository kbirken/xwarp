package org.nanosite.xwarp.model

import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.impl.WBandwidthResource
import org.nanosite.xwarp.model.impl.WBehavior
import org.nanosite.xwarp.model.impl.WConsumer
import org.nanosite.xwarp.model.impl.WModel
import org.nanosite.xwarp.model.impl.WProcessor
import org.nanosite.xwarp.model.impl.WResource
import org.nanosite.xwarp.model.impl.WStep

class ModelBuilder {
	
	def IModel model() {
		new WModel
	}
	
	def void add(IModel model, INamed... items) {
		if (model instanceof WModel) {
			items.forEach[
				switch(it) {
					WResource: model.addResource(it)
					WConsumer: model.addConsumer(it)
					default: throw new RuntimeException("Unknown model item '" + it.name + "'")
				}
			]
		}
	}
	
	def void addInitial(IModel model, IBehavior... behaviors) {
		if (model instanceof WModel) {
			behaviors.filter(WBehavior).forEach [ model.addInitial(it) ]
		}
	}
	
	def IResource processor(String name) {
		new WProcessor(name)
	}
	
	def IBandwidthResource resource(String name, List<Integer> cst) {
		new WBandwidthResource(name, cst)
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
	
	def IBehavior behavior(String name) {
		behavior(name, false)
	}

	def IBehavior behavior(String name, boolean shouldAddTokens) {
		val behavior = new WBehavior(name, shouldAddTokens)
		justCreated(behavior)
		behavior
	}

	def protected void justCreated(IBehavior behavior) { }
	
	def void add(IBehavior behavior, IStep step, IStep... steps) {
		if (behavior instanceof WBehavior) {
			if (step instanceof WStep)
				behavior.addStep(step)
			steps.filter(WStep).forEach[behavior.addStep(it)]
		}
	}
	
	def void send(IBehavior behavior, IBehavior triggered) {
		if (behavior instanceof WBehavior) {
			behavior.addSendTrigger(triggered)
		}
	}
	
	def IStep step(String name, long waitTime) {
		val step = new WStep(name, waitTime)
		justCreated(step)
		step
	}

	def IStep step(String name, Map<IResource, Long> resourceNeeds) {
		val step = new WStep(name, resourceNeeds)
		justCreated(step)
		step
	}

	def IStep step(String name, long waitTime, Map<IResource, Long> resourceNeeds) {
		val step = new WStep(name, waitTime, resourceNeeds)
		justCreated(step)
		step
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
