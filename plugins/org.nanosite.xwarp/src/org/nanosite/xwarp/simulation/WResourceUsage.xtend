package org.nanosite.xwarp.simulation

import java.util.List
import org.nanosite.xwarp.model.WResource

class WResourceUsage {
	
	WResource resource
	
	long sum = 0
	List<IJob> users = newArrayList
	
	long min = Long.MAX_VALUE
	
	new (WResource resource) {
		this.resource = resource
	}
	
	def request(long amount, IJob by) {
		sum = sum + amount
		users.add(by)		
	}

	def computeMin() {
		// TODO: handle CST and more advanced schedulers
		for(job : users) {
			val req = job.resourceNeeds.get(resource)
			if (req>0 && req < min) {
				min = req
			}
		}
	}
	
	def long getSum() {
		sum
	}
	
	def long getMin() {
		min
	}
	
	def consume(long deltaTime) {
		// TODO: handle CST and more advanced schedulers
		for(job : users) {
			job.useResource(resource, deltaTime)
		}
	}
	
	def asString() {
		'''«resource.name»/«users.size»/«WIntAccuracy.toPrint(sum)»>«WIntAccuracy.toPrint(min)»'''
	}
	
	def logUsedByJob(IJob job) {
		val sumScaled = WIntAccuracy.toPrint(sum)
		val byJob = job.resourceNeeds.get(resource)
		if (byJob===null)
			format(sumScaled, 0L)
		else
			format(sumScaled, WIntAccuracy.toPrint(byJob))
	}	

	def static logNotUsed() {
		format(0, 0)
	}
	
	def static private format(long perRes, long perJob) {
		''' «String.format("%07d", perRes)»/«String.format("%07d", perJob)» '''
	}
}
