package hxre;

import haxe.ds.Option;
import hxre.Types;
import hxre.Inst;

class Thread {
	public var pc : Index<Inst>; // program counter
	public var savedbegin : Array<Null<Index<Char>>>; // saved capture begins
	public var savedend : Array<Null<Index<Char>>>; // saved end capture ends

	public function new(pc, sb : Array<Null<Index<Char>>>, se : Array<Null<Index<Char>>>, ncap) {
		this.pc = pc;
		for (i in sb.length ... ncap) {
			sb[i] = null;
		}
		for (i in se.length ... ncap) {
			se[i] = null;
		}
		this.savedbegin = sb;
		this.savedend = se;
	}

	public function copy() : Thread {
		return new Thread(pc, savedbegin.copy(), savedend.copy(), savedbegin.length);
	}
}
