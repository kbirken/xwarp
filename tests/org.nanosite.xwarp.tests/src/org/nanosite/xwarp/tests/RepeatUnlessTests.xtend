package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

class RepeatUnlessTests extends TestBase {

	@Test
	def void testRepeatUnless1() {
		// create hardware model
		val cpu1 = processor("CPU1")
		val cpu2 = processor("CPU2")

		// create software model
		val consumer1 = consumer("Component1") => [
			add(
				behavior("B1") => [
					add(
						step("B1S1", #{ cpu1->1000L }),
						step("B1S2", #{ cpu1->1000L })
					)
				],
				behavior("B2") => [
					repeatUnless("B1S1")
					add(
						step("LOOP", #{ cpu2->250L })
					)
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1, cpu2)
			add(consumer1)
			addInitial(
				consumer1.behaviors.get(0),
				consumer1.behaviors.get(1)
			)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 6, false)
		result.check("B1S1", 0, 0, 1000)
		result.check("B1S2", 1000, 1000, 2000)
		result.check("LOOP", 0,   0,   0, 250)
		result.check("LOOP", 1, 250, 250, 500)
		result.check("LOOP", 2, 500, 500, 750)
		result.check("LOOP", 3, 750, 750, 1000)
	}
		
	@Test
	def void testRepeatUnless2() {
		// create hardware model
		val cpu1 = processor("CPU1")
		val cpu2 = processor("CPU2")

		// create software model
		val consumer1 = consumer("Component1") => [
			add(
				behavior("B1") => [
					add(
						step("B1S1", #{ cpu1->1000L }),
						step("B1S2", #{ cpu1->1000L })
					)
				],
				behavior("B2") => [
					repeatUnless("B1S1")
					add(
						step("B2S1", #{ cpu2->400L })
					)
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1, cpu2)
			add(consumer1)
			addInitial(
				consumer1.behaviors.get(0),
				consumer1.behaviors.get(1)
			)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 5, false)
		result.check("B1S1", 0, 0, 1000)
		result.check("B1S2", 1000, 1000, 2000)
		result.check("B2S1", 0,   0,   0, 400)
		result.check("B2S1", 1, 400, 400, 800)
		result.check("B2S1", 2, 800, 800, 1200)
	}
		
}
