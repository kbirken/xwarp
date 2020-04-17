package org.nanosite.xwarp.model

class WQueueConfig {
	enum Strategy { ONE_OF_EACH, FIRST_AVAILABLE }
	
	val int nInstant
	val int nQueues
	val Strategy strategy
	
	public final static val WQueueConfig STANDARD =
		new WQueueConfig(1, Strategy.FIRST_AVAILABLE)
  
	new(int nQueues, Strategy strategy) {
		this(0, nQueues, strategy)
	}
	
	/**
	 * Construct a queue configuration object.
	 * 
	 * @param nInstant the number of inputs whose events are not queued
	 * @param nQueues the number of inputs with an event queue
	 * @param strategy the strategy for handling of incoming events  
	 */
	new(int nInstant, int nQueues, Strategy strategy) {
		this.nInstant = nInstant
		this.nQueues = nQueues
		this.strategy = strategy
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
}
