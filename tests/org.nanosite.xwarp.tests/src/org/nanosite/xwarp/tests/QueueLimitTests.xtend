package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

import static org.nanosite.xwarp.model.WQueueConfig.Limit.Policy.*

class QueueLimitTests extends TestBase {

	@Test
	def void testQueueOverflow_PolicyDiscard() {
		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior with only one step and a queue with a limit
				behavior("Bhvr1",
					queueConfig(limit(2, DISCARD_INCOMING))
				) => [
					add(step("S1", 100L))
				]
			)
		]

		// build model to be simulated
		val bhvr = consumer1.behaviors.head 
		val model = model => [
			add(consumer1)
			for(i : 1..5)
				addInitial(bhvr)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.check("Comp1::Bhvr1::S1", 0,   0,   0, 100)
		result.check("Comp1::Bhvr1::S1", 1, 100, 100, 200)
		result.check("Comp1::Bhvr1::S1", 2, 200, 200, 300)
		// next two triggers will be discarded because queue is full
	}

	@Test
	def void testInstantQueueOverflow_PolicyAbort() {
		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior with only one step and a queue with a limit
				behavior("Bhvr1",
					queueConfig(limit(2, ABORT_SIMULATION))
				) => [
					add(step("S1", 100L))
				]
			)
		]

		// build model to be simulated
		val bhvr = consumer1.behaviors.head 
		val model = model => [
			add(consumer1)
			for(i : 1..5)
				addInitial(bhvr)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 0, false)
		result.checkQueueAbort("Comp1::Bhvr1", 0)
		// the simulation will be aborted immediately because of queue overflow
	}
	
	
	@Test
	def void testQueueOverflow_PolicyAbort() {
		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior with only one step and a queue with a limit
				behavior("Bhvr1",
					queueConfig(limit(2, ABORT_SIMULATION))
				) => [
					add(step("S1", 100L))
					
					// send twice, exponential growth
					send("Bhvr1")
					send("Bhvr1")
				]
			)
		]

		// build model to be simulated
		val bhvr = consumer1.behaviors.head 
		val model = model => [
			add(consumer1)
			addInitial(bhvr)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 2, false)
		result.checkQueueAbort("Comp1::Bhvr1", 0)
		result.check("Comp1::Bhvr1::S1", 0,   0,   0, 100)
		result.check("Comp1::Bhvr1::S1", 1, 100, 100, 200)
		// next two triggers will be discarded because queue is full
	}
	
}
