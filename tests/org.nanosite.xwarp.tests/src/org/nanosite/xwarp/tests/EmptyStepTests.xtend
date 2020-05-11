package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

class EmptyStepTests extends TestBase {

	@Test
	def void testEmptyBehavior() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior without a step
				behavior("Bhvr1") => [
					send("Bhvr2")
				],
				behavior("Bhvr2") => [
					add(step("S1", 100L))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 1, false)
		result.check("Comp1::Bhvr2::S1", 0, 0, 100)
	}
	
	@Test
	def void testZeroWaitStep() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior without a step
				behavior("Bhvr1") => [
					add(step("S1", 0L))
					send("Bhvr2")
				],
				behavior("Bhvr2") => [
					add(step("S1", 100L))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 2, false)
		result.check("Comp1::Bhvr1::S1", 0, 0, 0)
		result.check("Comp1::Bhvr2::S1", 0, 0, 100)
	}
	
}
