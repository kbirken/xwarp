package org.nanosite.xwarp.simulation

import java.util.Queue

class WMessageQueue implements IQueue {
	
	val Queue<WMessage> queue = newLinkedList
	
	override isEmpty() {
		queue.empty
	}
	
	override push(WMessage message, long tCurrent) {
		queue.add(message)
	}
	
	override pop() {
		queue.poll
	}
}
