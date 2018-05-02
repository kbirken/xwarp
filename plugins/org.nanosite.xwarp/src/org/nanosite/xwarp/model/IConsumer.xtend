package org.nanosite.xwarp.model

import java.util.List

interface IConsumer extends INamed {

	def List<IBehavior> getBehaviors()
		
}
