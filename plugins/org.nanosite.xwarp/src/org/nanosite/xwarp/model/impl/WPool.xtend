package org.nanosite.xwarp.model.impl

import org.nanosite.xwarp.model.IPool

class WPool extends WNamedElement implements IPool {
	
	val long maxAmount
	
	val ErrorAction onOverflow
	val ErrorAction onUnderflow
	
	new (String name, long maxAmount) {
		this(name, maxAmount, ErrorAction.REJECT_AND_CONTINUE, ErrorAction.REJECT_AND_CONTINUE)
	}
	
	new (
		String name,
		long maxAmount,
		ErrorAction onOverflow,
		ErrorAction onUnderflow
	) {
		super(name)
		this.maxAmount = maxAmount
		this.onOverflow = onOverflow
		this.onUnderflow = onUnderflow
	}
	
	override getMaxAmount() {
		maxAmount
	}
	
	override onOverflow() {
		onOverflow
	}
	
	override onUnderflow() {
		onUnderflow
	}
}
