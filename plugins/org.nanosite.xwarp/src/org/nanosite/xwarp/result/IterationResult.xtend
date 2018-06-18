package org.nanosite.xwarp.result

import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.IResource
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.simulation.WIntAccuracy

class IterationResult {
	
	val int n
	val long deltaT
	
	val Map<IResource, List<IStep>> resourceUsers = newHashMap
	
	new (int n, long deltaT) {
		this.n = n
		this.deltaT = deltaT
	}
	
	def int getN() {
		n
	}
	
	def long getDeltaT() {
		deltaT
	}
	
	def void addResourceUsage(IResource res, Iterable<IStep> users) {
		resourceUsers.put(res, users.toList)
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
