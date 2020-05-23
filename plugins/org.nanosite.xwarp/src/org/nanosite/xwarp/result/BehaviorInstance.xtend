package org.nanosite.xwarp.result

import java.util.List
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.simulation.WMessageQueue

class BehaviorInstance {

	val IBehavior behavior
	
	var long tStarted = 0L
	var long tReady = -1L
	var long tKilled = -1L
	
	var List<WMessageQueue.Statistics> queueStatistics = null
	
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
	
	def setQueueStatistics(List<WMessageQueue.Statistics> statistics) {
		this.queueStatistics = statistics
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
	
	def getQueueStatistics(int idxQueue) {
		if (idxQueue>=0 && idxQueue<queueStatistics.size)
			queueStatistics.get(idxQueue)
		else
			null
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
