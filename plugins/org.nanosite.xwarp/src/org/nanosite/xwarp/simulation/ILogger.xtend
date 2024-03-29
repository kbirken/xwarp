package org.nanosite.xwarp.simulation

interface ILogger {
	enum Type {
		TOKINFO,
		TOKEN,
		POOL,
		INFO,
		DEBUG,
		
		// task states
		WAITING,
		READY,
		RUNNING,
		DONE
	}
	
	def void updateCurrentTime(long timestamp)
	
	def void log(int level, Type type, String txt)
//	def void logNoTime(int level, Type type, String txt)
		
	def void error(String txt)
	def void fatal(String txt)
}
