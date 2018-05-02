package org.nanosite.xwarp.model.impl

import com.google.common.collect.ImmutableList
import java.util.List
import org.nanosite.xwarp.model.IConsumer

class WConsumer extends WNamedElement implements IConsumer {
	
	List<WBehavior> behaviors = newArrayList
	
	new(String name) {
		super(name)
	}
	
	def boolean addBehavior(WBehavior behavior) {
		behavior.owner = this
		behaviors.add(behavior)
		true
	}
	
	override getBehaviors() { ImmutableList.copyOf(behaviors) }
	
}
