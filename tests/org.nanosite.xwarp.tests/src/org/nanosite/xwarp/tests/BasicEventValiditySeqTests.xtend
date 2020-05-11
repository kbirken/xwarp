package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.tests.base.TestBase

class BasicEventValiditySeqTests extends TestBase {

	@Test
	def void testOneCycle() {
		// build simulation model
		val model = buildModel(1)
		
		// create simulator and run simulation
		val result = simulate(model, 1, false)
		result.check("Comp1::Bhvr1::S1", 0, 0, 1000)
		result.checkCycles("Comp1::Bhvr1::S1", 0, 1)
	}
	
	@Test
	def void testTwoCycles() {
		// build simulation model
		val model = buildModel(2)
		
		// create simulator and run simulation
		val result = simulate(model, 2, false)
		result.check("Comp1::Bhvr1::S1", 0, 0, 0, 1000)
		result.check("Comp1::Bhvr1::S1", 1, 1000, 1000, 2000)
		result.checkCycles("Comp1::Bhvr1::S1", 0, 1)
		result.checkCycles("Comp1::Bhvr1::S1", 1, 0)
	}
	
	@Test
	def void testThreeCycles() {
		// build simulation model
		val model = buildModel(3)
		
		// create simulator and run simulation
		val result = simulate(model, 3, false)
		result.check("Comp1::Bhvr1::S1", 0, 0, 0, 1000)
		result.check("Comp1::Bhvr1::S1", 1, 1000, 1000, 2000)
		result.check("Comp1::Bhvr1::S1", 2, 2000, 2000, 3000)
		result.checkCycles("Comp1::Bhvr1::S1", 0, 1)
		result.checkCycles("Comp1::Bhvr1::S1", 1, 0)
		result.checkCycles("Comp1::Bhvr1::S1", 2, 0)
	}
	
	def private IModel buildModel(int nTriggers) {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// behavior with only one step using 1 secs of CPU
				behavior("Bhvr1") => [
					add(step("S1", #{ cpu1->1000L }))
					NRequiredCycles = 2
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
		]
		
		// add initial triggers
		for(i : 1 .. nTriggers)
			model.addInitial(consumer1.behaviors.head)
			
		model
	}	
}
