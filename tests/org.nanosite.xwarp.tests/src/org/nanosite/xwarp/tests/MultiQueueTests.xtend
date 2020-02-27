package org.nanosite.xwarp.tests

import org.junit.Test
import static org.nanosite.xwarp.model.WQueueConfig.Strategy.*

class MultiQueueTests extends TestBase {

	@Test
	def void testMultiQueueOneBehaviorOneEachTwoInputs() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1", queueConfig(2, ONE_OF_EACH)) => [
					add(step("S1", #{ cpu1->100L }))
				]
			)
		]

		// build model to be simulated
		val bhvr = consumer1.behaviors.head
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(
				trigger(bhvr, 0),
				trigger(bhvr, 1)
			)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 1, false)
		result.check("Comp1::Bhvr1::S1", 0, 0, 100)
	}


	@Test
	def void testMultiQueueOneBehaviorOneEachFourInputs() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1", queueConfig(4, ONE_OF_EACH)) => [
					add(step("S1", #{ cpu1->100L }))
				]
			)
		]

		// build model to be simulated
		val bhvr = consumer1.behaviors.head
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(
				trigger(bhvr, 0),
				trigger(bhvr, 1),
				trigger(bhvr, 2),
				trigger(bhvr, 3)
			)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 1, false)
		result.check("Comp1::Bhvr1::S1", 0, 0, 100)
	}


	@Test
	def void testMultiQueueOneBehaviorFirstThreeInputs() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1", queueConfig(3, FIRST_AVAILABLE)) => [
					add(step("S1", #{ cpu1->100L }))
				]
			)
		]

		// build model to be simulated
		val bhvr = consumer1.behaviors.head
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(
				trigger(bhvr, 1)
			)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 1, false)
		result.check("Comp1::Bhvr1::S1", 0, 0, 100)
	}



	@Test
	def void testMultiQueueThreeBehaviors() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior with only one step using 3 secs of CPU
				behavior("Bhvr1") => [
					add(step("S1", 200L))
					send("Bhvr3", 0)
				],
				behavior("Bhvr2") => [
					add(step("S1", 500L))
					send("Bhvr3", 1)
				],
				behavior("Bhvr3", queueConfig(2, ONE_OF_EACH)) => [
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
				consumer1.behaviors.get(1)
			)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.check("Comp1::Bhvr1::S1", 0, 0, 200)
		result.check("Comp1::Bhvr2::S1", 0, 0, 500)
		result.check("Comp1::Bhvr3::S1", 500, 500, 510)
	}
}
