package org.nanosite.xwarp.model

import com.google.common.collect.ArrayListMultimap
import com.google.common.collect.Multimap
import java.util.Map
import org.nanosite.xwarp.model.impl.WBehavior

class TestModelBuilder extends ModelBuilder {
	
	Map<String, IBehavior> behaviors = newHashMap

	Multimap<String, WBehavior> tobeAdded = ArrayListMultimap.create
	
	override protected void justCreated(IBehavior behavior) {
		val key = behavior.name
		behaviors.put(key, behavior)
		
		// check if a trigger is waiting to be added
		if (tobeAdded.containsKey(key)) {
			for(sender : tobeAdded.get(key))
				send(sender, behavior)
		}
	}

	def send(IBehavior behavior, String triggeredBehavior) {
		if (behaviors.containsKey(triggeredBehavior)) {
			// triggered behavior has already been created
			behavior.send(behaviors.get(triggeredBehavior))
		} else {
			// triggered behavior will be created later
			if (behavior instanceof WBehavior)
				tobeAdded.put(triggeredBehavior, behavior) 
		}
	}
}
