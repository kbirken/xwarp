package org.nanosite.xwarp.model.impl

import org.nanosite.xwarp.model.IBehavior
import org.nanosite.xwarp.model.IStep

abstract class WAbstractStep extends WNamedElement implements IStep {

	WBehavior owner = null
	
	new(String name) {
		super(name)
	}

	def setOwner(WBehavior owner) {
		this.owner = owner
	}

	override String getQualifiedName() {
		'''«owner.qualifiedName»::«name»'''
	}
	
	override IBehavior getOwner() {
		owner
	}

	override boolean isFirst() {
		owner.firstStep == this
	}
	
	override boolean hasSameBehavior(IStep other) {
		if (other instanceof WAbstractStep)
			this.owner == other.owner
		else
			false
	}
}
