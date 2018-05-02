package org.nanosite.xwarp.tests

import org.junit.Test
import org.nanosite.xwarp.simulation.WLogger
import org.nanosite.xwarp.simulation.WSimulator

import static extension org.nanosite.xwarp.model.ModelBuilder.*

class BasicTests {

	@Test
	def void test01() {
		// create hardware model
		val cpu1 = processor("CPU1")

		// create software model
		val consumer1 = consumer("Component1") => [
			add(
				behavior("Behavior1") => [
					add(step("Step1", #{ cpu1->100L }))
					add(step("Step2", #{ cpu1->500L }))
				]
			)
		]

		// build model to be simulated
		val model = model => [
			add(cpu1)
			add(consumer1)
			addInitial(consumer1.behaviors.head)
		]
		
		// create simulator and start simulation
		val logger = new WLogger(9)
		val simulator = new WSimulator(logger)
		simulator.simulate(model)
	}
	
}
