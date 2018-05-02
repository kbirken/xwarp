package org.nanosite.xwarp.simulation

import org.nanosite.xwarp.simulation.ILogger

class WLogger implements ILogger {

	val int loglevel

	var long currentTime
	
	new (int loglevel) {
		this.loglevel = loglevel
		this.currentTime = 0L
	}
	
	override void updateCurrentTime(long timestamp) {
		this.currentTime = timestamp
	}
	
	override void log(int level, Type type, String txt) {
		if (level<=loglevel) {
			val time = String.format("%09d", WIntAccuracy.toPrint(currentTime))
			println('''«time» «type.format»«txt»''')
		}
	}

//	override void logNoTime(int level, Type type, String txt) {
//		if (level<=loglevel) {
//			println('''          «type.format»«txt»''')
//		}
//	}
	
	def private static format(Type type) {
		String.format("%-10s", type)
	}
}
