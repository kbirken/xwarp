package org.nanosite.xwarp.tests

import org.junit.Test

import static extension org.nanosite.xwarp.model.ModelBuilder.*

class BasicParallelTests extends TestBase {

	@Test
	def void testTwoBehaviorsParallel1() {
		// create hardware model
		val cpu1 = processor("CPU1")

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
		result.check("C2B1S1", 0, 0, 2000)
	}
	
	@Test
	def void testTwoBehaviorsParallel2() {
		// create hardware model
		val cpu1 = processor("CPU1")

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
		result.check("C1B1S1", 0, 0, 2000)
		result.check("C2B1S1", 0, 0, 3000)
	}
	
	@Test
	def void testTwoBehaviorsParallel3() {
		// create hardware model
		val cpu1 = processor("CPU1")

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
		val result = simulate(model, 3, false)
		result.check("C1B1S1", 0, 0, 2000)
		result.check("C1B1S2", 2000, 2000, 4000)
		result.check("C2B1S1", 0, 0, 4000)
	}
	
}
