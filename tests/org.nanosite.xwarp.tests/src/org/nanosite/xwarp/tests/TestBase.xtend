package org.nanosite.xwarp.tests

import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.model.IPool
import org.nanosite.xwarp.model.TestModelBuilder
import org.nanosite.xwarp.result.SimResult
import org.nanosite.xwarp.simulation.WLogger
import org.nanosite.xwarp.simulation.WSimulator

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertNotNull

class TestBase {

	protected extension TestModelBuilder = new TestModelBuilder
	
	/**
	 * The timebase for warp is one microsecond, thus we define a millisec as 1000 microseconds.
	 */
	protected final int MS = 1000;

	def protected SimResult simulate(IModel model, int nStepsExpected, boolean dumpResult) {
		val logger = new WLogger(4)
		val simulator = new WSimulator(logger)
		val result = simulator.simulate(model)
		assertEquals(nStepsExpected, result.stepInstances.size)
		if (dumpResult) {
			println("---")
			result.dump
		}
		result
	}

	def protected check(
		SimResult result,
		String stepName,
		long tWaitingExpected,
		long tRunningExpected,
		long tDoneExpected
	) {
		// search for part of step name only
		val si = result.stepInstances.findFirst[step.qualifiedName.contains(stepName)]
		assertNotNull("Cannot find step result for name '" + stepName + "'", si)
		
		assertEquals(tWaitingExpected*MS, si.waitingTime)
		assertEquals(tRunningExpected*MS, si.runningTime)
		assertEquals(tDoneExpected*MS, si.doneTime)
	}

	def protected checkPool(
		SimResult result,
		String poolName,
		long allocatedExpected,
		int nOverflowsExpected,
		int nUnderflowsExpected
	) {
		// search for part of pool name only
		val pool = result.poolStates.findFirst[pool.name.contains(poolName)]
		assertNotNull("Cannot find pool state for name '" + poolName + "'", pool)

		assertEquals(allocatedExpected, pool.allocated)
		assertEquals(nOverflowsExpected, pool.NOverflows)
		assertEquals(nUnderflowsExpected, pool.NUnderflows)
	}

	def protected checkPool(
		SimResult result,
		String stepName,
		String poolName,
		long allocatedExpected,
		boolean overflowExpected,
		boolean underflowExpected
	) {
		// search for part of step name only
		val si = result.stepInstances.findFirst[step.qualifiedName.contains(stepName)]
		assertNotNull("Cannot find step result for name '" + stepName + "'", si)
		
		assertEquals(allocatedExpected, si.getPoolUsage(poolName))
		assertEquals(overflowExpected, si.getPoolOverflow(poolName))
		assertEquals(underflowExpected, si.getPoolUnderflow(poolName))
	}
}
