package org.nanosite.xwarp.tests

import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.model.TestModelBuilder
import org.nanosite.xwarp.result.SimResult
import org.nanosite.xwarp.simulation.WLogger
import org.nanosite.xwarp.simulation.WSimulator

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertFalse
import static org.junit.Assert.assertTrue
import static org.junit.Assert.assertNotNull

class TestBase {

	protected extension TestModelBuilder = new TestModelBuilder
	
	/**
	 * The timebase for warp is one microsecond, thus we define a millisec as 1000 microseconds.
	 */
	protected final int MS = 1000;

	def protected SimResult simulate(IModel model, int nStepsExpected, boolean dumpResult) {
		val logger = new WLogger(1)
		val simulator = new WSimulator(logger)
		val result = simulator.simulate(model)
		assertNotNull("Simulation didn't finish properly", result)
		assertEquals(nStepsExpected, result.stepInstances.size)
		if (dumpResult) {
			println("---")
			result.dump
		}
		println("-------------------------------------------")
		result
	}

	def protected check(
		SimResult result,
		String stepName,
		long tWaitingExpected,
		long tRunningExpected,
		long tDoneExpected
	) {
		check(result, stepName, 0,
			tWaitingExpected,
			tRunningExpected,
			tDoneExpected
		)
	}
	
	def protected check(
		SimResult result,
		String stepName,
		int instance,
		long tWaitingExpected,
		long tRunningExpected,
		long tDoneExpected
	) {
		// search for part of step name only
		val instances = result.stepInstances.filter[step.qualifiedName.contains(stepName)]
		assertFalse("Cannot find step result for name '" + stepName + "'", instances.empty)

		assertTrue("Cannot find instance " + instance + " for step for name '" + stepName + "'",
			instance < instances.size
		)
		
		val si = instances.get(instance)
		assertEquals(tWaitingExpected, si.waitingTime/MS)
		assertEquals(tRunningExpected, si.runningTime/MS)
		assertEquals(tDoneExpected, si.doneTime/MS)
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
	
	def protected checkCycles(
		SimResult result,
		String stepName,
		int instance,
		int nMissingCyclesExpected
	) {
		// search for part of step name only
		val instances = result.stepInstances.filter[step.qualifiedName.contains(stepName)]
		assertFalse("Cannot find step result for name '" + stepName + "'", instances.empty)

		assertTrue("Cannot find instance " + instance + " for step for name '" + stepName + "'",
			instance < instances.size
		)
		
		val si = instances.get(instance)
		assertEquals(nMissingCyclesExpected, si.NMissingCycles)		
	}
}
