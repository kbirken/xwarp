package org.nanosite.xwarp.model.impl

import com.google.common.collect.ImmutableList
import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.IAllocatingConsumable
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IConsumer
import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.model.IScheduledConsumable
import org.nanosite.xwarp.model.ITrigger

class WModel implements IModel {

	List<IScheduledConsumable> scheduledConsumables = newArrayList
	List<IAllocatingConsumable> allocatingConsumables = newArrayList

	List<WConsumer> consumers = newArrayList
	List<WTrigger> initial = newArrayList 
	
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

	def boolean addInitial(WTrigger trigger) {
		initial.add(trigger)
		true
	}

	@Deprecated
	def boolean addInitial(WBehavior behavior) {
		initial.add(new WTrigger(behavior, 0))
		true
	}

	def void finishInitialisation() {
		consumers.forEach[finishInitialisation]
		checkForCycles()
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

	override List<ITrigger> getInitial() {
		if (! initialized)
			finishInitialisation
		ImmutableList.copyOf(initial)
	}

	override List<IConsumer> getConsumers() {
		if (! initialized)
			finishInitialisation
		ImmutableList.copyOf(consumers)
	}
	
	// we are using DFS for cycle detection
	enum Color { WHITE, GRAY, BLACK}
	
	def private checkForCycles() {
		// initialize
		val Map<IBehavior, Color> color = newHashMap
		val allBehaviors = consumers.map[behaviors].flatten
		allBehaviors.forEach[color.put(it, Color.WHITE)]
		
		// start depth-first traversal for all behaviors which are candidates
		for(bhvr : allBehaviors.filter[executesInZeroTime]) {
			checkCycleRec(bhvr, color)
		}
		
		// set flag for all behaviors which are part of infinite loop
		for(bhvr : allBehaviors.filter[color.get(it)==Color.GRAY]) {
			//println("in cycle: " + bhvr.qualifiedName)
			(bhvr as WBehavior).setNoProgressLoop
		}
	}
	
	def private boolean checkCycleRec(IBehavior bhvr, Map<IBehavior, Color> color) {
		// mark as being processed
		color.put(bhvr, Color.GRAY)
		
		// iterate over triggers
		for (b : bhvr.sendTriggers.map[behavior].filter[executesInZeroTime]) {
			val col = color.get(b)
			if (col == Color.GRAY) {
				// this is a cycle
				return true
			}
				
			if (col == Color.WHITE) {
				if (checkCycleRec(b, color)) {
					return true
				}
			}
		}
		
		// mark as processed
		color.put(bhvr, Color.BLACK)
		false
	}
}
