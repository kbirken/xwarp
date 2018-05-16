package org.nanosite.xwarp.model

/**
 * A resource is anything that can be consumed.
 */
interface IResource extends INamed {
	
	def boolean isLimited()
	
}
