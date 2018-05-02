package org.nanosite.xwarp.simulation

import java.util.Queue

class WMessageQueue {
	
	val Queue<WMessage> queue = newLinkedList
	
	def isEmpty() {
		queue.empty
	}
	
	def push(WMessage message) {
		queue.add(message)
	}
	
	def pop() {
		queue.poll
	}
}
