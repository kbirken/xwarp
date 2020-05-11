package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

class ComplexResourceTests extends TestBase {

	val static PERCENT = 10
	
	@Test
	def void testResourceTwoUsersComplexSteps() {
		// create hardware model with two resource interfaces
		val res1 = resource("res1", #[ 10*PERCENT, 20*PERCENT ])

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(
						// use resource1 via two different interfaces
						step("B1S1", #{ res1.ri(0)->1500L, res1.ri(1)->500L })
					)
				],
				behavior("Bhvr2") => [
					add(step("B2S1", #{ res1.ri(0)->2000L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(res1)
			add(consumer1)
			addInitial(
				consumer1.behaviors.get(0),
				consumer1.behaviors.get(1)
			)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 2, false)
		result.check("B1S1", 0, 0, 4444)
		result.check("B2S1", 0, 0, 4400)
	}
}
