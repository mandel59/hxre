package hxre;

import hxre.Types;

class Compiler implements Program {
	public var ncap (default, null) : Index<Null<Index<Char>>>;
	public var nturnstile (default, null) : Index<Bool>;
	public var insts (default, null) : Array<Inst>;
	public var names (default, null) : Map<String, Index<Index<Char>>>;

	public static function compile(ast : Ast) : Program {
		var c = new Compiler(ast);
		c.construct(ast);
		return c;
	}

	function new(ast : Ast) {
		ncap = 1;
		nturnstile = 0;
		insts = [];
		names = new Map();
	}

	function countCaps(ast : Ast) {
		switch (ast) {
			case Cap(ast, name):
				var c = ncap++;
				switch (name) {
					case Some(n): names.set(n, c);
					default:
				}
			case Cat(asts):
				for (ast in asts) {
					countCaps(ast);
				}
			case Alt(ast1, ast2):
				countCaps(ast1);
				countCaps(ast2);
			case Rep(ast, _, _):
				countCaps(ast);
			default:
		}
	}

	function construct(ast : Ast) {
		switch (ast) {
			case Dot:
				insts.push(AddThread);
			case Literal(c):
				insts.push(OneChar(c));
				insts.push(AddThread);
			case AstClass(ranges, negated):
				if (!negated) {
					insts.push(CharClass(ranges));
				} else {
					insts.push(NegCharClass(ranges));
				}
				insts.push(AddThread);
			case Begin:
				insts.push(Begin);
			case End:
				insts.push(End);
			case Cap(ast, name):
				var c = ncap++;
				switch (name) {
					case Some(n): names.set(n, c);
					default:
				}
				insts.push(SaveBegin(c));
				construct(ast);
				insts.push(SaveEnd(c));
			case Cat(asts):
				for (ast in asts) {
					construct(ast);
				}
			case Alt(ast1, ast2):
				var split = insts.length;
				insts.push(null);
				var j1 = insts.length;
				construct(ast1);
				var jump = insts.length;
				insts.push(null);
				var j2 = insts.length;
				construct(ast2);
				var j3 = insts.length;
				insts.push(PassTurnstile(nturnstile++));

				insts[split] = Split(j1, j2);
				insts[jump] = Jump(j3);
			case Rep(ast, ZeroOne, g):
				var split = insts.length;
				insts.push(null);
				var j1 = insts.length;
				construct(ast);
				var j2 = insts.length;
				insts.push(PassTurnstile(nturnstile++));

				switch (g) {
					case Greedy: insts[split] = Split(j1, j2);
					case Ungreedy: insts[split] = Split(j2, j1);
				}
			case Rep(ast, ZeroMore, g):
				var j1 = insts.length;
				insts.push(PassTurnstile(nturnstile++));
				var split = insts.length;
				insts.push(null);
				var j2 = insts.length;
				construct(ast);
				var jump = insts.length;
				insts.push(null);
				var j3 = insts.length;

				switch (g) {
					case Greedy: insts[split] = Split(j2, j3);
					case Ungreedy: insts[split] = Split(j3, j2);
				}
				insts[jump] = Jump(j1);
			case Rep(ast, OneMore, g):
				var j1 = insts.length;
				insts.push(PassTurnstile(nturnstile++));
				construct(ast);
				var split = insts.length;
				insts.push(null);
				var j2 = insts.length;

				switch (g) {
					case Greedy: insts[split] = Split(j1, j2);
					case Ungreedy: insts[split] = Split(j2, j1);
				}
			case Rep(ast, NRange(n, m), g):
				if (m > 0) {
					var c = ncap;

					for (i in 0 ... n) {
						ncap = c;
						construct(ast);
					}

					var splits = [];
					for (i in n ... m) {
						ncap = c;
						splits.push(insts.length);
						insts.push(null);
						construct(ast);
					}

					var j1 = insts.length;
					insts.push(PassTurnstile(nturnstile++));

					switch (g) {
						case Greedy:
							for (split in splits) {
								insts[split] = Split(split + 1, j1);
							}
						case Ungreedy:
							for (split in splits) {
								insts[split] = Split(j1, split + 1);
							}
					}
				} else {
					countCaps(ast);
				}
			case Rep(ast, NMore(n), g):
				var c = ncap;

				for (i in 0 ... n) {
					ncap = c;
					construct(ast);
				}

				ncap = c;
				construct(Rep(ast, ZeroMore, g));
		}
	}
}
