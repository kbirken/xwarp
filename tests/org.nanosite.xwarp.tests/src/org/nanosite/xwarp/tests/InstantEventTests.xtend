package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

import static org.nanosite.xwarp.model.WQueueConfig.Strategy.*

class InstantEventTests extends TestBase {

	@Test
	def void testInstantEventAfterQueuedData() {
		val model = buildModel(200L, 200L, 198L)
		
		// create simulator and run simulation
		val result = simulate(model, 4, false)
		result.check("Comp1::Timer1::T", 0, 0, 200)
		result.check("Comp1::Timer2::T", 200, 200, 400)
		result.check("Comp1::Data::D", 0, 0, 198)
		result.check("Comp1::Algo::S1", 200, 200, 210)
	}

	// NOTE: If both events occur simultaneously, the actual execution depends on
	//       the order of events in the simulation engine. I.e., there is no special
	//       handling for simultaneous events.
	@Test
	def void testInstantEventAndQueuedDataSimultaneously() {
		val model = buildModel(200L, 200L, 200L)
		
		// create simulator and run simulation
		val result = simulate(model, 4, false)
		result.check("Comp1::Timer1::T", 0, 0, 200)
		result.check("Comp1::Timer2::T", 200, 200, 400)
		result.check("Comp1::Data::D", 0, 0, 200)
		result.check("Comp1::Algo::S1", 400, 400, 410)
	}	
	
	@Test
	def void testQueuedDataAfterFirstInstantEvent() {
		val model = buildModel(200L, 200L, 203L)
		
		// create simulator and run simulation
		val result = simulate(model, 4, false)
		result.check("Comp1::Timer1::T", 0, 0, 200)
		result.check("Comp1::Timer2::T", 200, 200, 400)
		result.check("Comp1::Data::D", 0, 0, 203)
		result.check("Comp1::Algo::S1", 400, 400, 410)
	}
	
	@Test
	def void testQueuedDataAfterSecondInstantEvent() {
		val model = buildModel(200L, 200L, 444L)
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.check("Comp1::Timer1::T", 0, 0, 200)
		result.check("Comp1::Timer2::T", 200, 200, 400)
		result.check("Comp1::Data::D", 0, 0, 444)
		// Algo::S1 will not run
	}
	
	def private buildModel(long tWaitTimer1, long tWaitTimer2, long tWaitData) {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// there are two timer ticks executed sequentially
				behavior("Timer1") => [
					add(step("T", tWaitTimer1))
					send("Timer2", 0)
					send("Algo", 0)
				],
				behavior("Timer2") => [
					add(step("T", tWaitTimer2))
					send("Algo", 0)
				],
				// this is a data producer
				behavior("Data") => [
					add(step("D", tWaitData))
					send("Algo", 1)
				],
				// this is the algorithm with one instant input and one queued input
				behavior("Algo", queueConfig(1, 1, ONE_OF_EACH)) => [
					add(step("S1", #{ cpu1->10L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(
				consumer1.behaviors.get(0),
				consumer1.behaviors.get(2)
			)
		]
		
		model
	}
}
