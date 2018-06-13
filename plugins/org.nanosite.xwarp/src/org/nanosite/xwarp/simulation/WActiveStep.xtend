package org.nanosite.xwarp.simulation

import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.IConsumableAmount
import org.nanosite.xwarp.model.IPool
import org.nanosite.xwarp.model.IResource
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.result.StepInstance

class WActiveStep implements IJob {

	val IStep step
	
	val WActiveBehavior behavior
	
	val List<IStep> waitingFor = newArrayList

	Map<IResource, IConsumableAmount> currentNonPoolNeeds = newHashMap

	var StepInstance result
	
	new(IStep step, WActiveBehavior behavior) {
		this.step = step
		this.behavior = behavior
		init(true)

		this.result = new StepInstance(step)
	}
	
	def private init(boolean firstTime) {
		waitingFor.clear
		for(predecessor : step.predecessors) {
			if (step.hasSameBehavior(predecessor)) {
				// the other step can only be the previous step in same behavior
				waitingFor.add(predecessor)
			} else {
				// this is a precondition or some other condition
				// due to the semantics of preconditions we only wait once for each of them
				if (firstTime)
					waitingFor.add(predecessor)
			}
		}

		step.copyNonPoolNeeds(currentNonPoolNeeds)
	}
	
	def IStep getStep() {
		step
	}

	override String getQualifiedName() {
		step.qualifiedName
	}

	override boolean isWaiting() {
		! waitingFor.empty
	}

	override boolean hasResourceNeeds() {
		step.hasNonPoolNeeds
	}

	override Map<IResource, IConsumableAmount> getResourceNeeds() {
		currentNonPoolNeeds
	}

	override long getResourceNeed(IResource resource) {
		val need = currentNonPoolNeeds.get(resource)
		if (need===null)
			0L
		else
			need.amount
	}
	
	override void useResource(IResource resource, long amount) {
		val remaining = currentNonPoolNeeds.get(resource).reduceAmount(amount)
		if (remaining<0) {
			throw new RuntimeException(
				"Internal error: negative resource need for " +
				"resource '" + resource.name + "', shouldn't occur!"
			)
		}
		if (remaining == 0) {
			currentNonPoolNeeds.remove(resource)
		}
	}

	override Map<IPool, Long> getPoolNeeds() {
		step.poolNeeds
	}

	override boolean isDone() {
		currentNonPoolNeeds.empty
	}
	

	override void exitActions() {
		behavior.exitActionsForStep(this, step.successors)
		
		// prepare next execution
		init(false)
	}

	def void triggerWaiting(WActiveStep from, IScheduler scheduler) {
		//printf("CStep::done %s: %s is done - waitfor=%d\n", getQualifiedName().c_str(), step->getQualifiedName().c_str(), _waitFor.size());
	
		if (waitingFor.empty) {
			throw new RuntimeException(
				"Internal error: Missing predecessor '" + from.qualifiedName + "' " +
				"for step '" + qualifiedName + "'"
			)
		}

		// we are no more waiting for the notifying step (because it is done)
		waitingFor.remove(from.step)

		if (waitingFor.empty) {
			// waiting is over
			
			if (step.isFirst) {
				// first step has to ask behavior if trigger has been received yet
				if (behavior.isRunning) {
					scheduler.activateJob(this)
				}
			} else {
				// non-first steps can run immediately
				scheduler.activateJob(this)
			}
		} else {
			scheduler.createWaitingJob(this)
		}
//		eventAcceptor.signalReady(step, this, runNow);
	}

	override void traceWaiting(long timestamp) {
		result.waitingTime = timestamp
	}
		
	override void traceReady(long timestamp) {
		result.readyTime = timestamp
	}
		
	override void traceRunning(long timestamp) {
		result.runningTime = timestamp
	}
		
	override void traceDone(long timestamp) {
		result.doneTime = timestamp
	}
		
	override StepInstance getResult() {
		result
	}
	
	override StepInstance clearResult() {
		val previous = result
		result = new StepInstance(step)
		previous
	}

	override String toString() {
		'''WActiveStep(«step.toString»)'''
	}
	
}
