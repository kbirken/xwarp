package org.nanosite.xwarp.model.impl

import org.nanosite.xwarp.model.INamed

abstract class WNamedElement implements INamed {
	
	String name
	
	new(String name) {
		this.name = name
	}
	
	override getName() {
		name
	}
}
