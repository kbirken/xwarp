package org.nanosite.xwarp.simulation

import com.google.common.collect.Iterables
import java.util.List
import org.nanosite.xwarp.model.IBandwidthResourceInterface
import org.nanosite.xwarp.model.IResource

class WResourceUsage {
	
	val IResource resource
	
	val int contextSwitchingPenalty
	
	long sum = 0
	List<IJob> users = newArrayList
	
	long min = Long.MAX_VALUE
	
	new (IResource resource) {
		this.resource = resource
		this.contextSwitchingPenalty =
			if (resource instanceof IBandwidthResourceInterface)
				resource.CST
			else
				0
	}
	
	def request(long amount, IJob by) {
		sum = sum + amount
		users.add(by)		
	}

	def computeMin() {
		// TODO: also handle more advanced schedulers
		val sharing = users.size > 1
		for(job : users) {
			var amount = job.getResourceNeed(resource)
			if (contextSwitchingPenalty>0 && sharing) {
				val penalty = amount * contextSwitchingPenalty 
				amount += WIntAccuracy.div(penalty, 1000L)
			}
			if (amount>0 && amount<min) {
				min = amount
			}
		}
	}
	
	def long getSum() {
		sum
	}
	
	def long getMinDelta() {
		if (resource.isLimited)
			min * users.size
		else
			min
	}
	
	def consume(long deltaTime, ILogger logger) {
		// TODO: also handle more advanced schedulers
		val nReq = users.size
		val sharing = nReq > 1
		val dt =
			if (resource.isLimited)
				WIntAccuracy.div(deltaTime, nReq)
			else deltaTime

		var dtNetto = dt
		if (contextSwitchingPenalty>0 && sharing) {
			// we implicitly rounded the last digit of dtNetto, add 5 to compensate this
			dtNetto = WIntAccuracy.div(dt*1000, 1000+contextSwitchingPenalty)
			if (dtNetto<10) {
				dtNetto = dtNetto + 5
			}
//			logger.log(3, ILogger.Type.DEBUG, "%s: cst penalty, res %d: dt=%5d dtNetto=%5d cts=%5d\n",
//						getQualifiedName().c_str(),
//						i,
//						CIntAccuracy::toPrint(dt),
//						CIntAccuracy::toPrint(dtNetto),
//						cstPer1000
//					);
		}
		for(job : users) {
			job.useResource(resource, dtNetto)
		}
	}
	
	def getUsers() {
		users
	}
	
	def asString() {
		'''«resource.name»/«users.size»/«WIntAccuracy.toPrint(sum)»>«WIntAccuracy.toPrint(minDelta)» '''
	}
	
	def logUsedByJob(IJob job) {
		val sumScaled = WIntAccuracy.toPrint(sum)
		val byJob = job.getResourceNeed(resource)
		if (byJob>0)
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
