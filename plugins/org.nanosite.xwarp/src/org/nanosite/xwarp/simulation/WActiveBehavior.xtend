package org.nanosite.xwarp.simulation

import java.util.Collection
import java.util.List
import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IStep
import org.nanosite.xwarp.model.IStepSuccessor
import org.nanosite.xwarp.result.BehaviorInstance
import org.nanosite.xwarp.result.IResultRecorder
import org.nanosite.xwarp.result.StepInstance
import org.nanosite.xwarp.result.StepInstance.Predecessor

class WActiveBehavior {

	val IBehavior behavior
	val ISimState state 
	val IScheduler scheduler
	val ILogger logger
	val IResultRecorder recorder
	
	val WMultiQueue queue
	var WMessage currentMessage = null

	var iteration = 0
	var WActiveStep currentUnlessCondition = null
	var finishedOnce = false
	
	var iPayloadCycle = 0
	
	var BehaviorInstance result
	
	new(
		IBehavior behavior,
		ISimState state,
		IScheduler scheduler,
		ILogger logger,
		IResultRecorder recorder
	) {
		this.behavior = behavior
		this.state = state
		this.scheduler = scheduler
		this.logger = logger
		this.recorder = recorder
		this.queue = new WMultiQueue(behavior.queueConfig)
		
		this.result = new BehaviorInstance(behavior)
	}

	def String getQualifiedName() {
		behavior.qualifiedName
	}
	
	def void receiveTrigger(WMessage msg, int inputIndex) {
		log(2, msg, "RECV ")
	
		// always queue incoming messages, the queue will decide if some work results from this
		queue.push(inputIndex, msg)
		
		if (currentMessage!==null) {
			// we are busy, do nothing now
		} else {
			// we are free, check if we can do more work
			getNextFromQueue(false)
		}
	}
	
	def private void handleTrigger(WMessage msg, Collection<StepInstance> from) {
		// check if incoming message has a valid payload 
		if (msg.isPayloadValid) {
			// yes, increase number of valid payload cycles
			if (iPayloadCycle < behavior.NRequiredCycles) {
				iPayloadCycle++
			}
		}
		
		result.startedTime = scheduler.currentTime
		
		handleTriggerInternal(from)
	}
	
	def private void handleTriggerInternal(Collection<StepInstance> from) {
		val firstStep = behavior.firstStep
		val job = state.getActiveStep(firstStep, this)
		if (job.isWaiting) {
			// this step is waiting for preconditions and will be started later
			scheduler.createWaitingJob(job)
		} else {
			// immediately provide first step to scheduler
			scheduler.activateJob(job)
		}
		job.tracePredecessors(
			from,
			if (iteration>0) Predecessor.Type.LOOP else Predecessor.Type.TRIGGER
		)
	}

	// this will be called by the behavior's first step (if waiting for preconditions is over)
	def boolean isRunning() {
		currentMessage!==null
	}
	
	def void exitActionsForStep(WActiveStep step, List<IStepSuccessor> successors) {
		// all has been consumed => tell successors that we are ready
		for(succ : successors) {
			if (succ instanceof IStep) {
				val simBehavior = state.getActiveBehavior(succ.owner, scheduler, recorder)
				val simStep = state.getActiveStep(succ, simBehavior)
				simStep.triggerWaiting(step, scheduler)
			} else if (succ instanceof IBehavior) {
				val simBehavior = state.getActiveBehavior(succ, scheduler, recorder)
				simBehavior.done(step)
			}
		}
		
		// if this is the last step in one behavior, also tell behavior that we are ready
		if (behavior.isLastStep(step.step)) {
			lastStepDone(step)
		}
	}

	def void notifyKilled(WActiveStep step) {
		result.killedTime = scheduler.currentTime
		closeAction()
		
		// TODO: we could add checking the queue here and ensure that the behavior will
		// execute again if necessary. Without this it will be triggered on the next incoming message only.
	}

