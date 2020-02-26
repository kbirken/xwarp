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
	var currentUnlessCondition = false
	var finishedOnce = false
	
	var iPayloadCycle = 0
	
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
			handleTrigger(msg, from)
		}
	}
	
	def private void handleTrigger(WMessage msg, WActiveStep from) {
		// check if incoming message has a valid payload 
		if (msg.isPayloadValid) {
			// yes, increase number of valid payload cycles
			if (iPayloadCycle < behavior.NRequiredCycles) {
				iPayloadCycle++
			}
		}
		
		handleTriggerInternal(from)
	}
	
	def private void handleTriggerInternal(WActiveStep from) {
		val firstStep = behavior.firstStep
		if (firstStep===null) {
			// there are no steps in this behavior, recursively call send triggers
			val n = behavior.NIterations
			if (behavior.unlessCondition !== null) {
				logger.fatal("invalid behavior " + qualifiedName + ": unless-condition given, but no steps")
			}
			for(i : 0..n-1) {
				sendTriggers(from)
			}
	
			// prepare for next incoming message
			closeAction()
		} else {
			val job = state.getActiveStep(firstStep, this)
			if (job.isWaiting) {
				// this step is waiting for preconditions and will be started later
				scheduler.createWaitingJob(job)
//				if (! (_type==LOOP_TYPE_UNLESS && _iteration>0)) {
//					eventAcceptor.signalSend(from, first, false);
//				}
			} else {
				// immediately provide first step to scheduler
				scheduler.activateJob(job)
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
				val simBehavior = state.getActiveBehavior(succ.owner, scheduler)
				val simStep = state.getActiveStep(succ, simBehavior)
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
		// we simply clear unless condition (forever)
		// this will be checked before any execution of the loop
		currentUnlessCondition = true
	}

	def private void lastStepDone(WActiveStep from) {
		finishedOnce = true
	
		// last step is done, send triggers
		sendTriggers(from)
	
		// prepare steps for next iteration or trigger
//		prepareExecution();
	
//		_global_iteration++;
		iteration++
	
		// TODO: fully implement "repeat" handling based on _type
		if (iteration < behavior.NIterations) {
			// still iterations left, trigger myself
			handleTriggerInternal(from)
		} else if (behavior.unlessCondition!==null) {
			if (! currentUnlessCondition) {
				/*
				logger.log("INFO", "still waiting for unless condition in behavior %s: %s",
						getQualifiedName().c_str(),
						_unless_condition->getQualifiedName().c_str());
				*/
	
				// unless condition still false, do another loop
				handleTriggerInternal(from)
			} else {
				// unless condition is active, loop ends here
//				eventAcceptor.signalUnless(_unless_condition, from);
			}
		} else {
			// last iteration
//			switch (_type) {
//			case LOOP_TYPE_UNTIL:
//				// NIY
//				logger.fatal("invalid behavior %s - type %d not yet implemented\n", getQualifiedName().c_str(), _type);
//				break;
	
			// prepare for next incoming message
			iteration = 0
			closeAction()
		
			// check if next message is already waiting
			if (! queue.empty) {
				currentMessage = queue.pop
				log(2, currentMessage, "START")
				val simState = state.getActiveStep(behavior.lastStep, this)
				handleTrigger(currentMessage, simState)
			}
		}
	}

	def private void closeAction() {
		val msg = buildMessage(currentMessage.token, null)
		log(2, msg, "READY")
		currentMessage = null
	}
	
	def int getNMissingCycles() {
 		behavior.NRequiredCycles - iPayloadCycle
 	}
 	
	def void sendTriggers(WActiveStep from) {
		// send triggers to successor behaviors
		val token = currentMessage.token
		for(triggered : behavior.sendTriggers) {
			val msg = buildMessage(token, triggered)
			val simBehavior = state.getActiveBehavior(triggered, scheduler)
			simBehavior.receiveTrigger(from, msg)
		}
	}

	/** Construct new message with existing token and valid-payload indicator */	
	def WMessage buildMessage(WToken token, IBehavior triggered) {
		val newToken =
			if (behavior.shouldAddToken && triggered!==null) {
				// this behavior generates its own tokens
				genToken(token, triggered)
			} else
				token 

		// compute valid-payload indicator
		val isValidPayload = iPayloadCycle==behavior.NRequiredCycles
		
		new WMessage(newToken, isValidPayload)
	}

	def WToken genToken(WToken parent, IBehavior next) {
		val isLoop = behavior.NIterations>1
		val info = '''«next.qualifiedName»«IF isLoop»%«iteration»«ENDIF»'''
		WToken.create(info, parent, logger)
	}

	def boolean hasFinishedOnce() {
		finishedOnce
	}
	
	def private void log(int level, WMessage msg, String action) {
		logger.log(
			level,
			ILogger.Type.TOKEN,
			'''«msg.taggedName» «action» at «qualifiedName»'''
		)
	}

	override String toString() {
		'''WActiveBehavior(«behavior.toString»)'''
	}
}
