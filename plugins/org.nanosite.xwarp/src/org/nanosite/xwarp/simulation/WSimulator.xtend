package org.nanosite.xwarp.simulation

import com.google.common.collect.Sets
import java.util.List
import java.util.Map
import java.util.Set
import org.nanosite.xwarp.model.IAllocatingConsumable
import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.model.IScheduledConsumable
import org.nanosite.xwarp.model.impl.WUnlimitedResource
import org.nanosite.xwarp.result.ISimResult
import org.nanosite.xwarp.result.IterationResult
import org.nanosite.xwarp.result.SimResult

class WSimulator implements IScheduler {

	val ILogger logger
	
	/** maximum number of iterations */
	var nMaxIter = 1999

	/** constant for "no simulated time limit" */
	val static tLimitNone = -1L
	
	/** simulated time limit (in microseconds) */
	var tLimit = tLimitNone
	
	/** current simulated time */	
	var long time
	
	val List<IJob> readyList = newArrayList
	val List<IJob> runningList = newArrayList
	
	val WSimState state

	val result = new SimResult
	
	new(ILogger logger) {
		this.logger = logger
		this.state = new WSimState(logger)
	}
	
	def setNMaxIterations(int nMax) {
		this.nMaxIter = nMax
	}
	
	/**
	 * Set limit for simulated time (in microseconds)
	 */
	def setTimeLimit(long tLimit) {
		this.tLimit = tLimit
	}
	
	def ISimResult simulate(IModel model) {
		
		// set simulated time
		time = 0L
		
		// reset SimState and SimResult
		state.clear
		result.clear
		
		// initialize readyList
		readyList.clear
		for(trigger : model.initial) {
			val behavior = trigger.behavior
			val active = state.getActiveBehavior(behavior, this, result)
			val token = WToken.create(behavior.qualifiedName, logger)
			val msg = new WMessage(token, null)
			active.receiveTrigger(msg, trigger.inputIndex, time)
		}
		
		// iterate through time
		var healthy = true
		var iteration = 0
		val tLimitCalc =
			if (tLimit==tLimitNone)
				tLimitNone
			else
				WIntAccuracy.toCalc(tLimit)
		while (
			healthy &&
			iteration<=nMaxIter &&
			(tLimitCalc==tLimitNone || time<tLimitCalc) &&
			(!readyList.empty || !runningList.empty)
		) {
			logger.log(1,
				ILogger.Type.INFO,
				'''ITER «String.format("%5d", iteration)»   (ready=«readyList.size»  running=«runningList.size»)'''
			)

			val ok = doIteration(
				model.scheduledConsumables,
				model.allocatingConsumables,
				iteration
				/*scheds, isLimited, loadfile*/
			);
			if (!ok) {
				// error message is printed inside iteration()
				return null
			}
			iteration++
		}
		
		if (iteration >= nMaxIter) {
			result.setReachedMaxIterations
			logger.log(1,
				ILogger.Type.INFO,
				'''simulation ended due to max number of iterations (max=«nMaxIter»)'''
			)
		}
		
		if (tLimit!=tLimitNone && time >= tLimitCalc) {
			result.setReachedTimeLimit
			logger.log(1,
				ILogger.Type.INFO,
				'''simulation ended due to time limit reached (tLimit=«tLimit»)'''
			)
		}
		
		// copy all pool states to simulation result
		state.poolStates.forEach[result.addPoolState(it)]
		
		// store all behaviors in simulation result which haven't been executed at least once
		val started = state.activeBehaviors.keySet
		val startedAndNeverFinished = state.activeBehaviors.filter[bhvr, state | ! state.hasFinishedOnce].keySet
		val allBehaviors = model.consumers.map[behaviors].flatten.toSet
		val neverStarted = Sets.difference(allBehaviors, started)
		result.addRemainingBehaviors(startedAndNeverFinished)
		result.addRemainingBehaviors(neverStarted)

		result
	}
	
