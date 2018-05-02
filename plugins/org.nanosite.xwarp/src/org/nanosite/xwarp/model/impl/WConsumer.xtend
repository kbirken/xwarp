package org.nanosite.xwarp.model.impl

import com.google.common.collect.ImmutableList
import java.util.List

class WConsumer extends WNamedElement {
	
	List<WBehavior> behaviors = newArrayList
	
	new(String name) {
		super(name)
	}
	
	def boolean addBehavior(WBehavior behavior) {
		behavior.owner = this
		behaviors.add(behavior)
		true
	}
	
	def getBehaviors() { ImmutableList.copyOf(behaviors) }
	
}
