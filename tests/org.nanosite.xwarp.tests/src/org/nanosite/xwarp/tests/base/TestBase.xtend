package org.nanosite.xwarp.tests.base

import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.model.TestModelBuilder
import org.nanosite.xwarp.result.ISimResult
import org.nanosite.xwarp.simulation.WLogger
import org.nanosite.xwarp.simulation.WSimulator

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertFalse
import static org.junit.Assert.assertTrue
import static org.junit.Assert.assertNotNull
import org.nanosite.xwarp.model.IBehavior

class TestBase {

	protected extension TestModelBuilder = new TestModelBuilder
	
	/**
	 * The timebase for warp is one microsecond, thus we define a millisec as 1000 microseconds.
	 */
	protected final int MS = 1000;

	def ISimConfig maxIterations(int n) {
		new SetMaxIterations(n)
	}
	
	/** Time limit is given in milliseconds (as all other numbers in the test). */
	def ISimConfig timeLimit(long tl) {
		new SetTimeLimit(tl * MS)
	}
	
	def protected ISimResult simulate(
		IModel model,
		int nStepsExpected,
		boolean dumpResult
	) {
		simulate(model, nStepsExpected, 0, dumpResult)		
	}
	
	def protected ISimResult simulate(
		IModel model,
		ISimConfig[] config,
		int nStepsExpected,
		boolean dumpResult
	) {
		simulate(model, config, nStepsExpected, 0, dumpResult)		
	}
	
	def protected ISimResult simulate(
		IModel model,
		int nStepsExpected,
		int nKilledBehaviors,
		boolean dumpResult
	) {
		simulate(model, newArrayList(), nStepsExpected, nKilledBehaviors, dumpResult)
	}
	
	def protected ISimResult simulate(
		IModel model,
		ISimConfig[] config,
		int nStepsExpected,
		int nKilledBehaviors,
		boolean dumpResult
	) {
		// create simulator and configure it
		val logger = new WLogger(2)
		val simulator = new WSimulator(logger) => [ NMaxIterations = 99 ]
		for(cfg : config) {
			cfg.applyTo(simulator)			
		}
		
		// run simulation and check results
		val result = simulator.simulate(model)
		assertNotNull("Simulation didn't finish properly", result)
		assertEquals(nStepsExpected, result.stepInstances.filter[it.step!==null].size)
		assertEquals(nKilledBehaviors, result.killedBehaviorInstances.size)
		if (dumpResult) {
			println("---")
			result.dump
		}
		println("-------------------------------------------")
		result
	}

	def protected check(
		ISimResult result,
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
		ISimResult result,
		String stepName,
		int instance,
		long tWaitingExpected,
		long tRunningExpected,
		long tDoneExpected
	) {
		// search for part of step name only
		val instances = result.stepInstances.filter[qualifiedName.contains(stepName)]
		assertFalse("Cannot find step result for name '" + stepName + "'", instances.empty)

		assertTrue("Cannot find instance " + instance + " for step for name '" + stepName + "'",
			instance < instances.size
		)
		
		val si = instances.get(instance)
		assertEquals(tWaitingExpected, si.waitingTime/MS)
		assertEquals(tRunningExpected, si.runningTime/MS)
		assertEquals(tDoneExpected, si.doneTime/MS)
	}

	def protected checkMaxIterations(ISimResult result, boolean expected) {
		assertEquals(expected, result.reachedMaxIterations)
	}

	def protected checkTimeLimit(ISimResult result, boolean expected) {
		assertEquals(expected, result.reachedTimeLimit)
	}
	
	def protected checkQueueAbort(ISimResult result, String expectedBehavior, int expectedInputIndex) {
		val qoa = result.queueOverflowAbort
		assertNotNull(qoa)
		assertEquals(expectedBehavior, qoa.behavior.qualifiedName)
		assertEquals(expectedInputIndex, qoa.inputIndex)
	}
	
	def protected checkQueueStatistics(
		ISimResult result,
		IBehavior bhvr,
		int indexQueue,
		int highWatermarkExpected,
		int nOverflowsExpected
	) {
		val candidates = result.behaviorInstances.filter[it.behavior==bhvr]
		assertFalse("Cannot find behavior instance", candidates.empty)
		val bi = candidates.last
		val stat = bi.getQueueStatistics(indexQueue)
		assertEquals(highWatermarkExpected, stat.highWatermark)
		assertEquals(nOverflowsExpected, stat.nOverflows)
	}

	def protected checkPool(
		ISimResult result,
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
		ISimResult result,
		String stepName,
		String poolName,
		long allocatedExpected,
		boolean overflowExpected,
		boolean underflowExpected
	) {
		// search for part of step name only
		val si = result.stepInstances.findFirst[qualifiedName.contains(stepName)]
		assertNotNull("Cannot find step result for name '" + stepName + "'", si)
		
		assertEquals(allocatedExpected, si.getPoolUsage(poolName))
		assertEquals(overflowExpected, si.getPoolOverflow(poolName))
		assertEquals(underflowExpected, si.getPoolUnderflow(poolName))
	}
	
	def protected checkCycles(
		ISimResult result,
		String stepName,
		int instance,
		int nMissingCyclesExpected
	) {
		// search for part of step name only
		val instances = result.stepInstances.filter[qualifiedName.contains(stepName)]
		assertFalse("Cannot find step result for name '" + stepName + "'", instances.empty)

		assertTrue("Cannot find instance " + instance + " for step for name '" + stepName + "'",
			instance < instances.size
		)
		
		val si = instances.get(instance)
		assertEquals(nMissingCyclesExpected, si.NMissingCycles)		
	}
}
