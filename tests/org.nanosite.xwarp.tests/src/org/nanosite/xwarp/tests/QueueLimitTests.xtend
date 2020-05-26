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
	def void testQueueOverflow_PolicyDiscardOldest() {
		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// driver just passes through all messages
				behavior("Driver") => [
					add(step("D", 10L))
					send("Worker")
				],
				// worker will not be able to handle all messages in time
				behavior("Worker",
					queueConfig(limit(2, DISCARD_OLDEST))
				) => [
					add(step("W", 100L))
				]
			)
		]

		// build model to be simulated
		val driver = consumer1.behaviors.get(0)
		val worker = consumer1.behaviors.get(1)
		val model = model => [
			add(consumer1)
			for(i : 1..5)
				addInitial(driver)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 8, false)
		// triggers #1 and #2 will be discarded because queue is full
		result.checkQueueStatistics(worker, 0, 2, 2)
		result.check("Comp1::Driver::D", 0,   0,   0,  10)
		result.check("Comp1::Driver::D", 1,  10,  10,  20)
		result.check("Comp1::Driver::D", 2,  20,  20,  30)
		result.check("Comp1::Driver::D", 3,  30,  30,  40)
		result.check("Comp1::Driver::D", 4,  40,  40,  50)
		result.check("Comp1::Driver::D", 0,   0,   0,  10)
		result.check("Comp1::Driver::D", 0,   0,   0,  10)
		result.check("Comp1::Driver::D", 0,   0,   0,  10)
		result.check("Comp1::Worker::W", 0,  10,  10, 110)
		result.check("Comp1::Worker::W", 1, 110, 110, 210)
		result.check("Comp1::Worker::W", 2, 210, 210, 310)
		
		// check predecessors
		result.checkPredecessor("Comp1::Worker::W", 0, "Comp1::Driver::D", 0)
		result.checkPredecessor("Comp1::Worker::W", 1, "Comp1::Driver::D", 3)
		result.checkPredecessor("Comp1::Worker::W", 2, "Comp1::Driver::D", 4)
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
