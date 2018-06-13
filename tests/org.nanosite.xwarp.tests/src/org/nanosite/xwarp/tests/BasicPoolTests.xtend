package org.nanosite.xwarp.tests

import org.junit.Test

class BasicPoolTests extends TestBase {

	@Test
	def void testPoolOneUserNoCPU0() {
		// create hardware model
		val pool1 = pool("pool1", 1000)

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(
						step("S1", #{ pool1->  100L }),
						step("S2", #{ pool1-> 2000L }),
						step("S3", #{ pool1->  -50L })
					)
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(pool1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.checkPool("pool1", 50, 1, 0)
		result.checkPool("S1", "pool1", 100, false, false)
		result.checkPool("S2", "pool1", 100,  true, false)
		result.checkPool("S3", "pool1",  50,  true, false)
	}
}
