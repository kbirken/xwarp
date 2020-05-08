package org.nanosite.xwarp.result

import java.util.Collection
import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IPool
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.simulation.WIntAccuracy

class StepInstance {
	
	val IBehavior behavior
	val IStep step
	
	var long tWaiting = -1L
	var long tReady = 0L
	var long tRunning = 0L
	var long tDone = 0L
	
	static public class Predecessor {
		public enum Type {
			// sequential execution of steps in a behavior
			SEQUENTIAL,
			
			// next loop iteration in a looped behavior
			LOOP,
			
			// behavior has just finished and the next trigger is already waiting 
			FOLLOWUP,

			// one behavior triggers another (or itself)
			TRIGGER,

			// repeating a behavior stops because of an unless condition 
			// (this is not actually a linear dependency)
			UNLESS_CONDITION
		}
		val public StepInstance stepInstance
		val public Type type
		
		new(StepInstance stepInstance, Type type) {
			this.stepInstance = stepInstance
			this.type = type
		}
	}
	
	val List<Predecessor> predecessors = newArrayList
	
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

	var int nMissingCycles = 0
	
	/**
	 * Construct a step instance for a IStep (normal case). 
	 */
	new(IStep step) {
		this.behavior = null
		this.step = step
	}
	
	/**
	 * Construct a step instance for a behavior without any steps.
	 */
	new(IBehavior behavior) {
		this.behavior = behavior
		this.step = null
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
	
	def addPredecessor(StepInstance pred, Predecessor.Type type) {
		predecessors.add(new Predecessor(pred, type))
	}
	
	def void addPoolState(IPool pool, long amount, boolean overflow, boolean underflow) {
		val ps = new PoolState(amount, overflow, underflow)
		poolStates.put(pool.name, ps)
	}
	
	def void setNMissingCycles(int nMissingCycles) {
		this.nMissingCycles = nMissingCycles
	}

	def String getQualifiedName() {
		if (step===null)
			behavior.qualifiedName
		else
			step.qualifiedName
	}

	def getBehavior() {
		behavior
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
	
	def Collection<Predecessor> getPredecessors() {
		predecessors
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
	
	def int getNMissingCycles() {
		nMissingCycles
	}
	
	def void dump() {
		println(this.qualifiedName)

		if (tWaiting!=-1L && tWaiting!=tReady)
			println('''   «String.format("%09d", tWaiting)» WAITING''')

		if (tRunning!=tReady)
			println('''   «String.format("%09d", tReady)» READY''')

		println('''   «String.format("%09d", tRunning)» RUNNING''')

		println('''   «String.format("%09d", tDone)» DONE''')
		
		for(pool : poolStates.keySet) {
			val ps = poolStates.get(pool)
			println('''   pool state '«pool»': «ps.amount»«IF ps.overflow» overflow!«ENDIF»«IF ps.underflow» underflow!«ENDIF»''')
		}
	}
	
	override String toString() {
		'''«qualifiedName»#«tReady»/«tRunning»/«tDone»'''
	}
}
