package org.nanosite.xwarp.result

interface IResultRecorder {
	
	def void addBehaviorResult(BehaviorInstance result)
	def void addStepResult(StepInstance result)
}