	def private boolean doIteration(
		List<IScheduledConsumable> allScheduledConsumables,
		List<IAllocatingConsumable> allPools,
		int nIteration
	) {
		// transfer ready steps to running (this might lead to new ready steps in between)
		val Set<IJob> visited = newHashSet
		while (!readyList.empty) {
			// if the same job shows up in the ready list twice in the same iteration, 
			// this is a cycle without progress. We have to kill it in order to avoid an endless loop.
			val cyclic = Sets.intersection(visited, readyList.toSet)
			for(job : cyclic) {
				logger.error(
					'''cyclic dependency in current iteration, killed «job.qualifiedName»'''
				)
				job.notifyKilled
			}
			readyList.removeAll(cyclic)
			
			// copy ready list because loop might insert new jobs
			val todo = readyList.clone
			readyList.clear
	
			// handle current set of ready steps
			for (job : todo) {
				visited.add(job)
				
				if (job.shouldLog)
					log(1, ILogger.Type.RUNNING, job.qualifiedName)
				//_runningMap[step] = _time;
	
				// alloc/free pool resources of this step
				for(pn : job.poolNeeds.entrySet) {
					val poolState = state.getPoolState(pn.key)
					poolState.handleRequest(pn.value)

					// record current state of this pool as a result
					if (job.result!==null)
						job.result.addPoolState(pn.key,
							poolState.allocated,
							poolState.NOverflows>0,
							poolState.NUnderflows>0
						)
				}
	
				job.traceRunning(time)
				if (job.hasConsumableNeeds) {
					runningList.add(job)
				} else {
					// this is a job with zero resource usage, it is already done
					jobDone(job)
				}
			}
		}
	
	
		// compute sum of requests of all 'running' steps for each ResourceSlot (absolute value and count)
//		CResourceVector sums;
	
//		vector<int> nRequests;
//		vector<vector<int> > stepsPerResource;
//		nRequests.resize(sums.size());
//		stepsPerResource.resize(sums.size());
		val Map<IScheduledConsumable, WScheduledConsumableUsage> resourceUsages = newHashMap
		for(job : runningList) {
			for(res : job.consumableNeeds.keySet) {
				if (! resourceUsages.containsKey(res)) {
					resourceUsages.put(res, new WScheduledConsumableUsage(res))
				}
				val amount = job.consumableNeeds.get(res)
				resourceUsages.get(res).request(amount.amount, job)
			}
//			for(unsigned i=0; i<sums.size(); i++) {
//				CStep* step = *it;
//				int rn = step->getCurrentResourceNeeds()[i];
//				if (rn > 0) {
//					sums[i] += rn;
//					nRequests[i]++;
//					stepsPerResource[i].push_back(step->getID());
//				}
//			}
		}
	
	
		// for all APS-scheduled resources: compute #requests per partition
//		for(Schedulers::iterator si=scheds.begin(); si!=scheds.end(); ++si) {
//			si->second->clear();
//		}
//		for (CStep::Vector::const_iterator it = _running.begin(); it!=_running.end(); it++) {
//			CStep* step = *it;
//			if (step->getCurrentResourceNeeds()[step->getCPU()]) {
//				int part = step->getPartition();
//				Schedulers::iterator si = scheds.find(step->getCPU());
//				if (si!=scheds.end()) {
//					si->second->addRequest(part);
//				}
//			}
//		}
//		if (_verbose>1) {
//			for(Schedulers::iterator si=scheds.begin(); si!=scheds.end(); ++si) {
//				int r = si->first;
//				CAPSScheduler* aps = si->second;
//				const model::Resource& res = *(resources[r]);
//				bool logstart = false;
//				for(unsigned int p=0; p<res.getNPartitions(); p++) {
//					if (aps->getNReqPerPartition(p)>0) {
//						if (!logstart) {
//							logstart = true;
//							log("SCHED", "%s=APS: ", res.getName());
//						}
//						printf(" %s/%i/%d/%d",
//								res.getPartitionName(p).c_str(), p,
//								(res.getPartitionSize(p)*1000) / aps->getUsedPartitionsSize(),
//								aps->getNReqPerPartition(p)
//						);
//					}
//				}
//				if (logstart) {
//					printf("\n");
//				}
//			}
//		}
//	
		// determine next interesting time (= minimum delta of all steps)
//		CResourceVector mins(INT_MAX);
//		for (CStep::Vector::const_iterator it = _running.begin(); it!=_running.end(); it++) {
//		for(job : runningList) {
//			val int partNReqs = 0
//			val int partSize = 1
//			val int partAllSize = 1
//			val int part = (*it)->getPartition()
//			Schedulers::iterator si = scheds.find((*it)->getCPU());
//			if (si!=scheds.end()) {
//				CAPSScheduler* aps = si->second;
//				partNReqs = aps->getNReqPerPartition(part);
//				partSize = aps->getPartitionSize(part);
//				partAllSize = aps->getUsedPartitionsSize();
//			}
//	
//			bool ok = (*it)->checkSmallestRequests(nRequests, mins, partNReqs, partSize, partAllSize, *this);
//			val ok = job.checkSmallestRequests(nRequests, mins, partNReqs, partSize, partAllSize, *this)
			
//			if (!ok) {
//				return false;
//			}
//		}
		for(job : runningList) {
			val sb = new StringBuffer
			sb.append("    ")
			for(consumable : allScheduledConsumables) {
				//sb.append("|" + consumable.name + " ")
				val ru = resourceUsages.get(consumable)
				if (ru!==null)
					sb.append(ru.logUsedByJob(job))
				else
					sb.append(WScheduledConsumableUsage.logNotUsed)
			}
			sb.append("\t")
			sb.append(job.qualifiedName)
			log(3, ILogger.Type.DEBUG, sb.toString)
		}
		resourceUsages.values.forEach[computeMin]
	
		val long overallMinDelta =
			if (resourceUsages.empty) 0L else resourceUsages.values.map[minDelta].min
//		val boolean logstart = true;
		val sb = new StringBuilder
		for(res : allScheduledConsumables) {
			val ru = resourceUsages.get(res)
			if (ru!==null) {
				sb.append(ru.asString)
			}
		}
		if (sb.length>0)
			log(3, ILogger.Type.DEBUG, sb.toString)

		// record detailed results
		val tDelta = WIntAccuracy.toPrint(overallMinDelta)
		val IterationResult iterationResult =
			new IterationResult(nIteration, tDelta, WUnlimitedResource.waitResource)
		result.addIteration(iterationResult)
		for(res : resourceUsages.keySet) {
			val users = resourceUsages.get(res).users.filter(WActiveStep).map[step]
			iterationResult.addResourceUsage(res, users)
		}
	
//		// output to loadfile
//		int dt = CIntAccuracy::toCalc(_timeWindowDiscrete);
//		if (loadfile) {
//			// TODO: we are producing some inaccuracies at the iteration boundaries here
//			while (_timeDiscrete+dt < _time+overallMinDelta) {
//				fprintf(loadfile, "%06d;", _timeslotDiscrete);
//	
//				// TODO: preparing a 0/1 array once outside while() would be more efficient
//				for(unsigned r=1 /* skip waittime */; r<nRequests.size(); r++) {
//					int resLoad = 0;
//					if (nRequests[r] > 0) {
//						resLoad = 1;
//					}
//					fprintf(loadfile, "%d;", resLoad);
//				}
//	
//				fprintf(loadfile, "\n");
//	
//				_timeDiscrete += dt;
//				_timeslotDiscrete++;
//			}
//		}
	
		val sb1 = new StringBuilder
		sb1.append('''DELTA=«tDelta» ''')
		for(res : allScheduledConsumables) {
			val ru = resourceUsages.get(res)
			if (ru!==null) {
				val remaining = ru.sum - overallMinDelta
				val remainingLimited = if (remaining<0) 0 else remaining
				sb1.append(''' «res.name»/«WIntAccuracy.toPrint(remainingLimited)»''')
			}
		}
		log(1, ILogger.Type.INFO, sb1.toString)
	
		// overflow check
		if (overallMinDelta<0) {
			logger.fatal('''arithmetic overflow (DELTA=«overallMinDelta»)''')
			return false
		}
	
		// progress in time
		time += overallMinDelta;
		logger.updateCurrentTime(time)

		// overflow check
		if (time<0) {
			logger.fatal('''arithmetic overflow (TIME=«time»)''')
			return false
		}

		resourceUsages.values.forEach[consume(overallMinDelta, logger)]
//		vector<int> nMaxRequests(nRequests.begin(), nRequests.end());
//		{
//			for (CStep::Vector::iterator it = _running.begin(); it!=_running.end();) {
//				int partNReqs = 0;
//				int partSize = 1;
//				int partAllSize = 1;
//				int part = (*it)->getPartition();
//				Schedulers::iterator si = scheds.find((*it)->getCPU());
//				if (si!=scheds.end()) {
//					CAPSScheduler* aps = si->second;
//					partNReqs = aps->getNReqPerPartition(part);
//					partSize = aps->getPartitionSize(part);
//					partAllSize = aps->getUsedPartitionsSize();
//				}
//	
//				if ((*it)->consume(overallMinDelta, isLimited, nMaxRequests, partNReqs, partSize, partAllSize, *this)) {
//					// this step is done and can be consumed
//					stepDone(*it);
//					it = _running.erase(it);
//				}
//				else {
//					it++;
//				}
//			}
//		}
		for(job : runningList.clone) {
			if (job.isDone()) {
				runningList.remove(job)
				jobDone(job)
			}
		}
	
		true
	}

	override void createWaitingJob(IJob job) {
		if (job.shouldLog)
			log(1, ILogger.Type.WAITING, job.qualifiedName)
		job.traceWaiting(time)
	}

	override void activateJob(IJob job) {
		if (job.shouldLog)
			log(1, ILogger.Type.READY, job.qualifiedName)
		readyList.add(job)
		job.traceReady(time)
	}
	
	override long getCurrentTime() {
		time
	}
	
	def private void jobDone(IJob job) {
		job.traceDone(time)
		job.exitActions(result)
		
		if (job.shouldLog)
			log(1, ILogger.Type.DONE, job.qualifiedName)
//		drawNode(step);
//		_doneMap[step] = _time;
	}
	
	def private log(int level, ILogger.Type type, String msg) {
		logger.log(level, type, msg)
	}

}
