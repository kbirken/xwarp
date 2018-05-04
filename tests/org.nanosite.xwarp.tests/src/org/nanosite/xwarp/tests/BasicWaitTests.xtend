package org.nanosite.xwarp.tests

import org.junit.Test

class BasicWaitTests extends TestBase {

	@Test
	def void testSingleBehaviorWait1() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(
						step("S1", 2000L)
					)
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 1, false)
		result.check("Bhvr1::S1", 0, 0, 2000)
	}

	@Test
	def void testSingleBehaviorWait2() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(
						step("S1", 2000L),
						step("S2", #{ cpu1->3000L })
					)
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 2, false)
		result.check("Bhvr1::S1", 0, 0, 2000)
		result.check("Bhvr1::S2", 2000, 2000, 5000)
	}

	@Test
	def void testSingleBehaviorWait3() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(
						step("S1", 2000L, #{ cpu1->100L })
					)
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 1, false)
		result.check("Bhvr1::S1", 0, 0, 2000)
	}

	@Test
	def void testSingleBehaviorWait4() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(
						step("S1", 2000L, #{ cpu1->2000L })
					)
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 1, false)
		result.check("Bhvr1::S1", 0, 0, 2000)
	}

	@Test
	def void testSingleBehaviorWait5() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(
						step("S1", 2000L, #{ cpu1->4000L })
					)
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 1, false)
		result.check("Bhvr1::S1", 0, 0, 4000)
	}
}
