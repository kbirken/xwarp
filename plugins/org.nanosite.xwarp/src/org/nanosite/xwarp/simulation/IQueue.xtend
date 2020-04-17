package org.nanosite.xwarp.simulation

interface IQueue {
	def boolean isEmpty()
	def void push(WMessage message)
	def WMessage pop()
	def void clear()
}
