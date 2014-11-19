package hxre;

import haxe.ds.Option;
import hxre.Types;

class NfaVM {
	public var ignoreCase (default, null) : Bool = false;
	public var multiline (default, null) : Bool = false;
	public var global (default, null) : Bool = false;

	public var lastIndex (default, null) : Int = 0;

	var prog : Null<Program>;
	var w : Window;
	var cts : Array<Thread>;
	var nts : Array<Thread>;
	var ncap : Index<Option<Index<Char>>>;
	var turnstile : Array<Bool>;
	var matchedThread : Option<Thread>;

	public function new(prog : Null<Program>, flags : Flags) {
		this.prog = prog;
		if (prog != null) {
			ncap = prog.ncap;
			turnstile = [for (i in 0 ... prog.nturnstile) false];
		}
		ignoreCase = flags.ignoreCase;
		multiline = flags.multiline;
		global = flags.global;
	}

	public function match(w : Window) : Bool {
		this.w = w;
		if (global) {
			w.index = lastIndex;
		}
		cts = [];
		nts = [];
		clearTurnstiles();
		matchedThread = None;

		while (true) {
			if (matchedThread == None) {
				cts.push(new Thread(0, [w.index], [], ncap));
			}

			if (cts.length == 0) {
				break;
			}

			for (t in cts) {
				if (run(t)) {
					break;
				}
			}

			if (terminal()) {
				break;
			}

			advance();
		}
		return matchedThread != None;
	}

	inline public function exec(w : Window) : Option<Array<Option<Range<Index<Char>>>>> {
		match(w);
		return getMatch();
	}

	function getMatch() : Option<Array<Option<Range<Index<Char>>>>> {
		switch (matchedThread) {
			case None:
				return None;
			case Some(t):
				return Some([for (i in 0 ... ncap)
					switch [t.savedbegin[i], t.savedend[i]] {
						case [null, _], [_, null]:
							None;
						case [b, e]:
							Some({begin: b, end: e});
					}]);
		}
	}

	inline function clearTurnstiles() {
		for (i in 0 ... turnstile.length) {
			turnstile[i] = false;
		}
	}

	inline function terminal() : Bool {
		return w.terminal();
	}

	inline function advance() : Void {
		w.advance();
		cts = nts;
		nts = [];
		clearTurnstiles();
	}

	function run(t : Thread) : Bool {
		while (true) {
			if (t.pc == prog.insts.length) {
				t.savedend[0] = w.index;
				if (global) {
					lastIndex = w.index;
				}
				matchedThread = Some(t);
				return true;
			}
			switch (prog.insts[t.pc++]) {
				case AddThread:
					addThread();
				case Jump(x):
					jump(x);
				case Split(x, y):
					split(x, y);
				case PassTurnstile(i):
					passTurnstile(i);
				case SaveBegin(i):
					saveBegin(i);
				case SaveEnd(i):
					saveEnd(i);
				case OneChar(c):
					assert(oneChar(c));
				case CharClass(ranges):
					assert(charClass(ranges));
				case NegCharClass(ranges):
					assert(negCharClass(ranges));
				case Begin:
					assert(begin());
				case End:
					assert(end());
			}
		}
	}

	macro static function addThread() {
		return macro {
			nts.push(t);
			return false;
		};
	}

	inline function oneChar(c : Char) : Bool {
		return !w.terminal() && w.curr == c;
	}

	function charClass(ranges : Array<Range<Char>>) : Bool {
		if (w.terminal()) {
			return false;
		}
		var curr = w.curr;
		// FIXME: inefficient linear search
		for (range in ranges) {
			if (range.begin <= curr && curr < range.end) {
				return true;
			}
		}
		return false;
	}

	inline function negCharClass(ranges) {
		return !charClass(ranges);
	}

	inline function begin() : Bool {
		return w.prev == None;
	}

	inline function end() : Bool {
		return w.terminal();
	}

	macro static function assert(prop) {
		return macro if (!${prop}) {
			return false;
		};
	}

	macro static function jump(x) {
		return macro t.pc = ${x};
	}

	macro static function split(x, y) {
		return macro {
			var t1 = t.copy();
			t1.pc = ${x};
			if (run(t1)) {
				return true;
			}
			t.pc = ${y};
		};
	}

	macro static function passTurnstile(i) {
		return macro {
			if (turnstile[${i}]) {
				return false;
			}
			turnstile[${i}] = true;
		};
	}

	macro static function saveBegin(i) {
		return macro t.savedbegin[${i}] = w.index;
	}

	macro static function saveEnd(i) {
		return macro t.savedend[${i}] = w.index;
	}
}
