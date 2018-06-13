package org.nanosite.xwarp.simulation

import org.nanosite.xwarp.model.IPool

class WPoolState {

	val IPool pool
	val ILogger logger
	
	var long allocated = 0
	var int nOverflows = 0
	var int nUnderflows = 0
	 
	new (IPool pool, ILogger logger) {
		this.pool = pool
		this.logger = logger
	}
	
	def IPool getPool() {
		pool
	}
	
	def long getAllocated() {
		allocated
	}
	
	def int getNOverflows() {
		nOverflows
	}

	def int getNUnderflows() {
		nUnderflows
	}

	def void handleRequest(long amount) {
	if (isStopped()) {
		// pool is stopped due to previous overflow/underflow
		log(1, "stopped, ignoring request " + amount)
	} else {
		// pool is working, try to allocate
		if (mayAlloc(amount)) {
			// allocation in range, do it
			alloc(amount)
			log(2, "request " + amount + ", now " + allocated)
		} else {
			// overflow or underflow
			if (allocated+amount < 0) {
				handleUnderflow(amount)
				log(1, "underflow " + amount + ", now " + allocated)
			} else {
				handleOverflow(amount)
				log(1, "overflow " + amount + ", now " + allocated)
			}
		}
	}
}


	def private boolean isStopped() {
		if (nOverflows>0 && pool.onOverflow==IPool.ErrorAction.STOP_WORKING) {
			true
		} else if (nUnderflows>0 && pool.onUnderflow==IPool.ErrorAction.STOP_WORKING) {
			true
		} else
			false
	}

	def private boolean mayAlloc(long amount) {
		if (allocated+amount > pool.maxAmount) {
			// overflow
			return false
		}

		if (allocated+amount < 0) {
			// underflow
			return false
		}

		true
	}


	def private void handleOverflow(long amount) {
		nOverflows++
		if (pool.onOverflow==IPool.ErrorAction.EXECUTE_AND_CONTINUE) {
			alloc(amount)
		}
	}
	
	def private void handleUnderflow(long amount) {
		nUnderflows++
		if (pool.onUnderflow==IPool.ErrorAction.EXECUTE_AND_CONTINUE) {
			alloc(amount)
		}
	}
	
	def private void alloc(long amount) {
		allocated += amount
	}

	def private void log(int level, String action) {
		logger.log(
			level,
			ILogger.Type.POOL,
			'''«pool.name»: «action»'''
		)
	}


}
