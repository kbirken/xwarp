package org.nanosite.xwarp.model.impl

import java.util.List
import com.google.common.collect.ImmutableList
import org.nanosite.xwarp.model.IBandwidthResource

class WBandwidthResource extends WResource implements IBandwidthResource {
	
	// for each ResourceInterface, there is one entry in the cst vector (for non-CPUs only)
	List<Integer> contextSwitchingTimes
	
	new(String name, List<Integer> contextSwitchingTimes) {
		// this kind of resource is always limited by bandwidth 
		super(name, true)
		
		this.contextSwitchingTimes = contextSwitchingTimes
	}
	
	override List<Integer> getCSTs() {
		ImmutableList.copyOf(contextSwitchingTimes)
	}
}
