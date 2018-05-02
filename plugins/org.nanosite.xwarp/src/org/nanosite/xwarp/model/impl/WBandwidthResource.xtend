package org.nanosite.xwarp.model.impl

class WBandwidthResource extends WResource {
	
	
	new(String name) {
		// this kind of resource is always limited by bandwidth 
		super(name, true)
	}
	
}
