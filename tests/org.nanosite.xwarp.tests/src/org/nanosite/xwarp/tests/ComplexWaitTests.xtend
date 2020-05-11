package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

class ComplexWaitTests extends TestBase {

	@Test
	def void testTwoBehaviorsWithWait1() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Component1") => [
			add(
				behavior("C1B1") => [
					add(step("C1B1S1", 2000L))
				]
			)
		]
		val consumer2 = consumer("Component2") => [
			add(
				behavior("C2B1") => [
					add(step("C2B1S1", #{ cpu1->1000L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1, consumer2)
			addInitial(consumer1.behaviors.head, consumer2.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 2, false)
		result.check("C1B1S1", 0, 0, 2000)
		result.check("C2B1S1", 0, 0, 1000)
	}

	@Test
	def void testTwoBehaviorsWithWait2() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		// parallel waits will not take extra time as waiting is an unlimited resource
		val consumer1 = consumer("Component1") => [
			add(
				behavior("C1B1") => [
					add(step("C1B1S1", 3000L))
				]
			)
		]
		val consumer2 = consumer("Component2") => [
			add(
				behavior("C2B1") => [
					add(step("C2B1S1", 2000L, #{ cpu1->1000L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1, consumer2)
			addInitial(consumer1.behaviors.head, consumer2.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 2, false)
		result.check("C1B1S1", 0, 0, 3000)
		result.check("C2B1S1", 0, 0, 2000)
	}

	@Test
	def void testTwoBehaviorsWithWait3() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Component1") => [
			add(
				behavior("C1B1") => [
					add(step("C1B1S1", 1000L, #{ cpu1->800L }))
				]
			)
		]
		val consumer2 = consumer("Component2") => [
			add(
				behavior("C2B1") => [
					add(step("C2B1S1", #{ cpu1->2000L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1, consumer2)
			addInitial(consumer1.behaviors.head, consumer2.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 2, false)
		result.check("C1B1S1", 0, 0, 2*500 + 2*300)
		result.check("C2B1S1", 0, 0, 2*500 + 2*300 + 1200)
	}

}
