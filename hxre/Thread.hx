package hxre;

import hxre.Types;
import hxre.Inst;

class Thread {
	public var pc : Index<Inst>; // program counter
	public var savedbegin : Array<Index<Char>>; // saved capture begins
	public var savedend : Array<Index<Char>>; // saved end capture ends

	public function new(pc, sb, se) {
		this.pc = pc;
		this.savedbegin = sb;
		this.savedend = se;
	}

	public function copy() : Thread {
		return new Thread(pc, savedbegin.copy(), savedend.copy());
	}
}
