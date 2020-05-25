package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

class SeeminglyCyclicTests extends TestBase {

	@Test
	def void testNotACycle1() {
		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(step("S", 0L))
					send("Bhvr2")
				],
				behavior("Bhvr2") => [
					add(step("T", 30L))
				]
			)
		]

		// build model to be simulated
		val bhvr1 = consumer1.behaviors.head
		val model = model => [
			add(consumer1)
			addInitial(bhvr1, bhvr1)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 4, false)
		// no cycle should be detected at t=0
		result.check("Bhvr1::S", 0,  0,  0,  0)
		result.check("Bhvr1::S", 1,  0,  0,  0)
		result.check("Bhvr2::T", 0,  0,  0, 30)
		result.check("Bhvr2::T", 1, 30, 30, 60)
	}

	@Test
	def void testNotACycle2() {
		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(step("S", 0L))
					send("Channel")
				],
				behavior("Channel") => [
					add(step("C", 0L))
					send("Bhvr2")
				],
				behavior("Bhvr2") => [
					add(step("T", 30L))
				]
			)
		]

		// build model to be simulated
		val bhvr1 = consumer1.behaviors.head
		val model = model => [
			add(consumer1)
			addInitial(bhvr1, bhvr1)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 6, false)
		// no cycle should be detected at t=0
		result.check("Bhvr1::S",   0,  0,  0,  0)
		result.check("Bhvr1::S",   1,  0,  0,  0)
		result.check("Channel::C", 0,  0,  0,  0)
		result.check("Channel::C", 1,  0,  0,  0)
		result.check("Bhvr2::T",   0,  0,  0, 30)
		result.check("Bhvr2::T",   1, 30, 30, 60)
	}
}
