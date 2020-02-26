package org.nanosite.xwarp.simulation

class WMessage {
	WToken token
	
	boolean isPayloadValid
	
	new(WToken token) {
		this(token, true)
	}
	
	new(WToken token, boolean isPayloadValid) {
		this.token = token
		this.isPayloadValid = isPayloadValid
	}
	
	def getToken() {
		token
	}
	
	def getName() {
		token.name
	}
	
	def String getTaggedName() {
		if (isPayloadValid)
			token.name + "!"
		else
			token.name + "?"
	}

	def isPayloadValid() {
		isPayloadValid
	}

	override String toString() {
		'''WMessage(«token.toString», «IF isPayloadValid»valid«ELSE»invalid«ENDIF»)'''
	}
}
