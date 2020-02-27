package org.nanosite.xwarp.simulation

import java.util.List
import org.nanosite.xwarp.model.WQueueConfig

class WMultiQueue {
	val List<WMessageQueue> queues = newArrayList
	
	val WQueueConfig.Strategy strategy
	
	new(WQueueConfig config) {
		for(i : 1..config.NQueues)
			queues.add(new WMessageQueue)
		this.strategy = config.strategy
	}
	
	def void push(int idx, WMessage msg) {
		if (idx>=queues.size) {
			throw new RuntimeException(
				"Invalid queue index " + idx + ", #queues=" + queues.size
			)
		}
		queues.get(idx).push(msg)
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
		result
	}
}
