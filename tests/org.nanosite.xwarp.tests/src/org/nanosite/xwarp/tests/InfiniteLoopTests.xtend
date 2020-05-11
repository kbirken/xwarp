package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

class InfiniteLoopTests extends TestBase {

	@Test
	def void testInfiniteLoopWithWaitSteps() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(step("S1", 20L))
					send("Bhvr2")
				],
				behavior("Bhvr2") => [
					add(step("S1", 30L))
					send("Bhvr1")
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
		val result = simulate(model, 100, false)
		result.check("Bhvr2::S1", 49, 2470, 2470, 2500)
	}

	@Test
	def void testInfiniteLoopWithEmptySteps() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(step("S1", 0L))
					send("Bhvr2")
				],
				behavior("Bhvr2") => [
					add(step("S1", 0L))
					send("Bhvr1")
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
		val result = simulate(model, 2, 1, false)
		result.check("Bhvr1::S1", 0, 0, 0)
		result.check("Bhvr2::S1", 0, 0, 0)
	}

	@Test
	def void testInfiniteLoopWithoutSteps() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					send("Bhvr2")
				],
				behavior("Bhvr2") => [
					send("Bhvr1")
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
		val result = simulate(model, 0, 1, false)
	}

}
