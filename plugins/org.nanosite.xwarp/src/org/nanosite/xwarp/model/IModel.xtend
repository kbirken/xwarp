package org.nanosite.xwarp.model

import java.util.List

interface IModel {
	
	def List<IScheduledConsumable> getScheduledConsumables()
	def List<IAllocatingConsumable> getAllocatingConsumables()
	
	def List<IConsumer> getConsumers()
	def List<ITrigger> getInitial()
}
