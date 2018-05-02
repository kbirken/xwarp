package org.nanosite.xwarp.simulation

import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.model.impl.WResource

class WActiveStep implements IJob {

	val IStep step
	
	val WActiveBehavior behavior
	
	val List<IStep> preconditions = newArrayList

	Map<WResource, Long> currentResourceNeeds = newHashMap

	new(IStep step, WActiveBehavior behavior) {
		this.step = step
		this.behavior = behavior
		step.copyResourceNeeds(currentResourceNeeds)
	}
	
	def IStep getStep() {
		step
	}

	override String getQualifiedName() {
		step.qualifiedName
	}

	override boolean isWaiting() {
		! preconditions.empty
	}

	override boolean hasResourceNeeds() {
		step.hasResourceNeeds
	}

	override Map<WResource, Long> getResourceNeeds() {
		currentResourceNeeds
	}
	
	override void useResource(WResource resource, long amount) {
		val need = currentResourceNeeds.get(resource)
		val remaining = need - amount
		if (remaining<0) {
			throw new RuntimeException(
				"Internal error: negative resource need for " +
				"resource '" + resource.name + "', shouldn't occur!"
			)
		}
		if (remaining == 0) {
			currentResourceNeeds.remove(resource)
		} else {
			currentResourceNeeds.put(resource, remaining)
		}
	}

	override boolean isDone() {
		currentResourceNeeds.empty
	}
	

	override void exitActions() {
		behavior.exitActionsForStep(this, step.successors)
	}

	def void triggerWaiting(IScheduler scheduler) {
		//printf("CStep::done %s: %s is done - waitfor=%d\n", getQualifiedName().c_str(), step->getQualifiedName().c_str(), _waitFor.size());
	
//		Vector::iterator iter = find(_waitFor.begin(), _waitFor.end(), step);
//		if (iter==_waitFor.end()) {
//			// todo: error handling
//			printf("ERROR in step '%s' at CStep::done('%s'): inconsistent data model\n",
//						getQualifiedName().c_str(),
//						step->getQualifiedName().c_str());
//	//		throw 99;
//	//		exit(1);
//		}
//		else {
//			// we are no more waiting for this step, because it is done
//			_waitFor.erase(iter);
//		}
	
//		bool runNow = false;
//		if (_waitFor.size()==0) {
//			// waiting is over
//			if (_isFirst) {
//				// first step has to ask behavior if trigger has been received yet
//				if (_bhvr.isRunning()) {
//					runNow = true;
//				}
//			} else {
//				// non-first steps can run immediately
//				runNow = true;
//			}
//		}
//		if (runNow) {
//			eventAcceptor.setReady(this);
			scheduler.addJob(this)
//		}
//		eventAcceptor.signalReady(step, this, runNow);
		}
}
