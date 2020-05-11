package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

class BasicSequentialTests extends TestBase {

	@Test
	def void testSingleBehaviorOneStep() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior with only one step using 3 secs of CPU
				behavior("Bhvr1") => [
					add(step("S1", #{ cpu1->3000L }))
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
		result.check("Comp1::Bhvr1::S1", 0, 0, 3000)
	}
	
	@Test
	def void testSingleBehaviorTwoSteps() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(
						step("S1", #{ cpu1->2000L }),
						step("S2", #{ cpu1->3000L })
					)
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
		result.check("Bhvr1::S1", 0, 0, 2000)
		result.check("Bhvr1::S2", 2000, 2000, 5000)
	}
	
	@Test
	def void testSingleBehaviorSecondStepEmpty() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(
						step("S1", #{ cpu1->2000L }),
						step("S2", #{ })
					)
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
		result.check("Bhvr1::S1", 0, 0, 2000)
		result.check("Bhvr1::S2", 2000, 2000, 2000)
	}
	
}