	// this is called to set 'unless' conditions
	def private void done(WActiveStep signalledBy) {
		// we simply clear unless condition (forever)
		// this will be checked before any execution of the loop
		currentUnlessCondition = signalledBy
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
		val predecessors = newArrayList(from.previousResult)
		if (iteration < behavior.NIterations) {
			// still iterations left, trigger myself
			handleTriggerInternal(predecessors)
		} else if (behavior.unlessCondition!==null) {
			if (currentUnlessCondition===null) {
				/*
				logger.log("INFO", "still waiting for unless condition in behavior %s: %s",
						getQualifiedName().c_str(),
						_unless_condition->getQualifiedName().c_str());
				*/
	
				// unless condition still false, do another loop
				handleTriggerInternal(predecessors)
			} else {
				// unless condition is active, loop ends here
				from.previousResult.addPredecessor(
					currentUnlessCondition.previousResult,
					Predecessor.Type.UNLESS_CONDITION
				)
			}
		} else {
			// last iteration
//			switch (_type) {
//			case LOOP_TYPE_UNTIL:
//				// NIY
//				logger.fatal("invalid behavior %s - type %d not yet implemented\n", getQualifiedName().c_str(), _type);
//				break;
			
			// prepare for next incoming message
			result.readyTime = scheduler.currentTime
			closeAction()
		
			// check if next message is already waiting
			getNextFromQueue(true)
		}
	}
	
	def private void getNextFromQueue(boolean isFollowup) {
		if (queue.mayPop) {
			val msgs = queue.pop
			currentMessage = msgs.merge
			
			// compute predecessors for simulation results
			// TODO: is there a more elegant way to create an iterator as a concat of two lists?
			val predecessors = newArrayList()
			predecessors.addAll(msgs.map[sender])
			if (isFollowup) {
				val previous = state.getActiveStep(behavior.lastStep, this)
				predecessors.add(previous.previousResult)
			}
							
			// set iteration count for repeat-loops
			iteration = 0

			// execute behavior based on the message(s) from queue
			log(2, currentMessage, "START")
			handleTrigger(currentMessage, predecessors)
		}
	}
	
	def private void closeAction() {
		recordResult()

		iteration = 0
		
		// create WMessage just for reporting
		val msg = buildMessage(currentMessage.token, null, null)
		log(2, msg, "DONE ")
		currentMessage = null
	}
	
	def int getNMissingCycles() {
 		behavior.NRequiredCycles - iPayloadCycle
 	}
 	
	def void sendTriggers(WActiveStep from) {
		// send triggers to successor behaviors
		val token = currentMessage.token
		for(trigger : behavior.sendTriggers) {
			val msg = buildMessage(token, trigger.behavior, from.previousResult)
			val simBehavior = state.getActiveBehavior(trigger.behavior, scheduler, recorder)
			simBehavior.receiveTrigger(msg, trigger.inputIndex)
		}
	}

	def private WMessage merge(List<WMessage> many) {
		if (many.size==1)
			many.head
		else {
			// more than one incoming message
			// we generate a new token
			// and compute payloadValid as the logical conjunction of all inputs 
			new WMessage(
				WToken.create(behavior.qualifiedName, many.map[token], logger),
				null, // TODO: which sender should we provide here, there might be >1
				many.forall[it.payloadValid]
			)
		}
			
	}

	/** Construct new message with existing token and valid-payload indicator */	
	def WMessage buildMessage(WToken token, IBehavior triggered, StepInstance previous) {
		val newToken =
			if (behavior.shouldAddToken && triggered!==null) {
				// this behavior generates its own tokens
				genToken(token, triggered)
			} else
				token 

		// compute valid-payload indicator
		val isValidPayload = iPayloadCycle==behavior.NRequiredCycles
		
		new WMessage(newToken, previous, isValidPayload)
	}

	def WToken genToken(WToken parent, IBehavior next) {
		val isLoop = behavior.NIterations>1
		val info = '''«next.qualifiedName»«IF isLoop»%«iteration»«ENDIF»'''
		WToken.create(info, parent, logger)
	}

	def boolean hasFinishedOnce() {
		finishedOnce
	}
	
	def private void recordResult() {
		// record result of the execution of this behavior instance
		recorder.addBehaviorResult(result)
		result = new BehaviorInstance(behavior)
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
