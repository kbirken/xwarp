package org.nanosite.xwarp.result

import com.google.common.collect.Sets
import java.util.Collection
import java.util.Map
import org.nanosite.xwarp.model.IConsumable
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.simulation.WIntAccuracy

class IterationResult {
	
	val int n
	val long deltaT
	val IConsumable waitResource
	
	val Map<IConsumable, Collection<IStep>> resourceUsers = newHashMap
	
	new (int n, long deltaT, IConsumable waitResource) {
		this.n = n
		this.deltaT = deltaT
		this.waitResource = waitResource
	}
	
	def int getN() {
		n
	}
	
	def long getDeltaT() {
		deltaT
	}
		
	def void addResourceUsage(IConsumable res, Iterable<IStep> users) {
		if (resourceUsers.containsKey(res)) {
			// merge both lists
			val both = Sets.union(resourceUsers.get(res).toSet, users.toSet)
			resourceUsers.put(res, both)
		} else {
			resourceUsers.put(res, users.toSet)
		}
	}
	
	def getWaitResourceUsage() {
		resourceUsers.get(waitResource)
	}
	
	def getResourceUsage() {
		resourceUsers
	}
	
	def void dump() {
		println("iteration " + n + " (t=" + WIntAccuracy.toPrint(deltaT) + ")")
		for(res : resourceUsers.keySet) {
			val users = resourceUsers.get(res)
			println('''   resource «res.name»: «users.join(", ")»''')
		}
	}
}
