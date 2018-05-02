package org.nanosite.xwarp.model.impl

import org.nanosite.xwarp.model.IResource

class WResource extends WNamedElement implements IResource {
	
	// the wait-resource is unlimited per definition
	val public static WResource waitResource = new WResource("wait", false)
	
	val boolean isLimited
		
	new(String name, boolean isLimited) {
		super(name)
		this.isLimited = isLimited
	}
	
	override boolean isLimited() {
		isLimited
	}
	
}
