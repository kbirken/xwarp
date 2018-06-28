package org.nanosite.xwarp.model.impl

import org.nanosite.xwarp.model.IConsumableAmount
import org.nanosite.xwarp.simulation.WIntAccuracy

class WAmount implements IConsumableAmount {
	
	var long amount
	
	new (long amount) {
		// convert logical simulator units to actual calculation units 
		this.amount = WIntAccuracy.toCalc(amount) 
	}
	
	private new () { }
	 
	override WAmount clone() {
		val cloned = new WAmount()
		cloned.amount = amount
		cloned
	}

	override long reduceAmount(long delta) {
		amount = amount - delta
		amount
	}
	
	override long getAmount() {
		this.amount
	}
}
