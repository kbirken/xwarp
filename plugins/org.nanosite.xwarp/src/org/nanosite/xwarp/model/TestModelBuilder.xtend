package org.nanosite.xwarp.model

import com.google.common.collect.ArrayListMultimap
import com.google.common.collect.Multimap
import java.util.Map
import org.nanosite.xwarp.model.impl.WBehavior
import org.nanosite.xwarp.model.impl.WStep

class TestModelBuilder extends ModelBuilder {
	
	Map<String, IBehavior> behaviors = newHashMap
	Map<String, IStep> steps = newHashMap

	Multimap<String, WBehavior> tobeAddedAsSendTrigger = ArrayListMultimap.create
	Multimap<String, WStep> tobeAddedAsPrecondition = ArrayListMultimap.create
	
	override protected void justCreated(IBehavior behavior) {
		val key = behavior.name
		behaviors.put(key, behavior)
		
		// check if a trigger is waiting to be added
		if (tobeAddedAsSendTrigger.containsKey(key)) {
			for(sender : tobeAddedAsSendTrigger.get(key))
				send(sender, behavior)
			tobeAddedAsSendTrigger.removeAll(key)
		}
	}

	def send(IBehavior behavior, String triggeredBehavior) {
		if (behaviors.containsKey(triggeredBehavior)) {
			// triggered behavior has already been created
			behavior.send(behaviors.get(triggeredBehavior))
		} else {
			// triggered behavior will be created later
			if (behavior instanceof WBehavior)
				tobeAddedAsSendTrigger.put(triggeredBehavior, behavior) 
		}
	}

	override protected void justCreated(IStep step) {
		val key = step.name
		steps.put(key, step)
		
		// check if a precondition is waiting to be added
		if (tobeAddedAsPrecondition.containsKey(key)) {
			for(successor : tobeAddedAsPrecondition.get(key))
				precondition(successor, step)
			tobeAddedAsPrecondition.removeAll(key)
		}
	}

	def precondition(IStep step, String predecessor) {
		if (steps.containsKey(predecessor)) {
			// predecessor step has already been created
			step.precondition(steps.get(predecessor))
		} else {
			// predecessor step will be created later
			if (step instanceof WStep)
				tobeAddedAsPrecondition.put(predecessor, step) 
		}
	}

}
