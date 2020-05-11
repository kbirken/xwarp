package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

class BasicLoopTests extends TestBase {

	@Test
	def void testLoopedBehaviorBasic() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior which is executed 3 times
				behavior("Bhvr1", 3) => [
					add(step("S1", #{ cpu1->1000L }))
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
		val result = simulate(model, 3, false)
		result.check("S1", 0,    0,    0, 1000)
		result.check("S1", 1, 1000, 1000, 2000)
		result.check("S1", 2, 2000, 2000, 3000)
	}
	
	@Test
	def void testLoopedBehaviorWithSend() {
		// create hardware model
		val cpu1 = processor("CPU1")
		val cpu2 = processor("CPU2")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior which is executed 2 times
				behavior("Bhvr1", 2) => [
					add(step("S1", #{ cpu1->1000L }))
					send("Bhvr2")
				],

				// behavior which is executed 3 times
				behavior("Bhvr2") => [
					add(step("S2", #{ cpu2->100L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1, cpu2)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 4, false)
		result.check("S1", 0,    0,    0, 1000)
		result.check("S1", 1, 1000, 1000, 2000)
		result.check("S2", 0, 1000, 1000, 1100)
		result.check("S2", 1, 2000, 2000, 2100)
	}
	
	
}
