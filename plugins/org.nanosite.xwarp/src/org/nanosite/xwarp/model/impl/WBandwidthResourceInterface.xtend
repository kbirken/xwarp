package org.nanosite.xwarp.model.impl

import org.nanosite.xwarp.model.IBandwidthResourceInterface

class WBandwidthResourceInterface implements IBandwidthResourceInterface {
	
	val WBandwidthResource owner
	val int cst
	
	new (WBandwidthResource owner, int cst) {
		this.owner = owner
		this.cst = cst
	}
	
	override getName() {
		owner.name
	}

	override isLimited() {
		true
	}
	
	override getCST() {
		cst
	}
}
