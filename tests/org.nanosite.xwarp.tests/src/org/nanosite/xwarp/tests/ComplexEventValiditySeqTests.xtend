package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.tests.base.TestBase

class ComplexEventValiditySeqTests extends TestBase {

	@Test
	def void testPipelinedCycles() {
		// build simulation model
		val model = buildModel(4)
		
		// create simulator and run simulation
		val result = simulate(model, 8, false)

		result.checkCycles("Comp1::Bhvr1::S1", 0, 2)
		result.checkCycles("Comp1::Bhvr2::S1", 0, 2)
		
		result.checkCycles("Comp1::Bhvr1::S1", 1, 1)
		result.checkCycles("Comp1::Bhvr2::S1", 1, 2)
		
		result.checkCycles("Comp1::Bhvr1::S1", 2, 0)
		result.checkCycles("Comp1::Bhvr2::S1", 2, 1)

		result.checkCycles("Comp1::Bhvr1::S1", 3, 0)
		result.checkCycles("Comp1::Bhvr2::S1", 3, 0)

		result.check("Comp1::Bhvr2::S1", 3, 400L, 400L, 430L)
	}
	
	def private IModel buildModel(int nTriggers) {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Comp1") => [
			add(
				// two behaviors with 3 and 2 required cycles, respectively 
				behavior("Bhvr1") => [
					add(step("S1", 100L ))
					NRequiredCycles = 3
					send("Bhvr2")
				],
				behavior("Bhvr2") => [
					add(step("S1", 30L ))
					NRequiredCycles = 2
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
		]
		
		// add initial triggers for first behavior
		for(i : 1 .. nTriggers)
			model.addInitial(consumer1.behaviors.head)
			
		model
	}	
}
