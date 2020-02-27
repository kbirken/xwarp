package org.nanosite.xwarp.model.impl

import org.nanosite.xwarp.model.ITrigger
import org.nanosite.xwarp.model.IBehavior

class WTrigger implements ITrigger {
	
	val IBehavior behavior
	val int inputIndex
	
	new (IBehavior behavior, int inputIndex) {
		this.behavior = behavior
		this.inputIndex = inputIndex 
	}
	
	override IBehavior getBehavior() {
		this.behavior
	}
	
	override int getInputIndex() {
		this.inputIndex
	}
	
	override int hashCode() {
		var result = 1
		result = 31 * result + behavior.hashCode
		result = 31 * result + inputIndex 
		result
	}
	
	override boolean equals(Object obj) {
		if (this==obj)
			return true
		if (obj===null)
			return false
		if (this.class != obj.class)
			return false
		val other = obj as WTrigger
		if (behavior != other.behavior)
			return false
		if (inputIndex != other.inputIndex)
			return false
		return true
	}
}
