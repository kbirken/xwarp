package org.nanosite.xwarp.model.impl

class WUnlimitedResource extends WScheduledConsumable {
	
	// there is only one wait-resource, which is unlimited by definition
	val public static WUnlimitedResource waitResource =
		new WUnlimitedResource("wait")
	
	new(String name) {
		super(name, false)
	}
	
}
