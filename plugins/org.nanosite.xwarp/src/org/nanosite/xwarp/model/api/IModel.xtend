package org.nanosite.xwarp.model.api

import java.util.List

interface IModel {
	
	def List<IResource> getResources()
	def List<IBehavior> getInitial()
	
}
