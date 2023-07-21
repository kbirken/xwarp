package org.nanosite.xwarp.simulation

import org.nanosite.xwarp.model.IBehavior

interface IScheduler {
	
	/**
	 * This exception will be triggered by some behavior
	 * in order to abort the whole simulation if a queue is full.
	 */
	static class QueueAbortException extends RuntimeException {
		public val IBehavior behavior
		public val int inputIndex
		
		new (IBehavior behavior, int inputIndex) {
			super("queue overflow at " + behavior.qualifiedName + "#" + inputIndex)
			this.behavior = behavior
			this.inputIndex = inputIndex
		}
	}

	def void createWaitingJob(IJob job)
	def void activateJob(IJob job)
	
	def long getCurrentTime()
}
