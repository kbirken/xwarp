package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.tests.base.TestBase

class TimeLimitTests extends TestBase {

	@Test
	def void testTimeLimitRoughlyReached() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior with only one step using 3 secs of CPU
				behavior("Bhvr1") => [
					add(
						step("S1", #{ cpu1->30L }),
						step("S2", #{ cpu1->30L }),
						step("S3", #{ cpu1->30L }),
						step("S4", #{ cpu1->30L }),
						step("S5", #{ cpu1->30L })
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
		val result = simulate(model, #[ timeLimit(100L) ], 4, false)
		result.checkTimeLimit(true)
		result.check("Comp1::Bhvr1::S1",  0,  0, 30)
		result.check("Comp1::Bhvr1::S2", 30, 30, 60)
		result.check("Comp1::Bhvr1::S3", 60, 60, 90)
		result.check("Comp1::Bhvr1::S4", 90, 90, 120)
	}
	

	@Test
	def void testTimeLimitExactlyReached() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior with only one step using 3 secs of CPU
				behavior("Bhvr1") => [
					add(
						step("S1", #{ cpu1->97L }),
						step("S2", #{ cpu1->1L }),
						step("S3", #{ cpu1->1L }),
						step("S4", #{ cpu1->1L }),
						step("S5", #{ cpu1->1L })
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
		val result = simulate(model, #[ timeLimit(100L) ], 4, false)
		result.checkTimeLimit(true)
		result.check("Comp1::Bhvr1::S1",  0,  0, 97)
		result.check("Comp1::Bhvr1::S2", 97, 97, 98)
		result.check("Comp1::Bhvr1::S3", 98, 98, 99)
		result.check("Comp1::Bhvr1::S4", 99, 99, 100)
	}
	
	@Test
	def void testTimeLimitNotReached() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior with only one step using 3 secs of CPU
				behavior("Bhvr1") => [
					add(
						step("S1", #{ cpu1->20L }),
						step("S2", #{ cpu1->20L }),
						step("S3", #{ cpu1->20L }),
						step("S4", #{ cpu1->20L })
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
		val result = simulate(model, #[ timeLimit(81L) ], 4, false)
		result.checkTimeLimit(false)
		result.check("Comp1::Bhvr1::S1",  0,  0, 20)
		result.check("Comp1::Bhvr1::S2", 20, 20, 40)
		result.check("Comp1::Bhvr1::S3", 40, 40, 60)
		result.check("Comp1::Bhvr1::S4", 60, 60, 80)
	}
	
}
