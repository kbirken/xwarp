package org.nanosite.xwarp.tests

import org.junit.Test

class ComplexSequentialTests extends TestBase {

	@Test
	def void testTwoBehaviorsSequential1() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// one behavior triggers the next
				behavior("Bhvr1") => [
					add(
						step("B1S1", #{ cpu1->1000L }),
						step("B1S2", #{ cpu1->2000L })
					)
					send("Bhvr2")
				],
				behavior("Bhvr2") => [
					add(
						step("B2S1", #{ cpu1->500L }),
						step("B2S2", #{ cpu1->600L })
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
		val result = simulate(model, 4, false)
		result.check("B1S1", 0, 0, 1000)
		result.check("B1S2", 1000, 1000, 3000)
		result.check("B2S1", 3000, 3000, 3500)
		result.check("B2S2", 3500, 3500, 4100)
	}

	@Test
	def void testTwoBehaviorsSequential2() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// one behavior triggers the next
				behavior("Bhvr1") => [
					add(
						step("B1S1", #{ cpu1->1000L }),
						step("B1S2", #{ cpu1->2000L })
					)
					send("Bhvr2")
				]
			)
		]
		val consumer2 = consumer("Comp2") => [
			add(
				// one behavior triggers the next
				behavior("Bhvr2") => [
					add(
						step("B2S1", #{ cpu1->500L }),
						step("B2S2", #{ cpu1->600L })
					)
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1, consumer2)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 4, false)
		result.check("B1S1", 0, 0, 1000)
		result.check("B1S2", 1000, 1000, 3000)
		result.check("B2S1", 3000, 3000, 3500)
		result.check("B2S2", 3500, 3500, 4100)
	}
		
}
