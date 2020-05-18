package org.nanosite.xwarp.simulation

interface IQueue {
	def boolean isEmpty()
	def void push(WMessage message, long tCurrent)
	def WMessage pop()
}
