package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

import static org.nanosite.xwarp.model.IAllocatingConsumable.ErrorAction.*

class BasicPoolTests extends TestBase {
	
	@Test
	def void testSingleBehaviorWithPool() {
		// create hardware model
		val cpu1 = processor("CPU1")
		val pool1 = pool("pool1", 1000,
			REJECT_AND_CONTINUE, REJECT_AND_CONTINUE
		)

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior with parallel usage of pool and CPU
				behavior("Bhvr1") => [
					add(
						step("S1", #{ cpu1->300L, pool1->100L }),
						step("S2", #{ cpu1->200L, pool1->-30L }),
						step("S3", #{ cpu1->100L, pool1->130L })
					)
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(pool1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.check("S1", 0, 0, 300)
		result.check("S2", 300, 300, 500)
		result.check("S3", 500, 500, 600)
		result.checkPool("S1", "pool1", 100, false, false)
		result.checkPool("S2", "pool1",  70, false, false)
		result.checkPool("S3", "pool1", 200, false, false)
		result.checkPool("pool1", 200, 0, 0)
	}
	
}
