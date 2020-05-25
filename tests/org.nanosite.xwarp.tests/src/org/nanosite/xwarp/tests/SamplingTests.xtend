package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

import static org.nanosite.xwarp.model.WQueueConfig.Strategy.*
import static org.nanosite.xwarp.model.WQueueConfig.Limit.Policy.*

class SamplingTests extends TestBase {

	@Test
	def void testSamplingInput() {
		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// there are two timer ticks executed sequentially
				behavior("Timer") => [
					add(step("T", 100))
					send("Timer", 0)
					send("Algo", 0)
				],
				// this is a data producer
				behavior("Data1") => [
					add(step("D", 160))
					send("Algo", 1)
					send("Data2")
				],
				// another data producer
				behavior("Data2") => [
					add(step("D", 55))
					send("Algo", 1)
				],
				// this is the algorithm with one instant input and one queued input
				behavior("Algo",
					queueConfig(1, 1, ONE_OF_EACH, #{ 0 -> limit(1, SAMPLING)})
				) => [
					add(step("W", 180))
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
		val result = simulate(model, #[ timeLimit(599L) ], 10, false)
		val algo = consumer1.behaviors.get(3)
		result.checkQueueStatistics(algo, 0, 1, 0)
		result.check("Comp1::Timer::T", 0,   0,   0, 100)
		result.check("Comp1::Data1::D", 0,   0,   0, 160)
		result.check("Comp1::Timer::T", 1, 100, 100, 200)
		result.check("Comp1::Data2::D", 0, 160, 160, 215)
		result.check("Comp1::Timer::T", 2, 200, 200, 300)
		result.check("Comp1::Algo::W",  0, 200, 200, 380)
		result.check("Comp1::Timer::T", 3, 300, 300, 400)
		result.check("Comp1::Timer::T", 4, 400, 400, 500)
		result.check("Comp1::Algo::W",  1, 400, 400, 580)
		result.check("Comp1::Timer::T", 5, 500, 500, 600)
	}
}
