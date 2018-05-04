package org.nanosite.xwarp.simulation

import java.util.List
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.model.IStepSuccessor

class WActiveBehavior {

	val IBehavior behavior
	val ISimState state 
	val IScheduler scheduler
	val ILogger logger
	
	val WMessageQueue queue = new WMessageQueue
	var WMessage currentMessage = null
	var iteration = 0
	
	new(
		IBehavior behavior,
		ISimState state,
		IScheduler scheduler,
		ILogger logger
	) {
		this.behavior = behavior
		this.state = state
		this.scheduler = scheduler
		this.logger = logger
	}

	def String getQualifiedName() {
		behavior.qualifiedName
	}
	
	def void receiveTrigger(WActiveStep from, WMessage msg) {
		log(2, msg, "RECV ")
		
		if (currentMessage!==null) {
			// we are busy, just queue this message
			queue.push(msg)
		} else {
			// set iteration count for repeat-loops
			iteration = 0
			currentMessage = msg
			log(2, currentMessage, "START")
			handleTrigger(from)
		}
	}
	
	def void handleTrigger(WActiveStep from) {
		val firstStep = behavior.firstStep
		if (firstStep===null) {
			// there are no steps in this behavior, recursively call send triggers
//			int n = 1;
//			if (_type==LOOP_TYPE_REPEAT) {
//				n = _p;
//			}
//			if (_type==LOOP_TYPE_UNLESS) {
//				logger.fatal("invalid behavior %s: unless-condition given, but no steps", getQualifiedName().c_str());
//			}
//			for(int i=0; i<n; i++) {
//				sendTriggers(from, eventAcceptor, logger);
//			}
//	
//			// prepare for next incoming message
//			closeAction(logger);
		} else {
			val job = state.getActiveStep(firstStep, this)
			if (job.isWaiting) {
				// this step is waiting for preconditions and will be started later
//				if (! (_type==LOOP_TYPE_UNLESS && _iteration>0)) {
//					eventAcceptor.signalSend(from, first, false);
//				}
			} else {
				// immediately provide first step to scheduler
				scheduler.addJob(job)
//				if (! (_type==LOOP_TYPE_UNLESS && _iteration>0)) {
//					eventAcceptor.signalSend(from, first, !firstStep.waiting);
//				}
			}
		}
	}

	// this will be called by the behavior's first step (if waiting for preconditions is over)
	def boolean isRunning() {
		currentMessage!==null
	}

	def void exitActionsForStep(WActiveStep step, List<IStepSuccessor> successors) {
		// all has been consumed => tell successors that we are ready
		for(succ : successors) {
			if (succ instanceof IStep) {
				val simStep = state.getActiveStep(succ, this)
				simStep.triggerWaiting(step, scheduler)
			} else if (succ instanceof IBehavior) {
				val simBehavior = state.getActiveBehavior(succ, scheduler)
				simBehavior.done
			}
		}
		
		// if this is the last step in one behavior, also tell behavior that we are ready
		if (behavior.isLastStep(step.step)) {
			lastStepDone(step)
		}
	}

	// this is called to set 'unless' conditions
	def private void done() {
		println("TODO")
		// we simply clear unless condition (forever)
		// this will be checked before any execution of the loop
//		_current_unless_condition = true;
	}

	def private void lastStepDone(WActiveStep from) {
//		_finished_once = true;
	
		// last step is done, send triggers
		sendTriggers(from)
	
		// prepare steps for next iteration or trigger
//		prepareExecution();
	
//		_global_iteration++;
//		_iteration++;
	
		// TODO: fully implement "repeat" handling based on _type
//		switch (_type) {
//		case LOOP_TYPE_ONCE:
//			// simple behavior, one execution per trigger
//			break;
//		case LOOP_TYPE_REPEAT:
//			// repeat-loop (_p is loop count)
//			if (_iteration<_p) {
//				handleTrigger(from, eventAcceptor, logger);
//				return;
//			}
//			break;
//		case LOOP_TYPE_UNTIL:
//			// NIY
//			logger.fatal("invalid behavior %s - type %d not yet implemented\n", getQualifiedName().c_str(), _type);
//			break;
//		case LOOP_TYPE_UNLESS:
//			if (! _current_unless_condition) {
//				/*
//				logger.log("INFO", "still waiting for unless condition in behavior %s: %s",
//						getQualifiedName().c_str(),
//						_unless_condition->getQualifiedName().c_str());
//				*/
//	
//				// unless condition still false, do another loop
//				handleTrigger(from, eventAcceptor, logger);
//				return;
//			} else {
//				// unless condition is active, loop ends here
//				eventAcceptor.signalUnless(_unless_condition, from);
//			}
//			break;
//		default:
//			// shouldn't happen
//			logger.fatal("invalid behavior %s - unknown type %d\n", getQualifiedName().c_str(), _type);
//		}
	
		// prepare for next incoming message
		iteration = 0
		closeAction()
	
		// check if next message is already waiting
		if (! queue.empty) {
			currentMessage = queue.pop
			log(2, currentMessage, "START")
			val simState = state.getActiveStep(behavior.lastStep, this)
			handleTrigger(simState)
		}
	}

	def private void closeAction() {
		log(2, currentMessage, "READY")
		currentMessage = null
	}

	def void sendTriggers(WActiveStep from) {
		// send triggers to successor behaviors
		val token = currentMessage.token
		for(triggered : behavior.sendTriggers) {
			val msg = new WMessage(
				if (behavior.shouldAddToken) {
					// this behavior generates its own tokens
					genToken(token, triggered)
				} else
					token
			)

			val simBehavior = state.getActiveBehavior(triggered, scheduler)
			simBehavior.receiveTrigger(from, msg)
		}
	}

	def WToken genToken(WToken parent, IBehavior next) {
		val info = next.qualifiedName
		//if (_type!=LOOP_TYPE_ONCE) {
		//sprintf(buf, "%d", _iteration);
		//info += "%" + string(buf);
		//}

		WToken.create(info, parent, logger)
	}

	
	def private void log(int level, WMessage msg, String action) {
		logger.log(
			level,
			ILogger.Type.TOKEN,
			'''«msg.name» «action» at «qualifiedName»'''
		)
	}

	override String toString() {
		'''WActiveBehavior(«behavior.toString»)'''
	}
}
