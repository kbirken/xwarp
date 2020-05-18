package org.nanosite.xwarp.simulation

import java.util.List
import org.nanosite.xwarp.model.WQueueConfig

class WMultiQueue {
	val int nInstant
	val WQueueConfig.Strategy strategy

	val List<IQueue> queues = newArrayList	
	
	new(WQueueConfig config) {
		this.nInstant = config.NInstant
		this.strategy = config.strategy
		
		if (config.NInstant>0)
			for(i : 1..config.NInstant)
				queues.add(new WInstantQueue)
		if (config.NQueues>0)
			for(i : 1..config.NQueues)
				queues.add(new WMessageQueue)
	}
	
	def void push(int idx, WMessage msg, long tCurrent) {
		flushInstants(tCurrent)
		if (idx >= queues.size) {
			throw new RuntimeException(
				"Invalid queue index " + idx + ", #queues=" + queues.size
			)
		}
		queues.get(idx).push(msg, tCurrent)
	}
	
	def boolean mayPop() {
		switch (strategy) {
			case ONE_OF_EACH: {
				queues.forall[!empty]
			}
			case FIRST_AVAILABLE: {
				queues.exists[!empty]
			}
			default:
				throw new RuntimeException("Invalid strategy")
		}
	}
	
	def List<WMessage> pop() {
		val result = newArrayList
		switch (strategy) {
			case ONE_OF_EACH: {
				queues.forall[
					result.add(pop)
				]
			}
			case FIRST_AVAILABLE: {
				val msg = queues.findFirst[!empty].pop
				result.add(msg)
			}
			default:
				throw new RuntimeException("Invalid strategy")
		}
		
		flushInstants(Long.MAX_VALUE)
		
		result
	}
	
	def private flushInstants(long tCurrent) {
		// filter() is used instead of a cast 
		val instantQueues = queues.subList(0, nInstant).filter(WInstantQueue)

		// reset all instant inputs which are older than tCurrent
		instantQueues.forEach[clear(tCurrent)]
	}
}
