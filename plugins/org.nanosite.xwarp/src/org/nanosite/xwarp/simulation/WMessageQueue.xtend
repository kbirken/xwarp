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
			if (isStack)
				queue.addFirst(message)
			else
				queue.add(message)
			
			// record high-watermark statistics
			if (queue.size > statistics.highWatermark)
				statistics.highWatermark = queue.size
			return PushResult.OK			
		} else {
			// queue is full, handle situation according to policy
			if (! isSampling)
				statistics.nOverflows++
			switch (limit.policy) {
				case DISCARD_INCOMING:
					// just don't add new message into queue
					return PushResult.DISCARDED
				case SAMPLING: {
					// ensure that there is always at most one entry in the queue
					queue.clear
					queue.add(message)
					return PushResult.OK
				}
				case LATEST_FIRST: {
						// a new message at the beginning, this will throw away one older message
						if (queue.size > 1)
							queue.removeLast
						return PushResult.DISCARDED_OLDEST
					}
				case ABORT_SIMULATION:
					return PushResult.ABORT_SIMULATION
				default:
					throw new RuntimeException("Internal error: Invalid limit policy (was: " + limit.policy + ")")
			}
		}		
	}
	
	override pop() {
		if (isSampling) {
			// in SAMPLING mode, we keep the event from the queue
			queue.peek
		} else {
			// "normal" queue: remove the event from the queue
			queue.poll		
		}
	}
	
	def private isSampling() {
		limit!==null && limit.policy==WQueueConfig.Limit.Policy.SAMPLING
	}
	
	def private isStack() {
		limit!==null && limit.policy==WQueueConfig.Limit.Policy.LATEST_FIRST
	}
	
	def getStatistics() {
		statistics
	}	
}
