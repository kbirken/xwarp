package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

import static org.nanosite.xwarp.model.WQueueConfig.Strategy.*
import static org.nanosite.xwarp.model.WQueueConfig.Limit.Policy.*

class StackTests extends TestBase {

	@Test
	def void testBasicStack() {
		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// this is a looped sender producing a number of data items 
				behavior("Sender", 3, true) => [
					add(step("S", 10))
					send("Algo", 0)
				],
				// this is a receiver with a LATEST_FIRST queue (i.e., a stack)
				behavior("Algo",
					queueConfig(1, FIRST_AVAILABLE, #{ 0 -> limit(5, LATEST_FIRST)})
				) => [
					add(step("W", 100))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(consumer1)
			addInitial(
				consumer1.behaviors.get(0),
				consumer1.behaviors.get(1)
			)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 7, false)
		result.check("Comp1::Sender::S", 0,   0,   0,  10)
		result.check("Comp1::Sender::S", 1,  10,  10,  20)
		result.check("Comp1::Sender::S", 2,  20,  20,  30)
		result.check("Comp1::Algo::W",   0,   0,   0, 100)
		result.check("Comp1::Algo::W",   1, 100, 100, 200)
		result.check("Comp1::Algo::W",   2, 200, 200, 300)
		result.check("Comp1::Algo::W",   3, 300, 300, 400)
		
		// check specific stack behavior
		result.checkPredecessor("Comp1::Algo::W", 1, "Comp1::Sender::S", 2)
		result.checkPredecessor("Comp1::Algo::W", 2, "Comp1::Sender::S", 1)
		result.checkPredecessor("Comp1::Algo::W", 3, "Comp1::Sender::S", 0)
	}
}
