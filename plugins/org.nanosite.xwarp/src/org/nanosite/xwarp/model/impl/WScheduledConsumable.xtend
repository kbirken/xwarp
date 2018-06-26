package org.nanosite.xwarp.model.impl

import org.nanosite.xwarp.model.IScheduledConsumable

abstract class WScheduledConsumable extends WNamedElement implements IScheduledConsumable {
	
	val boolean isLimited
		
	new(String name, boolean isLimited) {
		super(name)
		this.isLimited = isLimited
	}
	
	override boolean isLimited() {
		isLimited
	}
	
}
