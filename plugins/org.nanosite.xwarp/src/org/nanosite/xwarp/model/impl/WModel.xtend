package org.nanosite.xwarp.model.impl

import com.google.common.collect.ImmutableList
import java.util.List
import org.nanosite.xwarp.model.IAllocatingConsumable
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IConsumer
import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.model.IScheduledConsumable

class WModel implements IModel {

	List<IScheduledConsumable> scheduledConsumables = newArrayList
	List<IAllocatingConsumable> allocatingConsumables = newArrayList

	List<WConsumer> consumers = newArrayList
	List<WBehavior> initial = newArrayList 
	
	var initialized = false
	
	new() {
		// add wait resource
		scheduledConsumables.add(WUnlimitedResource.waitResource)
	}
	
	def boolean addScheduledConsumable(IScheduledConsumable res) {
		scheduledConsumables.add(res)
		true
	}
	
	def boolean addPool(WPool pool) {
		allocatingConsumables.add(pool)
		true
	}

	def boolean addConsumer(WConsumer consumer) {
		consumers.add(consumer)
		true
	}

	def boolean addInitial(WBehavior behavior) {
		initial.add(behavior)
		true
	}

	def void finishInitialisation() {
		consumers.forEach[finishInitialisation]
		initialized = true
	}

	override List<IScheduledConsumable> getScheduledConsumables() {
		if (! initialized)
			finishInitialisation
		ImmutableList.copyOf(scheduledConsumables)
	}

	override List<IAllocatingConsumable> getAllocatingConsumables() {
		if (! initialized)
			finishInitialisation
		ImmutableList.copyOf(allocatingConsumables)
	}

	override List<IBehavior> getInitial() {
		if (! initialized)
			finishInitialisation
		ImmutableList.copyOf(initial)
	}

	override List<IConsumer> getConsumers() {
		if (! initialized)
			finishInitialisation
		ImmutableList.copyOf(consumers)
	}
	
}
