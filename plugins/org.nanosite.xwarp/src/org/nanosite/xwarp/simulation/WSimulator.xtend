package org.nanosite.xwarp.simulation

import java.util.List
import java.util.Map
import org.nanosite.xwarp.model.IModel
import org.nanosite.xwarp.model.IResource
import org.nanosite.xwarp.result.SimResult

class WSimulator implements IScheduler {

	val ILogger logger
	
	var long time
	val List<IJob> readyList = newArrayList
	val List<IJob> runningList = newArrayList
	
	val WSimState state

	val result = new SimResult
	
	new(ILogger logger) {
		this.logger = logger
		this.state = new WSimState(logger)
	}
	
	def SimResult simulate(IModel model) {
		
		// set simulation time
		time = 0L
		
		// reset SimState and SimResult
		state.clear
		result.clear
		
		// initialize readyList
		readyList.clear
		for(behavior : model.initial) {
			val active = state.getActiveBehavior(behavior, this)
			val token = WToken.create(behavior.qualifiedName, logger)
			val msg = new WMessage(token)
			active.receiveTrigger(msg)
		}
		
		// iterate through time
		var healthy = true
		var iteration = 0
		var nMax = 99 // 19999
		//pools.init
		while (healthy && iteration<=nMax && (!readyList.empty || !runningList.empty)) {
			logger.log(1,
				ILogger.Type.INFO,
				'''ITER «String.format("%5d", iteration)»   (ready=«readyList.size»  running=«runningList.size»)'''
			)

			val ok = doIteration(model.resources/*pools, scheds, isLimited, loadfile*/);
			if (!ok) {
				// error message is printed inside iteration()
				return null
			}
			iteration++
		}
		
		if (iteration>=nMax) {
			logger.log(1,
				ILogger.Type.INFO,
				'''simulation ended due to max number of iterations (max=«nMax»)'''
			)
		}
		
		result
	}

	def private boolean doIteration(List<IResource> allResources) {
		// transfer ready steps to running (this might lead to new ready steps in between)
		while (!readyList.empty) {
			// copy ready list because loop might insert new jobs
			val todo = readyList.clone
			readyList.clear
	
			// handle current set of ready steps
			for (job : todo) {
				log(1, ILogger.Type.RUNNING, job.qualifiedName)
				//_runningMap[step] = _time;
	
				// alloc/free pool resources of this step
//				bool ok = pools.apply(step->getPoolRequests(), step, *this);
//				if (!ok) {
//					return false;
//				}
	
				if (job.hasResourceNeeds) {
					runningList.add(job)
					job.traceRunning(time)
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
		val Map<IResource, WResourceUsage> resourceUsages = newHashMap
		for(job : runningList) {
			for(res : job.resourceNeeds.keySet) {
				if (! resourceUsages.containsKey(res)) {
					resourceUsages.put(res, new WResourceUsage(res))
				}
				val amount = job.resourceNeeds.get(res)
				resourceUsages.get(res).request(amount, job)
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
			for(res : allResources) {
				val ru = resourceUsages.get(res)
				if (ru!==null)
					sb.append(ru.logUsedByJob(job))
				else
					sb.append(WResourceUsage.logNotUsed)
			}
			sb.append("\t")
			sb.append(job.qualifiedName)
			log(3, ILogger.Type.DEBUG, sb.toString)
		}
		resourceUsages.values.forEach[computeMin]
	
		val long overallMinDelta = if (resourceUsages.empty) 0L else resourceUsages.values.map[min].min
//		val boolean logstart = true;
		val sb = new StringBuilder
		for(res : resourceUsages.keySet) {
//			val ru = resourceUsages.get(res)
//			//val long minDelta = isLimited[r] ? (mins[r] * nRequests[r]) : mins[r];
			sb.append(resourceUsages.get(res).asString)
			sb.append(" ")
		}
		log(2, ILogger.Type.DEBUG, sb.toString)

//		// record detailed results
		val tDelta = WIntAccuracy.toPrint(overallMinDelta)
//		result::CIterationResult* result = new result::CIterationResult(tDelta);
//		_results.add(result);
//		for(unsigned r=0; r<nRequests.size(); r++) {
//			result->addResourceUsage(resources[r], stepsPerResource[r]);
//		}
//	
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
//	
		// progress in time
//		if (_verbose>1) {
//			string loads = "";
//			// update book-keeping
//			for(unsigned r=0; r<nRequests.size(); r++) {
//				if (nRequests[r] > 0) {
//					sums[r] -= overallMinDelta;
//	
//					// limit sum to positive values
//					if (sums[r]<0) {
//						sums[r] = 0;
//					}
//				}
//			}
//			for(unsigned r=1; r<nRequests.size(); r++) {
//				if (nRequests[r] > 0) {
//					static char txt[128];
//					sprintf(txt, "%s/%d", resources[r]->getName(), CIntAccuracy::toPrint(sums[r]));
//					loads += string(" ") + string(txt);
//				}
//			}
			val sb1 = new StringBuilder
			sb1.append('''DELTA=«tDelta» ''')
			for(res : allResources) {
				val ru = resourceUsages.get(res)
				if (ru!==null) {
					val remaining = ru.sum - overallMinDelta
					sb1.append(''' «res.name»/«WIntAccuracy.toPrint(remaining)»''')
				}
			}
			log(1, ILogger.Type.INFO, sb1.toString)
//		}
//	
//		// overflow check
//		if (overallMinDelta<0) {
//			fatal("arithmetic overflow (DELTA=%d)\n", overallMinDelta);
//			return false;
//		}
//	
		time += overallMinDelta;
		logger.updateCurrentTime(time)

		// overflow check
		if (time<0) {
			//fatal("arithmetic overflow (TIME=%d)\n", time);
			return false
		}

		resourceUsages.values.forEach[consume(overallMinDelta)]
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

	override void addJob(IJob job) {
		log(1, ILogger.Type.READY, job.qualifiedName)
		readyList.add(job)
		job.traceReady(time)
	}

	def private void jobDone(IJob job) {
		job.exitActions()
		log(1, ILogger.Type.DONE, job.qualifiedName)
		job.traceDone(time)
//		drawNode(step);
//		_doneMap[step] = _time;

		// collect simulation result data from job and add it to overall simulation result 
		result.addInstance(job.result)
	}
	
	def private log(int level, ILogger.Type type, String msg) {
		logger.log(level, type, msg)
	}

}
