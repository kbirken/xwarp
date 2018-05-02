package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.result.SimResult
import org.nanosite.xwarp.simulation.WLogger
import org.nanosite.xwarp.simulation.WSimulator

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertNotNull

import static extension org.nanosite.xwarp.model.ModelBuilder.*

class BasicTests {
	/**
	 * The timebase for warp is one microsecond, thus we define a millisec as 1000 microseconds.
	 */
	protected final int MS = 1000;

	@Test
	def void test01() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Component1") => [
			add(
				behavior("Behavior1") => [
					add(step("Step1", #{ cpu1->100L }))
					add(step("Step2", #{ cpu1->500L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and start simulation
		val result = simulate(model, 2, false)
		result.check("Behavior1::Step1", 0, 0, 100)
		result.check("Behavior1::Step2", 100, 100, 600)
	}
	
	@Test
	def void test02() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Component1") => [
			add(
				behavior("C1B1") => [
					add(step("C1B1S1", #{ cpu1->100L }))
				]
			)
		]
		val consumer2 = consumer("Component2") => [
			add(
				behavior("C2B1") => [
					add(step("C2B1S1", #{ cpu1->100L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			add(consumer2)
			addInitial(consumer1.behaviors.head)
			addInitial(consumer2.behaviors.head)
		]
		
		// create simulator and start simulation
		val result = simulate(model, 2, true)
		result.check("C1B1S1", 0, 0, 200)
		result.check("C2B1S1", 0, 0, 200)
	}
	
	def private SimResult simulate(IModel model, int nStepsExpected, boolean dumpResult) {
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

	def private check(
		SimResult result,
		String stepName,
		long tReadyExpected,
		long tRunningExpected,
		long tDoneExpected
	) {
		// search for part of step name only
		val si = result.stepInstances.findFirst[step.qualifiedName.contains(stepName)]
		assertNotNull(si)
		
		assertEquals(tReadyExpected*MS, si.readyTime)
		assertEquals(tRunningExpected*MS, si.runningTime)
		assertEquals(tDoneExpected*MS, si.doneTime)
	}
}
