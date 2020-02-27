package org.nanosite.xwarp.model

class WQueueConfig {
	enum Strategy { ONE_OF_EACH, FIRST_AVAILABLE }
	
	val int nQueues
	val Strategy strategy
	
	public final static val WQueueConfig STANDARD =
		new WQueueConfig(1, Strategy.FIRST_AVAILABLE)
  
	new(int nQueues, Strategy strategy) {
		this.nQueues = nQueues
		this.strategy = strategy
	}
	
	def int getNQueues() {
		nQueues
	}
	
	def Strategy getStrategy() {
		strategy
	}
}
