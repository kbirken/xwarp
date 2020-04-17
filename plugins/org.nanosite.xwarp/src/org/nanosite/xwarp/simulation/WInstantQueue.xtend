package org.nanosite.xwarp.simulation

class WInstantQueue implements IQueue {
	var WMessage item = null
	
	override isEmpty() {
		item===null
	}
	
	override push(WMessage message) {
		item = message
	}
	
	override pop() {
		val msg = item
		item = null
		msg
	}
	
	override clear() {
		item = null
	}
}
