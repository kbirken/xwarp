package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.model.impl.WBehavior
import org.nanosite.xwarp.model.impl.WConsumer
import org.nanosite.xwarp.model.impl.WModel
import org.nanosite.xwarp.model.impl.WProcessor
import org.nanosite.xwarp.model.impl.WStep
import org.nanosite.xwarp.simulation.WLogger
import org.nanosite.xwarp.simulation.WSimulator

class BasicTests {

	@Test
	def void test01() {
		// create hardware model
		val cpu1 = new WProcessor("CPU1")

		// create software model
		val consumer1 = new WConsumer("Component1") => [
			addBehavior(
				new WBehavior("Behavior1") => [
					addStep(new WStep("Step1", #{ cpu1->100L }))
					addStep(new WStep("Step2", #{ cpu1->500L }))
				]
			)
		]

		// build model to be simulated
		val model = new WModel => [
			addResource(cpu1)
			addConsumer(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and start simulation
		val logger = new WLogger(9)
		val simulator = new WSimulator(logger)
		simulator.simulate(model)
	}
	
}
