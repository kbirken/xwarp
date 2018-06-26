package org.nanosite.xwarp.model.impl

import java.util.List
import org.nanosite.xwarp.model.IResource

class WResource extends WScheduledConsumable implements IResource {
	
	List<Integer> cst = newArrayList
	
	new(String name, List<Integer> contextSwitchingTimes) {
		super(name, true)
		
		cst.addAll(contextSwitchingTimes)
	}
	
	override int getCST(int index) {
		cst.get(index)
	}
}
