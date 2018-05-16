package org.nanosite.xwarp.model.impl

import org.nanosite.xwarp.model.IConsumableAmount
import org.nanosite.xwarp.simulation.WIntAccuracy

class WAmount implements IConsumableAmount {
	
	var long amount
	
	new (long amount) {
		this.amount = convertAmount(amount)
	}
	
	def private long convertAmount(long amountUser) {
		// convert UI units to logical simulator units
		val amount = Scaling.resourceUItoWarp * amountUser
		
		// convert logical simulator units to actual calculation units 
		WIntAccuracy.toCalc(amount) 
	}
	
	override long reduceAmount(long delta) {
		amount = amount - delta
		amount
	}
	
	override long getAmount() {
		this.amount
	}
}
