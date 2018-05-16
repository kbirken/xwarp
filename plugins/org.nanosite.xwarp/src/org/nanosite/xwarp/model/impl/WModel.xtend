package org.nanosite.xwarp.model.impl

import com.google.common.collect.ImmutableList
import java.util.List
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.model.IResource

class WModel implements IModel {

	List<WResource> resources = newArrayList
	List<WBandwidthResource> bandwidthResources = newArrayList
	List<WConsumer> consumers = newArrayList
	List<WBehavior> initial = newArrayList 
	
	var initialized = false
	
	new() {
		// add wait resource
		resources.add(WResource.waitResource)
	}
	
	def boolean addResource(WResource res) {
		resources.add(res)
		true
	}
	
	def boolean addBandwidthResource(WBandwidthResource res) {
		bandwidthResources.add(res)
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

	override List<IResource> getResources() {
		if (! initialized)
			finishInitialisation
		ImmutableList.copyOf(resources)
	}

	override List<IBehavior> getInitial() {
		if (! initialized)
			finishInitialisation
		ImmutableList.copyOf(initial)
	}
	
}
