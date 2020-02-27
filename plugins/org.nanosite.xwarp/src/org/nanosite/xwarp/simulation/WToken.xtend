package org.nanosite.xwarp.simulation

import java.util.List
import com.google.common.collect.ImmutableList

class WToken {
	
	var static nextId = 1
	
	def static WToken create(String info, ILogger logger) {
		create(info, null as WToken, logger)
	}
	
	def static WToken create(String info, WToken parent, ILogger logger) {
		new WToken(nextId++, info, parent)
	}
	
	def static WToken create(String info, List<WToken> parents, ILogger logger) {
		new WToken(nextId++, info, parents)
	}
	
	val int id
	val String infoLocal
	val List<WToken> parents
	
	private new(int id, String info, WToken parent) {
		this.id = id
		this.infoLocal = info
		this.parents = newArrayList()
		if (parent!==null)
			parents.add(parent)
	}

	private new(int id, String info, List<WToken> parents) {
		this.id = id
		this.infoLocal = info
		this.parents = ImmutableList.copyOf(parents)
	}

	def getId() {
		id
	}

	def String getName() {
		'''$«nameAux»$'''
	}

	def private String getNameAux() {
		accum["" + id]
	}

	def String getInfo() {
		accum[infoLocal]
	}

	def private String accum((WToken) => String infoFunc) {
		val local = infoFunc.apply(this)
		if (parents.empty) {
			local
		} else {
			if (parents.size==1)
				infoFunc.apply(parents.head) + "/" + local
			else
				"(" + parents.map(infoFunc).join('+') + ")" + "/" + local
		}
	}
	
	override String toString() {
		'''$«id»/«infoLocal»$'''
	}

}
