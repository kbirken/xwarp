package org.nanosite.xwarp.simulation

class WIntAccuracy {
	val static long accuracyFactor = 10
	
	def static long toCalc(long i) {
		i*accuracyFactor
	}
	
	def static long toPrint(long i) {
		(i+(accuracyFactor/2 as long)) / accuracyFactor
	}
	
	def static long C_100() {
		toCalc(100)
	}

	def static long C_1000() {
		toCalc(1000)
	}
	
	def static long div(long a, long b) {
		(a + (b/2)) / b
	}
	
}
