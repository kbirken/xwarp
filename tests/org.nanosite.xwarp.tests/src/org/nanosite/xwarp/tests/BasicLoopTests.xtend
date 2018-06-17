package org.nanosite.xwarp.tests

import org.junit.Test

class BasicLoopTests extends TestBase {

	@Test
	def void testLoopedBehavior() {
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
	
//	@Test
//	def void testSingleBehaviorTwoSteps() {
//		// create hardware model
//		val cpu1 = processor("CPU1")
//
//		// create software model
//		val consumer1 = consumer("Comp1") => [
//			add(
//				behavior("Bhvr1") => [
//					add(
//						step("S1", #{ cpu1->2000L }),
//						step("S2", #{ cpu1->3000L })
//					)
//				]
//			)
//		]
//
//		// build model to be simulated
//		val model = model => [
//			add(cpu1)
//			add(consumer1)
//			addInitial(consumer1.behaviors.head)
//		]
//		
//		// create simulator and run simulation
//		val result = simulate(model, 2, false)
//		result.check("Bhvr1::S1", 0, 0, 2000)
//		result.check("Bhvr1::S2", 2000, 2000, 5000)
//	}
	
}
