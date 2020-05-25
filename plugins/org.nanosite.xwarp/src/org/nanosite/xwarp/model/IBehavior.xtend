package org.nanosite.xwarp.model

import java.util.List

interface IBehavior extends IStepSuccessor, INamed {
	def String getQualifiedName()
	def boolean shouldAddToken()
	
	def WQueueConfig getQueueConfig()
	
	def int getNIterations()
	def IStep getUnlessCondition()
	
	def int getNRequiredCycles()
		
	def IStep getFirstStep()
	def IStep getLastStep()
	def boolean isLastStep(IStep step)

	def List<ITrigger> getSendTriggers()
	
	def boolean executesInZeroTime()
	def boolean isPartOfNoProgressInfiniteLoop()
}
