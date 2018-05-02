package org.nanosite.xwarp.model

import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.impl.WBehavior
import org.nanosite.xwarp.model.impl.WConsumer
import org.nanosite.xwarp.model.impl.WModel
import org.nanosite.xwarp.model.impl.WProcessor
import org.nanosite.xwarp.model.impl.WResource
import org.nanosite.xwarp.model.impl.WStep

class ModelBuilder {
	
	def static IModel model() {
		new WModel
	}
	
	def static void add(IModel model, INamed... items) {
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
	
	def static void addInitial(IModel model, IBehavior... behaviors) {
		if (model instanceof WModel) {
			behaviors.filter(WBehavior).forEach [ model.addInitial(it) ]
		}
	}
	
	def static IResource processor(String name) {
		new WProcessor(name)
	}
	
	def static IConsumer consumer(String name) {
		new WConsumer(name)
	}

	def static void add(IConsumer consumer, IBehavior behavior, IBehavior... behaviors) {
		if (consumer instanceof WConsumer) {
			if (behavior instanceof WBehavior)
				consumer.addBehavior(behavior)
			behaviors.filter(WBehavior).forEach[consumer.addBehavior(it)]
		}
	}
	
	def static IBehavior behavior(String name) {
		new WBehavior(name)
	}

	def static void add(IBehavior behavior, IStep step, IStep... steps) {
		if (behavior instanceof WBehavior) {
			if (step instanceof WStep)
				behavior.addStep(step)
			steps.filter(WStep).forEach[behavior.addStep(it)]
		}
	}
	
	def static IStep step(String name, Map<IResource, Long> resourceNeeds) {
		new WStep(name, resourceNeeds)
	}

}
