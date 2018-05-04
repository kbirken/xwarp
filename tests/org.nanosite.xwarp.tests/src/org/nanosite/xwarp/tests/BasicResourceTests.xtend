package org.nanosite.xwarp.tests

import org.junit.Test

class BasicResourceTests extends TestBase {

	val static PERCENT = 10L
	
	@Test
	def void testResourceOneUserNoCPU() {
		// create hardware model
		val res1 = resource("res1", #[ 10*PERCENT ])

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(step("S1", #{ res1->1000L }))
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
					add(step("S1", #{ cpu1->500L, res1->1000L }))
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
					add(step("S1", #{ cpu1->1000L, res1->500L }))
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
	def void testResourceTwoUsersNoCPU() {
		// create hardware model
		val res1 = resource("res1", #[ 10*PERCENT/*, 20*PERCENT*/ ])

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(step("B1S1", #{ res1->500L }))
				],
				behavior("Bhvr2") => [
					add(step("B2S1", #{ res1->500L }))
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
		val result = simulate(model, 2, true)
		result.check("B1S1", 0, 0, 1100)
		result.check("B2S1", 0, 0, 1100)
	}
}
