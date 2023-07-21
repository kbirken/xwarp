package org.nanosite.xwarp.simulation

interface IQueue {
	enum PushResult {
		OK,
		DISCARDED,
		DISCARDED_OLDEST,
		ABORT_SIMULATION
	}
	
	def boolean isEmpty()
	def PushResult push(WMessage message, long tCurrent)
	def WMessage pop()
}
