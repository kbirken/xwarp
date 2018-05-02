package org.nanosite.xwarp.result

import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.simulation.WIntAccuracy

class StepInstance {
	
	val IStep step
	
	var long tReady = 0L
	var long tRunning = 0L
	var long tDone = 0L
	
	new(IStep step) {
		this.step = step
	}
	
	def setReadyTime(long timestamp) {
		this.tReady = WIntAccuracy.toPrint(timestamp)
	}
	
	def setRunningTime(long timestamp) {
		this.tRunning = WIntAccuracy.toPrint(timestamp)
	}
	
	def setDoneTime(long timestamp) {
		this.tDone = WIntAccuracy.toPrint(timestamp)
	}
	
	def getStep() {
		step
	}

	def getReadyTime() {
		tReady
	}
	
	def getRunningTime() {
		tRunning
	}
	
	def getDoneTime() {
		tDone
	}
	
	def void dump() {
		println(step.qualifiedName)
		println('''   «String.format("%09d", tReady)» READY''')
		println('''   «String.format("%09d", tRunning)» RUNNING''')
		println('''   «String.format("%09d", tDone)» DONE''')
	}
}
