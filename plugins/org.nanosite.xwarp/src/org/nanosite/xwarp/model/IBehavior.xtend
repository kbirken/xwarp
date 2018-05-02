package org.nanosite.xwarp.model

interface IBehavior extends IStepSuccessor {
	def String getQualifiedName()
	def IStep getFirstStep()
	def boolean isLastStep(IStep step)
}
