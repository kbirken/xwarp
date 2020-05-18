package org.nanosite.xwarp.simulation

import java.util.Deque
import org.nanosite.xwarp.model.WQueueConfig

class WMessageQueue implements IQueue {
	
	val Deque<WMessage> queue = newLinkedList
	val WQueueConfig.Limit limit
	var int highWatermark
	var int nOverflows
	
	new() {
		this(null)
	}
	
	new(WQueueConfig.Limit limit) {
		this.limit = limit
		this.highWatermark = 0
		this.nOverflows = 0
	}
	
	override isEmpty() {
		queue.empty
	}
	
	override push(WMessage message, long tCurrent) {
		if (limit===null || queue.size < limit.nMaxEntries) {
			queue.add(message)

			// record high-watermark statistics
			if (queue.size > highWatermark)
				highWatermark = queue.size
			return PushResult.OK			
		} else {
			// queue is full, handle situation according to policy
			nOverflows++
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
	
	def getHighWatermark() {
		highWatermark
	}
	
	def getNOverflows() {
		nOverflows
	}
}
