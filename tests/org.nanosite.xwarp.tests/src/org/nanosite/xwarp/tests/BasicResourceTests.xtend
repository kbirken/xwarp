package org.nanosite.xwarp.tests

import org.junit.Test

class BasicResourceTests extends TestBase {

	val static PERCENT = 10
	
	@Test
	def void testResourceOneUserNoCPU0() {
		// create hardware model
		val res1 = resource("res1", #[ 10*PERCENT ])

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(step("S1", #{ res1.ri(0)->1000L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(res1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 1, false)
		result.check("S1", 0, 0, 1000)
	}
	
	@Test
	def void testResourceOneUserWithCPU1() {
		// create hardware model
		val cpu1 = processor("CPU1")
		val res1 = resource("res1", #[ 10*PERCENT ])

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(step("S1", #{ cpu1->500L, res1.ri(0)->1000L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1, res1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 1, false)
		result.check("S1", 0, 0, 1000)
	}
	
	@Test
	def void testResourceOneUserWithCPU2() {
		// create hardware model
		val cpu1 = processor("CPU1")
		val res1 = resource("res1", #[ 10*PERCENT ])

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(step("S1", #{ cpu1->1000L, res1.ri(0)->500L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1, res1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 1, false)
		result.check("S1", 0, 0, 1000)
	}
	
	@Test
	def void testResourceTwoUsersNoCPU1() {
		// create hardware model
		val res1 = resource("res1", #[ 10*PERCENT ])

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(step("B1S1", #{ res1.ri(0)->500L }))
				],
				behavior("Bhvr2") => [
					add(step("B2S1", #{ res1.ri(0)->500L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(res1)
			add(consumer1)
			addInitial(
				consumer1.behaviors.get(0),
				consumer1.behaviors.get(1)
			)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 2, false)
		result.check("B1S1", 0, 0, 1100)
		result.check("B2S1", 0, 0, 1100)
	}

	@Test
	def void testResourceTwoUsersNoCPU2() {
		// create hardware model with two resource interfaces
		val res1 = resource("res1", #[ 10*PERCENT, 20*PERCENT ])

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(
						step("B1S1", #{ res1.ri(0)->500L }),
						step("B1S2", #{ res1.ri(1)->500L })
					)
				],
				behavior("Bhvr2") => [
					add(step("B2S1", #{ res1.ri(0)->500L }))
					add(step("B2S2", #{ res1.ri(1)->1000L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(res1)
			add(consumer1)
			addInitial(
				consumer1.behaviors.get(0),
				consumer1.behaviors.get(1)
			)
		]
		
		// create simulator and run simulation
		val result = simulate(model, 4, false)
		result.check("B1S1", 0, 0, 1100)
		result.check("B1S2", 1100, 1100, 2300)
		result.check("B2S1", 0, 0, 1100)
		result.check("B2S2", 1100, 1100, 2300+500)
	}
}
