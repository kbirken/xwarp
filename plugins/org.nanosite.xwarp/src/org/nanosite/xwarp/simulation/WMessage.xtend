package org.nanosite.xwarp.simulation

class WMessage {
	WToken token
	
	new(WToken token) {
		this.token = token
	}
	
	def getToken() {
		token
	}
	
	def getName() {
		token.name
	}
}
