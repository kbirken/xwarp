package org.nanosite.xwarp.model

import java.util.Map

class WQueueConfig {
	enum Strategy { ONE_OF_EACH, FIRST_AVAILABLE }

	static class Limit {
		enum Policy {
			// discard incoming event if queue is full
			DISCARD_INCOMING,
			
			// discard oldest event if queue is full
			DISCARD_OLDEST,
			
			// always replace first event at the top of the queue and don't pop it
			SAMPLING,
			
			// always put new event at the top of the queue (stack behavior)
			LATEST_FIRST,
			
			// force end of simulation if queue is overloaded
			ABORT_SIMULATION
		}
		
		val public int nMaxEntries
		val public Policy policy
		
		new(int nMaxEntries, Policy policy) {
			this.nMaxEntries = nMaxEntries
			this.policy = policy
		}
	}

	
	val int nInstant
	val int nQueues
	val Strategy strategy
	val Map<Integer, Limit> limits
	
	public static val WQueueConfig STANDARD =
		new WQueueConfig(1, Strategy.FIRST_AVAILABLE)
  
	new(int nQueues, Strategy strategy) {
		this(0, nQueues, strategy, newHashMap)
	}
	
	new(Limit limit) {
		this(1, Strategy.FIRST_AVAILABLE, newHashMap(0 -> limit))
	}
	
	new(int nQueues, Strategy strategy, Map<Integer, Limit> limits) {
		this(0, nQueues, strategy, limits)
	}

	new(int nInstant, int nQueues, Strategy strategy) {
		this(nInstant, nQueues, strategy, newHashMap)
	}
		
	/**
	 * Construct a queue configuration object.
	 * 
	 * @param nInstant the number of inputs whose events are not queued
	 * @param nQueues the number of inputs with an event queue
	 * @param strategy the strategy for handling of incoming events  
	 * @param limits optional limit definitions for queues
	 */
	new(int nInstant, int nQueues, Strategy strategy, Map<Integer, Limit> limits) {
		this.nInstant = nInstant
		this.nQueues = nQueues
		this.strategy = strategy
		this.limits = limits
		
		for(idx : this.limits.keySet) {
			if (idx<0 || idx>=nQueues) {
				throw new RuntimeException("Invalid queue index (was: " + idx + ")")
			}
		} 
	}
	
	def int getNInstant() {
		nInstant
	}
	
	def int getNQueues() {
		nQueues
	}
	
	def Strategy getStrategy() {
		strategy
	}
	
	def Limit getLimit(int idxQueue) {
		if (limits.containsKey(idxQueue))
			limits.get(idxQueue)
		else
			null
	}
}
