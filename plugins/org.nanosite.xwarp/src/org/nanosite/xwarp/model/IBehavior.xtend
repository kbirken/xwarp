package org.nanosite.xwarp.model

import java.util.List

interface IBehavior extends IStepSuccessor, INamed {
	def String getQualifiedName()
	def boolean shouldAddToken()
	
	def IStep getFirstStep()
	def boolean isLastStep(IStep step)

	def List<IBehavior> getSendTriggers()
}
