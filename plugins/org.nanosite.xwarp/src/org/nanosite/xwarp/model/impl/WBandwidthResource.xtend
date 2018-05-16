package org.nanosite.xwarp.model.impl

import java.util.List
import com.google.common.collect.ImmutableList
import org.nanosite.xwarp.model.IBandwidthResource
import org.nanosite.xwarp.model.IBandwidthResourceInterface

class WBandwidthResource extends WNamedElement implements IBandwidthResource {
	
	List<WBandwidthResourceInterface> interfaces
	
	new(String name, List<Integer> contextSwitchingTimes) {
		super(name)
		
		this.interfaces = newArrayList
		interfaces.addAll(
			contextSwitchingTimes.map[new WBandwidthResourceInterface(this, it)]
		)
	}
	
	override List<IBandwidthResourceInterface> getInterfaces() {
		ImmutableList.copyOf(interfaces)
	}
}
