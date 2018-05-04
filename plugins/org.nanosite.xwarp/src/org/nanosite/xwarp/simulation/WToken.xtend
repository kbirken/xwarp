package org.nanosite.xwarp.simulation

class WToken {
	
	var static nextId = 1
	
	def static WToken create(String info, ILogger logger) {
		create(info, null, logger)
	}
	
	def static WToken create(String info, WToken parent, ILogger logger) {
		new WToken(nextId++, info, parent)
	}
	
	val int id
	val String infoLocal
	val WToken parent
	
	private new(int id, String info, WToken parent) {
		this.id = id
		this.infoLocal = info
		this.parent = parent
	}

	def getId() {
		id
	}

	def String getName() {
		'''$«nameAux»$'''
	}

	def private String getNameAux() {
		if (parent!==null) {
			parent.nameAux + "/" + id
		} else {
			"" + id
		}
	}

	def String getInfo() {
		if (parent!==null) {
			parent.info + "/" + infoLocal
		} else {
			infoLocal
		}
	}
	
	override String toString() {
		'''$«id»/«infoLocal»$'''
	}

}
