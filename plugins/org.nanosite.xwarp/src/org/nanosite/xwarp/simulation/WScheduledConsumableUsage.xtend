package org.nanosite.xwarp.simulation

import java.util.List
import org.nanosite.xwarp.model.IScheduledConsumable
import org.nanosite.xwarp.model.IResource

class WScheduledConsumableUsage {
	
	val IScheduledConsumable consumable
	
	long sum = 0
	List<IJob> users = newArrayList
	
	long min = Long.MAX_VALUE
	
	new (IScheduledConsumable consumable) {
		this.consumable = consumable
	}
	
	def request(long amount, IJob by) {
		sum = sum + amount
		users.add(by)		
	}

	def computeMin() {
		// TODO: also handle more advanced schedulers
		for(job : users) {
			val amount = job.computeRequiredAmount
			if (amount>0 && amount<min) {
				min = amount
			}
		}
	}
	
	def private long computeRequiredAmount(IJob job) {
		var amount = job.getConsumableNeed(consumable)
		val sharing = users.size > 1
		if (sharing) {
			if (consumable instanceof IResource) {
				val cst = job.getResourcePenalty(consumable)
				val penalty = amount * cst 
				amount += WIntAccuracy.div(penalty, 1000L)
			}
		}
		amount
	}
	
	def long getSum() {
		sum
	}
	
	def long getMinDelta() {
		if (consumable.isLimited)
			min * users.size
		else
			min
	}
	
	def consume(long deltaTime, ILogger logger) {
		// TODO: also handle more advanced schedulers
		val nReq = users.size
		val sharing = nReq > 1
		val dt =
			if (consumable.isLimited)
				WIntAccuracy.div(deltaTime, nReq)
			else deltaTime

		for(job : users) {
			var dtNetto = dt
			if (sharing) {
				if (consumable instanceof IResource) {
					val cst = job.getResourcePenalty(consumable)
					if (cst>0) {
						// we implicitly rounded the last digit of dtNetto, add 5 to compensate this
						dtNetto = WIntAccuracy.div(dt*1000, 1000+cst)
						if (dtNetto<10) {
							dtNetto = dtNetto + 5
						}
						val qn = job.qualifiedName
						logger.log(3, ILogger.Type.DEBUG,
							'''«qn»: cst penalty for '«consumable.name»': dt=«WIntAccuracy.toPrint(dt)» cst=«cst» dtNetto=«WIntAccuracy.toPrint(dtNetto)»'''
						)
					}
				}
			}
			job.useConsumable(consumable, dtNetto)
		}
	}
	
	def getUsers() {
		users
	}
	
	def asString() {
		'''«consumable.name»/«users.size»/«WIntAccuracy.toPrint(sum)»>«WIntAccuracy.toPrint(minDelta)» '''
	}
	
	def logUsedByJob(IJob job) {
		val amount = job.getConsumableNeed(consumable)
		val amountReal = job.computeRequiredAmount
		if (amount<=0) {
			format(0L, 0L)
		} else {
			format(WIntAccuracy.toPrint(amount), WIntAccuracy.toPrint(amountReal))
		}
	}	

	def static logNotUsed() {
		format(0, 0)
	}
	
	def static private format(long perRes, long perJob) {
		''' «String.format("%07d", perRes)»/«String.format("%07d", perJob)» '''
	}
}
