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
import org.nanosite.xwarp.simulation.IQueue.PushResult

/**
 * Representation of a behavior's state during the simulation. 
 */
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
	
	/**
	 * Receive a trigger and start execution of this behavior.</p>
	 * 
	 * The trigger might come from another behavior (via 'send') or
	 * it might be an initial trigger.</p>
	 */
	def void receiveTrigger(WMessage msg, int inputIndex, long tCurrent) {
		log(2, msg, "RECV ")
	
		// always queue incoming messages, the queue will decide if some work results from this
		val result = queue.push(inputIndex, msg, tCurrent)
		if (result!==PushResult.OK) {
			val loc = this.behavior.qualifiedName + " queue #" + inputIndex
			logger.log(2, ILogger.Type.INFO, "Queue overflow at " + loc)
			if (result==PushResult.ABORT_SIMULATION) {
				throw new IScheduler.QueueAbortException(this.behavior, inputIndex)
			}
		}
		
		if (currentMessage!==null) {
			// we are busy, do nothing now
		} else {
			// we are free, check if we can do more work
			getNextFromQueue(false)
		}
	}

	/**
	 * Check if there is a valid piece of work in the queue and handle it.</p>
	 * 
	 * The piece of work might be a single message or a set of messages,
	 * depending on the configuration of the queue.</p> 
	 */
	def private void getNextFromQueue(boolean isFollowup) {
		if (queue.mayPop(scheduler.currentTime)) {
			val msgs = queue.pop
			currentMessage = msgs.merge
							
			// set iteration count for repeat-loops
			iteration = 0

			// execute behavior based on the message(s) from queue
			log(2, currentMessage, "START")
			val triggeredBy = msgs.map[sender]
			handleTrigger(currentMessage, triggeredBy, isFollowup)
		}
	}
	
	/**
	 * Execute the behavior based on the trigger.
	 */
	def private void handleTrigger(WMessage msg, Collection<StepInstance> triggeredBy, boolean isFollowup) {
		// check if incoming message has a valid payload 
		if (msg.isPayloadValid) {
			// yes, increase number of valid payload cycles
			if (iPayloadCycle < behavior.NRequiredCycles) {
				iPayloadCycle++
			}
		}
		
		result.startedTime = scheduler.currentTime
		execute(triggeredBy, isFollowup)
	}
	
	/**
	 * Start execution of behavior by scheduling its first step.</p>
	 * 
	 * Note that if the step has to wait for a precondition,
	 * it will not be activated, but put into the scheduler's wait-queue
	 * instead.</p>
	 */
	def private void execute(Collection<StepInstance> triggeredBy, boolean isFollowup) {
		val firstStep = behavior.firstStep
		val job = state.getActiveStep(firstStep, this)
		if (job.isWaiting) {
			// this step is waiting for preconditions and will be started later
			scheduler.createWaitingJob(job)
		} else {
			// immediately provide first step to scheduler
			scheduler.activateJob(job)
		}
		
		// do tracing of predecessors of various kinds
		if (isFollowup) {
			val previous = state.getActiveStep(behavior.lastStep, this)
			job.tracePredecessor(
				previous.previousResult,
				if (iteration>0) Predecessor.Type.LOOP else Predecessor.Type.FOLLOWUP
			)
		}
		if (! triggeredBy.nullOrEmpty)
			job.tracePredecessors(triggeredBy, Predecessor.Type.TRIGGER)
	}

	/**
	 * Check if the behavior is currently running (i.e., busy).</p>
	 * 
	 * This will be called by the behavior's first step (if waiting for
	 * preconditions is over).
	 */
	def boolean isRunning() {
		currentMessage!==null
	}

	/**
	 * Check if the behavior has at least finished one time.</p>
	 */
	def boolean hasFinishedOnce() {
		finishedOnce
	}
	
	/**
	 * Get number of executions until the output data is valid.</p>
	 */
	def int getNMissingCycles() {
 		behavior.NRequiredCycles - iPayloadCycle
 	}
 	
	/**
	 * Execute activities which are necessary after a step is done.</p>
	 * 
	 * This might either unblock successor steps or stop another behavior
	 * which has a repeat-unless block.</p>
	 */
	def void exitActionsForStep(WActiveStep step, List<IStepSuccessor> successors) {
		// all has been consumed => tell successors that we are ready
		for(succ : successors) {
			if (succ instanceof IStep) {
				val simBehavior = state.getActiveBehavior(succ.owner, scheduler, recorder)
				val simStep = state.getActiveStep(succ, simBehavior)
				simStep.triggerWaiting(step, scheduler)
			} else if (succ instanceof IBehavior) {
				// signal to behavior that unless-condition is now true
				val simBehavior = state.getActiveBehavior(succ, scheduler, recorder)
				simBehavior.signalUnlessCondition(step)
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
	
	def boolean isPartOfNoProgressInfiniteLoop() {
		behavior.partOfNoProgressInfiniteLoop
	}

	def private void signalUnlessCondition(WActiveStep signalledBy) {
		// we simply clear unless condition (forever)
		// this will be checked before any execution of the loop
		currentUnlessCondition = signalledBy
	}

	/**
	 * This finalizes one execution of this behavior's steps.</p>
	 * 
	 * Note: If this is a looped behavior, this method will be called
	 * for each loop iteration.</p>
	 */
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
			execute(null, true)
		} else if (behavior.unlessCondition!==null) {
			if (currentUnlessCondition===null) {
				/*
				logger.log("INFO", "still waiting for unless condition in behavior %s: %s",
						getQualifiedName().c_str(),
						_unless_condition->getQualifiedName().c_str());
				*/
	
				// unless condition still false, do another loop
				execute(null, true)
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
	
	def private void closeAction() {
		recordResult()

		iteration = 0
		
		// create WMessage just for reporting
		val msg = buildMessage(currentMessage.token, null, null)
		log(2, msg, "DONE ")
		currentMessage = null
	}
	
 	/**
 	 * Send triggers to all successive behaviors.</p>
 	 */
	def private void sendTriggers(WActiveStep from) {
		// send triggers to successor behaviors
		val token = currentMessage.token
		for(trigger : behavior.sendTriggers) {
			val msg = buildMessage(token, trigger.behavior, from.previousResult)
			val simBehavior = state.getActiveBehavior(trigger.behavior, scheduler, recorder)
			simBehavior.receiveTrigger(msg, trigger.inputIndex, scheduler.currentTime)
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
	def private WMessage buildMessage(WToken token, IBehavior triggered, StepInstance previous) {
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

	def private WToken genToken(WToken parent, IBehavior next) {
		val isLoop = behavior.NIterations>1
		val info = '''«next.qualifiedName»«IF isLoop»%«iteration»«ENDIF»'''
		WToken.create(info, parent, logger)
	}

	def private void recordResult() {
		// record result of the execution of this behavior instance
		result.queueStatistics = queue.statistics
		recorder.addBehaviorResult(result)
		result = new BehaviorInstance(behavior)
	}
	
	/**
	 * Create a new empty StepInstance for recording results.</p>
	 * 
	 * Note: This is used only for behaviors without steps.</p>
	 */
	def createStepResult() {
		new StepInstance(behavior)
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
