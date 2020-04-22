package org.nanosite.xwarp.result

import org.nanosite.xwarp.model.IBehavior

class BehaviorInstance {

	val IBehavior behavior
	
	var long tStarted = 0L
	var long tReady = -1L
	var long tKilled = -1L
	
	new(IBehavior bhvr) {
		this.behavior = bhvr
	}
	
	def setStartedTime(long timestamp) {
		this.tStarted = timestamp
	}

	def setReadyTime(long timestamp) {
		this.tReady = timestamp
	}

	def setKilledTime(long timestamp) {
		this.tKilled = timestamp
	}

	def getBehavior() {
		this.behavior
	}
	
	def getStartedTime() {
		this.tStarted
	}
	
	def getReadyTime() {
		this.tReady
	}
	
	def wasKilled() {
		this.tKilled != -1
	}
	
	def getKilledTime() {
		this.tKilled
	}
	
	def void dump() {
		println(behavior.qualifiedName)

		println('''   «String.format("%09d", tStarted)» STARTED''')

		if (tReady != -1L)
			println('''   «String.format("%09d", tReady)» READY''')

		if (tKilled != -1L)
			println('''   «String.format("%09d", tKilled)» KILLED''')
	}

}
