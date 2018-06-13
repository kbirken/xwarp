package org.nanosite.xwarp.model

interface IPool extends IResource {

	enum ErrorAction {
		REJECT_AND_CONTINUE,
		EXECUTE_AND_CONTINUE,
		STOP_WORKING
	}
	
	def long getMaxAmount()
	
	def ErrorAction onOverflow() 
	def ErrorAction onUnderflow() 
	
}
