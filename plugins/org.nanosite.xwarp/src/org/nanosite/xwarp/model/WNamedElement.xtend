package org.nanosite.xwarp.model

import org.nanosite.xwarp.model.api.INamed

abstract class WNamedElement implements INamed {
	
	String name
	
	new(String name) {
		this.name = name
	}
	
	override getName() {
		name
	}
}
