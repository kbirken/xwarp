package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

class PreconditionTests extends TestBase {

	@Test
	def void testSimplePrecondition1() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Component1") => [
			add(
				behavior("B1") => [
					add(
						step("B1S1", #{ cpu1->1000L }),
						step("B1S2", #{ cpu1->2000L })
					)
				],
				behavior("B2") => [
					add(
						step("B2S1", #{ cpu1->2000L }) => [
							precondition("B1S2")
						]
					)
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(
				consumer1.behaviors.get(0),
				consumer1.behaviors.get(1)
			)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.check("B1S1", 0, 0, 1000)
		result.check("B1S2", 1000, 1000, 3000)
		result.check("B2S1", 0, 3000, 5000)
	}
	
	@Test
	def void testSimplePrecondition2() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Component1") => [
			add(
				behavior("B1") => [
					add(
						step("B1S1", #{ cpu1->490L }),
						step("B1S2", #{ cpu1->10L })
					)
				],
				behavior("B2") => [
					add(
						step("B2S1", #{ cpu1->10L }),
						step("B2S2", #{ cpu1->300L }) => [
							precondition("B1S1")
						]
					)
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(
				consumer1.behaviors.get(0),
				consumer1.behaviors.get(1)
			)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 4, false)
		result.check("B1S1", 0, 0, 500)
		result.check("B1S2", 500, 500, 520)
		result.check("B2S1", 0, 0, 20)
		result.check("B2S2", 20, 500, 810)
	}
}
