package org.nanosite.xwarp.result

import java.util.Map
import org.nanosite.xwarp.model.IPool
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.simulation.WIntAccuracy

class StepInstance {
	
	val IStep step
	
	var long tWaiting = -1L
	var long tReady = 0L
	var long tRunning = 0L
	var long tDone = 0L
	
	static private class PoolState {
		val public long amount
		val public boolean overflow
		val public boolean underflow
		
		new(long amount, boolean overflow, boolean underflow) {
			this.amount = amount
			this.overflow = overflow
			this.underflow = underflow
		}
	}
	
	val Map<String, PoolState> poolStates = newHashMap
	
	new(IStep step) {
		this.step = step
	}
	
	def setWaitingTime(long timestamp) {
		this.tWaiting = WIntAccuracy.toPrint(timestamp)
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
	
	def void addPoolState(IPool pool, long amount, boolean overflow, boolean underflow) {
		val ps = new PoolState(amount, overflow, underflow)
		poolStates.put(pool.name, ps)
	}
	
	def getStep() {
		step
	}

	def getWaitingTime() {
		if (tWaiting==-1L) tReady else tWaiting
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
	
	def long getPoolUsage(String poolName) {
		val ps = poolStates.get(poolName)
		if (ps===null) {
			0
		} else {
			ps.amount
		}
	}
	
	def boolean getPoolOverflow(String poolName) {
		val ps = poolStates.get(poolName)
		if (ps===null) {
			false
		} else {
			ps.overflow
		}
	}
	
	def boolean getPoolUnderflow(String poolName) {
		val ps = poolStates.get(poolName)
		if (ps===null) {
			false
		} else {
			ps.underflow
		}
	}
	
	def void dump() {
		println(step.qualifiedName)

		if (tWaiting!=-1L && tWaiting!=tReady)
			println('''   «String.format("%09d", tWaiting)» WAITING''')

		if (tRunning!=tReady)
			println('''   «String.format("%09d", tReady)» READY''')

		println('''   «String.format("%09d", tRunning)» RUNNING''')

		println('''   «String.format("%09d", tDone)» DONE''')
	}
}
