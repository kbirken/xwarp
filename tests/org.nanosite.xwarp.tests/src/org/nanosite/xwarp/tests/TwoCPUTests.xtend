package org.nanosite.xwarp.tests

import org.junit.Test

class TwoCPUTests extends TestBase {

	@Test
	def void testTwoBehaviorsParallel1() {
		// create hardware model
		val cpu1 = processor("CPU1")
		val cpu2 = processor("CPU2")

		// create software model
		val consumer1 = consumer("Component1") => [
			add(
				behavior("C1B1") => [
					add(step("C1B1S1", #{ cpu1->1000L }))
				]
			)
		]
		val consumer2 = consumer("Component2") => [
			add(
				behavior("C2B1") => [
					add(step("C2B1S1", #{ cpu2->1000L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1, cpu2)
			add(consumer1, consumer2)
			addInitial(consumer1.behaviors.head, consumer2.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 2, false)
		result.check("C1B1S1", 0, 0, 1000)
		result.check("C2B1S1", 0, 0, 1000)
	}
	
	@Test
	def void testTwoBehaviorsParallel2() {
		// create hardware model
		val cpu1 = processor("CPU1")
		val cpu2 = processor("CPU2")

		// create software model
		val consumer1 = consumer("Component1") => [
			add(
				behavior("C1B1") => [
					add(step("C1B1S1", #{ cpu1->1000L }))
				]
			)
		]
		val consumer2 = consumer("Component2") => [
			add(
				behavior("C2B1") => [
					add(step("C2B1S1", #{ cpu2->2000L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1, cpu2)
			add(consumer1, consumer2)
			addInitial(consumer1.behaviors.head, consumer2.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 2, false)
		result.check("C1B1S1", 0, 0, 1000)
		result.check("C2B1S1", 0, 0, 2000)
	}
	
	@Test
	def void testTwoBehaviorsParallel3() {
		// create hardware model
		val cpu1 = processor("CPU1")
		val cpu2 = processor("CPU2")

		// create software model
		val consumer1 = consumer("Component1") => [
			add(
				behavior("C1B1") => [
					add(step("C1B1S1", #{ cpu1->1000L }))
					add(step("C1B1S2", #{ cpu1->1000L }))
				]
			)
		]
		val consumer2 = consumer("Component2") => [
			add(
				behavior("C2B1") => [
					add(step("C2B1S1", #{ cpu2->2000L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1, cpu2)
			add(consumer1, consumer2)
			addInitial(consumer1.behaviors.head, consumer2.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.check("C1B1S1", 0, 0, 1000)
		result.check("C1B1S2", 1000, 1000, 2000)
		result.check("C2B1S1", 0, 0, 2000)
	}
	
}
