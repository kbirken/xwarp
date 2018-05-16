package org.nanosite.xwarp.model

import org.nanosite.xwarp.model.IAmount

interface IConsumableAmount extends IAmount {

	def long reduceAmount(long delta)	
}
