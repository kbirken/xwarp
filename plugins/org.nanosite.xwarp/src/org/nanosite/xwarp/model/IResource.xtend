package org.nanosite.xwarp.model

/**
 * Interface for resources which provide bandwidth
 * and can be used in different ways (i.e., sets of parameters).</p>
 */
interface IResource extends IScheduledConsumable {
	
	def int getCST(int index)
}
