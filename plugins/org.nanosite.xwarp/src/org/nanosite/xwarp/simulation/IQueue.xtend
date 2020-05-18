package org.nanosite.xwarp.simulation

interface IQueue {
	public enum PushResult {
		OK,
		DISCARDED,
		DISCARDED_PREVIOUS,
		ABORT_SIMULATION
	}
	
	def boolean isEmpty()
	def PushResult push(WMessage message, long tCurrent)
	def WMessage pop()
}
