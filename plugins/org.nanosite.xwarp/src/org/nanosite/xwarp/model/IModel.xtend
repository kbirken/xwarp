package org.nanosite.xwarp.model

import java.util.List

interface IModel {
	
	def List<IResource> getResources()
	def List<IBehavior> getInitial()
	
}
