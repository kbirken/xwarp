package org.nanosite.xwarp.model

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
	
	def static void add(IModel model, INamed item) {
		if (model instanceof WModel) {
			switch(item) {
				WResource: model.addResource(item)
				WConsumer: model.addConsumer(item)
				default: throw new RuntimeException("Unknown model item '" + item.name + "'")
			}
		}
	}

	def static void addInitial(IModel model, IBehavior behavior) {
		if (model instanceof WModel) {
			if (behavior instanceof WBehavior)
				model.addInitial(behavior)
		}
	}
	
	def static IResource processor(String name) {
		new WProcessor(name)
	}
	
	def static IConsumer consumer(String name) {
		new WConsumer(name)
	}

	def static void add(IConsumer consumer, IBehavior behavior) {
		if (consumer instanceof WConsumer) {
			if (behavior instanceof WBehavior)
				consumer.addBehavior(behavior)
		}
	}
	
	def static IBehavior behavior(String name) {
		new WBehavior(name)
	}

	def static void add(IBehavior behavior, IStep step) {
		if (behavior instanceof WBehavior) {
			if (step instanceof WStep)
				behavior.addStep(step)
		}
	}
	
	def static IStep step(String name, Map<IResource, Long> resourceNeeds) {
		new WStep(name, resourceNeeds)
	}

}
