package org.nanosite.xwarp.simulation

class WInstantQueue implements IQueue {
	var WMessage item = null
	var long tItem = 0L
	
	override isEmpty() {
		item===null
	}
	
	override push(WMessage message, long tCurrent) {
		item = message
		tItem = tCurrent
	}
	
	override pop() {
		val msg = item
		item = null
		msg
	}
	
	def clear(long tCurrent) {
		if (item!==null && tItem<tCurrent)
			item = null
	}
}
