package hxre;

import haxe.ds.Option;
import hxre.Types;
import hxre.Ast;

private enum Paren {
	NonCaptureGroup;
	CaptureGroup(name : Option<String>);
}

class ParseError {
	public var pos (default, null) : Index<Char>;
	public var msg (default, null) : String;

	public function new(p, m) {
		pos = p;
		msg = m;
	}
}

class Parser {
	var source : String;
	var chars : Array<Char>;
	var index : Index<Char>;
	var names : Map<String, Bool>;

	var stack : Array<{paren : Paren, alts : Array<Ast>, cats : Array<Ast>}>;
	var alts : Array<Ast>;
	var cats : Array<Ast>;

	public static function parse(s : String) {
		var p = new Parser(s);
		return p.parseRegex();
	}

	public static function parseFlags(s : Null<String>) : Flags {
		var i = 0;
		var flags = {
			ignoreCase : false,
			multiline : false,
			global : false,
		};
		if (s == null) {
			return flags;
		}
		for (i in 0 ... s.length) {
			var c = s.charCodeAt(i);
			switch (c) {
				case 'i'.code:
					flags.ignoreCase = true;
				case 'g'.code:
					flags.global = true;
				case 'm'.code:
					flags.multiline = true;
				default:
			}
		}
		return flags;
	}

	function new(s : String) {
		source = s;
		chars = [for (i in 0 ... s.length) s.charCodeAt(i)]; // FIXME: support unicode string
		index = 0;
		names = new Map();
		stack = [];
		alts = [];
		cats = [];
	}

	function concat() {
		return if (cats.length == 1) cats[0] else Cat(cats);
	}

	function collectAlts(alts : Array<Ast>, cats : Array<Ast>) {
		var c = concat();
		for (a in alts) {
			c = Alt(a, c);
		}
		return c;
	}

	function addRepeater(r : Repeater) {
		if (cats.length == 0) {
			throw new ParseError(index, "");
		}
		var i = cats.length - 1;
		if (index < chars.length && chars[index] == '?'.code) {
			index++;
			cats[i] = Rep(cats[i], r, Ungreedy);
		} else {
			cats[i] = Rep(cats[i], r, Greedy);
		}
	}

	function parseHexadecimalDigits(n : Int) {
		if (index > chars.length - n) {
			throw new ParseError(index, "");
		}
		var x = 0;
		for (i in 0 ... n) {
			var y = chars[index++];
			if ('0'.code <= y && y <= '9'.code) {
				x = x * 16 + (y - '0'.code);
			} else if ('A'.code <= y && y <= 'F'.code) {
				x = x * 16 + (y - 'A'.code) + 0x0a;
			} else if ('a'.code <= y && y <= 'f'.code) {
				x = x * 16 + (y - 'a'.code) + 0x0a;
			} else {
				throw new ParseError(index, "");
			}
		}
		return x;
	}

	function parseEscape() {
		if (index == chars.length) {
			throw new ParseError(index, "");
		}
		var c = chars[index++];
		switch (c) {
			case '\\'.code, '.'.code, '+'.code, '*'.code, '?'.code,
				 '('.code, ')'.code, '|'.code, '['.code, ']'.code,
				'{'.code, '}'.code, '^'.code, '$'.code:
				return Literal(c);
			case 'a'.code:
				return Literal(0x07); // bell
			case 'f'.code:
				return Literal(0x0c); // form feed
			case 't'.code:
				return Literal('\t'.code); // horizontal tab
			case 'n'.code:
				return Literal('\n'.code); // new line
			case 'r'.code:
				return Literal('\r'.code); // carriage return
			case 'v'.code:
				return Literal(0x0b); // vertical tab
			case 'x'.code:
				return Literal(parseHexadecimalDigits(2));
			case 'd'.code:
				return AstClass([{begin: '0'.code, end: '9'.code + 1}], false);
			case 'D'.code:
				return AstClass([{begin: '0'.code, end: '9'.code + 1}], true);
			default:
				throw "TODO: implement other escapes";
		}
	}

	function parseCharClass() {
		throw "TODO: implement char class";
	}

	function parseParenExt() {
		switch (chars[index++]) {
			case ':'.code:
				return NonCaptureGroup;
			default:
				throw "TODO: implement other extensions";
		}
	}

	function parseInt() {
		if (index == chars.length) {
			throw new ParseError(index, "");
		}

		var c = chars[index];
		if (c < '0'.code || '9'.code < c) {
			throw new ParseError(index, "");
		}
		index++;

		var i = c - '0'.code;
		while (index < chars.length) {
			var c = chars[index];
			if (c < '0'.code || '9'.code < c) {
				break;
			}
			index++;
			i = 10 * i + (c - '0'.code);
		}
		return i;
	}

	function parseRepeater() {
		if (index == chars.length) {
			return;
		}
		switch (chars[index]) {
			case '?'.code:
				index++;
				addRepeater(ZeroOne);
			case '*'.code:
				index++;
				addRepeater(ZeroMore);
			case '+'.code:
				index++;
			case '{'.code:
				index++;
				var n = parseInt();
				switch (chars[index++]) {
					case ','.code:
						if (chars[index] == '}'.code) {
							index++;
							addRepeater(NMore(n));
						} else {
							var m = parseInt();
							if (chars[index] != '}'.code) {
								throw new ParseError(index, "");
							}
							if (n > m) {
								throw new ParseError(index, "");
							}
							index++;
							addRepeater(NRange(n, m));
						}
					case '}'.code:
						addRepeater(NRange(n, n));
					default:
						throw new ParseError(index - 1, "");
				}
			default:
		}
	}

	function parseRegex() {
		while (index < chars.length) {
			switch (chars[index++]) {
				case '?'.code, '*'.code,  '+'.code, '{'.code:
					throw new ParseError(index - 1, "");
				case '\\'.code:
					cats.push(parseEscape());
					parseRepeater();
				case '['.code:
					parseCharClass();
					parseRepeater();
				case '('.code:
					if (index == chars.length) {
						throw new ParseError(index, "");
					}
					var p;
					if (chars[index] == '?'.code) {
						index++;
						p = parseParenExt();
					} else {
						p = CaptureGroup(None);
					}
					stack.push({paren : p, alts : alts, cats : cats});
					alts = [];
					cats = [];
				case ')'.code:
					if (stack.length == 0) {
						throw new ParseError(index - 1, "");
					}
					var c = collectAlts(alts, cats);
					var b = stack.pop();
					alts = b.alts;
					cats = b.cats;
					switch (b.paren) {
						case NonCaptureGroup:
							cats.push(c);
						case CaptureGroup(n):
							cats.push(Cap(c, n));
					}
					parseRepeater();
				case '|'.code:
					alts.unshift(concat());
					cats = [];
				case '.'.code:
					cats.push(Dot);
					parseRepeater();
				case '^'.code:
					cats.push(Begin);
				case '$'.code:
					cats.push(End);
				case c:
					cats.push(Literal(c));
					parseRepeater();
			}
		}
		if (stack.length != 0) {
			throw new ParseError(index, "");
		}
		var c = collectAlts(alts, cats);
		return c;
	}
}
