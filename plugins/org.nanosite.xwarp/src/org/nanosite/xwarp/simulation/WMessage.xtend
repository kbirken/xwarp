package org.nanosite.xwarp.simulation

import org.nanosite.xwarp.result.StepInstance

class WMessage {
	WToken token
	
	// store sender in order to allow analysing causal dependencies later 
	StepInstance sender
	
	boolean isPayloadValid
	
	new(WToken token, StepInstance sender) {
		this(token, sender, true)
	}
	
	new(WToken token, StepInstance sender, boolean isPayloadValid) {
		this.token = token
		this.sender = sender
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
	
	def getSender() {
		sender
	}

	def isPayloadValid() {
		isPayloadValid
	}

	override String toString() {
		'''WMessage(«token.toString», «IF isPayloadValid»valid«ELSE»invalid«ENDIF»)'''
	}
}
