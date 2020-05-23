package org.nanosite.xwarp.simulation

import java.util.Deque
import org.nanosite.xwarp.model.WQueueConfig

class WMessageQueue implements IQueue {
	
	val Deque<WMessage> queue = newLinkedList
	val WQueueConfig.Limit limit
	
	public static class Statistics implements Cloneable {
		public int highWatermark = 0
		public int nOverflows = 0
		def copy() { this.clone as Statistics}
	}
	val Statistics statistics
	
	new() {
		this(null)
	}
	
	new(WQueueConfig.Limit limit) {
		this.limit = limit
		this.statistics = new Statistics
	}
	
	override isEmpty() {
		queue.empty
	}
	
	override push(WMessage message, long tCurrent) {
		if (limit===null || queue.size < limit.nMaxEntries) {
			queue.add(message)

			// record high-watermark statistics
			if (queue.size > statistics.highWatermark)
				statistics.highWatermark = queue.size
			return PushResult.OK			
		} else {
			// queue is full, handle situation according to policy
			statistics.nOverflows++
			switch (limit.policy) {
				case DISCARD_INCOMING:
					// just don't add new message into queue
					return PushResult.DISCARDED
				case LATEST_FIRST: {
						// add new message at the beginning, this will throw away one older message
						queue.addFirst(message)
						return PushResult.DISCARDED_PREVIOUS
					}
				case ABORT_SIMULATION:
					return PushResult.ABORT_SIMULATION
				default:
					throw new RuntimeException("Internal error: Invalid limit policy (was: " + limit.policy + ")")
			}
		}		
	}
	
	override pop() {
		queue.poll
	}
	
	def getStatistics() {
		statistics
	}	
}
