package org.nanosite.xwarp.model

import java.util.List

interface IBandwidthResource extends INamed {

	def List<IBandwidthResourceInterface> getInterfaces()
	
}
