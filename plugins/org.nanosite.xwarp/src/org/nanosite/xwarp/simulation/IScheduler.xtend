package org.nanosite.xwarp.simulation

interface IScheduler {
	
	def void createWaitingJob(IJob job)
	def void activateJob(IJob job)
	
	def long getCurrentTime()
}
