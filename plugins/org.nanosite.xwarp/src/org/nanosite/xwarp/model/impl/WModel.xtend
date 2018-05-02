package org.nanosite.xwarp.model.impl

import com.google.common.collect.ImmutableList
import java.util.List
import org.nanosite.xwarp.model.api.IBehavior
import org.nanosite.xwarp.model.api.IModel
import org.nanosite.xwarp.model.api.IResource

class WModel implements IModel {

	List<WResource> resources = newArrayList
	List<WConsumer> consumers = newArrayList
	List<WBehavior> initial = newArrayList 
	
	WResource waitResource = new WResource("wait" /*, false */)
	
	new() {
		// add wait resource
		resources.add(waitResource)
	}
	
	def boolean addResource(WResource res) {
		resources.add(res)
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

	override List<IResource> getResources() {
		ImmutableList.copyOf(resources)
	}

	override List<IBehavior> getInitial() {
		ImmutableList.copyOf(initial)
	}
	
}
