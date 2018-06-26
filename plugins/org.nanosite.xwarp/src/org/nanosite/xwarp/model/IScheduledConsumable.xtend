package org.nanosite.xwarp.model

/**
 * Interface for consumables which are managed by a scheduler.</p>
 */
interface IScheduledConsumable extends IConsumable {
	
	def boolean isLimited()

}
