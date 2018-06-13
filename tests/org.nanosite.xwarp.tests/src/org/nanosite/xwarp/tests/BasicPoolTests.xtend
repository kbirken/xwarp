package org.nanosite.xwarp.tests

import org.junit.Test

import static org.nanosite.xwarp.model.IPool.ErrorAction.*

class BasicPoolTests extends TestBase {

	@Test
	def void testPoolOneUserNoCPU_Reject() {
		// create hardware model
		// add alloc/free pool with REJECT_AND_CONTINUE on overflow
		val pool1 = pool("pool1", 1000,
			REJECT_AND_CONTINUE, REJECT_AND_CONTINUE
		)

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

	@Test
	def void testPoolOneUserNoCPU_Execute() {
		// create hardware model
		// add alloc/free pool with EXECUTE_AND_CONTINUE on overflow
		val pool1 = pool("pool1", 1000,
			EXECUTE_AND_CONTINUE, REJECT_AND_CONTINUE
		)

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
		result.checkPool("pool1", 2050, 2, 0)
		result.checkPool("S1", "pool1",  100, false, false)
		result.checkPool("S2", "pool1", 2100,  true, false)
		result.checkPool("S3", "pool1", 2050,  true, false)
	}
}
