package org.nanosite.xwarp.model

/**
 * Interface for consumables which do allocation.</p>
 */
interface IAllocatingConsumable extends IConsumable {
	
	def long getMaxAmount()

	enum ErrorAction {
		REJECT_AND_CONTINUE,
		EXECUTE_AND_CONTINUE,
		STOP_WORKING
	}
	
	def ErrorAction onOverflow() 
	def ErrorAction onUnderflow() 
}
