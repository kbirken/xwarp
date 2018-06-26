package org.nanosite.xwarp.simulation

import org.nanosite.xwarp.model.ModelBuilder

/**
 * Dummy class with main() function.</p>
 * 
 * This is useful for exporting xwarp as jar file together
 * with the required dependencies (e.g., xtend runtime libs).</p>
 * 
 * Apart from that, this class is not needed for using the simulator.</p>
 */
class WMainDummy {

	protected static extension ModelBuilder = new ModelBuilder

	def static void main(String[] args) {
		// build example model
		val cpu1 = processor("CPU1")
		val consumer1 = consumer("Comp1") => [
			add(
				behavior("Bhvr1") => [
					add(step("S1", #{ cpu1->3000L }))
				]
			)
		]
		val model = model => [
			add(cpu1, consumer1)
			addInitial(consumer1.behaviors.head)
		]

		// run simulation
		val logger = new WLogger(4)
		val simulator = new WSimulator(logger)
		val result = simulator.simulate(model)
		result.dump				
	}
}
