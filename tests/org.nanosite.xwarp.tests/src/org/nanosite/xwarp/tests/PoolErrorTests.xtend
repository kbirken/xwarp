package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.model.IPool

import static org.nanosite.xwarp.model.IPool.ErrorAction.*

class PoolErrorTests extends TestBase {

	val static P = "pool1"
	
	@Test
	def void testPoolOneUserNoCPU_Reject1() {
		// create hardware model
		// add alloc/free pool with REJECT_AND_CONTINUE on overflow
		val pool1 = pool(P, 1000,
			REJECT_AND_CONTINUE, REJECT_AND_CONTINUE
		)

		// build model to be simulated
		val model = overflowInSecondStep(pool1)
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.checkPool(P, 50, 1, 0)
		result.checkPool("S1", P, 100, false, false)
		result.checkPool("S2", P, 100,  true, false)
		result.checkPool("S3", P,  50,  true, false)
	}

	@Test
	def void testPoolOneUserNoCPU_Execute1() {
		// create hardware model
		// add alloc/free pool with EXECUTE_AND_CONTINUE on overflow
		val pool1 = pool(P, 1000,
			EXECUTE_AND_CONTINUE, REJECT_AND_CONTINUE
		)

		// build model to be simulated
		val model = overflowInSecondStep(pool1)
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.checkPool(P, 2050, 2, 0)
		result.checkPool("S1", P,  100, false, false)
		result.checkPool("S2", P, 2100,  true, false)
		result.checkPool("S3", P, 2050,  true, false)
	}
	
	@Test
	def void testPoolOneUserNoCPU_Stop1() {
		// create hardware model
		// add alloc/free pool with STOP_WORKING on overflow
		val pool1 = pool(P, 1000,
			STOP_WORKING, REJECT_AND_CONTINUE
		)

		// build model to be simulated
		val model = overflowInSecondStep(pool1)
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.checkPool(P, 100, 1, 0)
		result.checkPool("S1", P,  100, false, false)
		result.checkPool("S2", P,  100,  true, false)
		result.checkPool("S3", P,  100,  true, false)
	}
	
	def private IModel overflowInSecondStep(IPool pool) {
		// build software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(
						step("S1", #{ pool->  100L }),
						step("S2", #{ pool-> 2000L }),
						step("S3", #{ pool->  -50L })
					)
				]
			)
		]

		// build model to be simulated
		model => [
			add(pool)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
	}

	@Test
	def void testPoolOneUserNoCPU_Reject2() {
		// create hardware model
		// add alloc/free pool with REJECT_AND_CONTINUE on overflow
		val pool1 = pool(P, 1000,
			REJECT_AND_CONTINUE, REJECT_AND_CONTINUE
		)

		// build model to be simulated
		val model = underflowInSecondStep(pool1)
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.checkPool(P, 150, 0, 1)
		result.checkPool("S1", P, 100, false, false)
		result.checkPool("S2", P, 100, false,  true)
		result.checkPool("S3", P, 150, false,  true)
	}

	@Test
	def void testPoolOneUserNoCPU_Execute2() {
		// create hardware model
		// add alloc/free pool with EXECUTE_AND_CONTINUE on underflow
		val pool1 = pool(P, 1000,
			REJECT_AND_CONTINUE, EXECUTE_AND_CONTINUE
		)

		// build model to be simulated
		val model = underflowInSecondStep(pool1)
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.checkPool(P, -1850, 0, 2)
		result.checkPool("S1", P, 100, false, false)
		result.checkPool("S2", P, -1900, false,  true)
		result.checkPool("S3", P, -1850, false,  true)
	}

	@Test
	def void testPoolOneUserNoCPU_Stop2() {
		// create hardware model
		// add alloc/free pool with STOP_WORKING on underflow
		val pool1 = pool(P, 1000,
			REJECT_AND_CONTINUE, STOP_WORKING
		)

		// build model to be simulated
		val model = underflowInSecondStep(pool1)
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.checkPool(P, 100, 0, 1)
		result.checkPool("S1", P, 100, false, false)
		result.checkPool("S2", P, 100, false,  true)
		result.checkPool("S3", P, 100, false,  true)
	}

	def private IModel underflowInSecondStep(IPool pool) {
		// build software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(
						step("S1", #{ pool->   100L }),
						step("S2", #{ pool-> -2000L }),
						step("S3", #{ pool->    50L })
					)
				]
			)
		]

		// build model to be simulated
		model => [
			add(pool)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
	}
}
