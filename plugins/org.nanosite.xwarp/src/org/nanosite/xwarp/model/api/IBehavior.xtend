package org.nanosite.xwarp.model.api

interface IBehavior extends IStepSuccessor {
	def String getQualifiedName()
	def IStep getFirstStep()
	def boolean isLastStep(IStep step)
}
