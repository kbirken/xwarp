package org.nanosite.xwarp.tests

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertNotNull

import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.result.SimResult
import org.nanosite.xwarp.simulation.WLogger
import org.nanosite.xwarp.simulation.WSimulator

class TestBase {

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
		long tReadyExpected,
		long tRunningExpected,
		long tDoneExpected
	) {
		// search for part of step name only
		val si = result.stepInstances.findFirst[step.qualifiedName.contains(stepName)]
		assertNotNull("Cannot find step result for name '" + stepName + "'", si)
		
		assertEquals(tReadyExpected*MS, si.readyTime)
		assertEquals(tRunningExpected*MS, si.runningTime)
		assertEquals(tDoneExpected*MS, si.doneTime)
	}
}
