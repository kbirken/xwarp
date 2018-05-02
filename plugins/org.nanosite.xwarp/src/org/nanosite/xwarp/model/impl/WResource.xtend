package org.nanosite.xwarp.model.impl

import org.nanosite.xwarp.model.IResource

class WResource extends WNamedElement implements IResource {
	
	val boolean isLimited
		
	new(String name, boolean isLimited) {
		super(name)
		this.isLimited = isLimited
	}
	
	override boolean isLimited() {
		isLimited
	}
	
}
