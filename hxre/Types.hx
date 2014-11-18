package hxre;

import haxe.ds.Option;

typedef Range<T> = {
	var begin : T;
	var end : T;
}

typedef Index<T> = Int

typedef Char = Int

interface Program {
	public var ncap (default, null) : Index<Null<Index<Char>>>; // number of captures
	public var nturnstile (default, null) : Index<Bool>; // number of turnstiles
	public var insts (default, null) : Array<Inst>; // list of instructions
	public var names (default, null) : Map<String, Index<Index<Char>>>;
}

interface Window {
	var index : Index<Char>;
	var prev (default, null) : Option<Char>;
	var curr (get, null) : Char;

	function terminal() : Bool;

	function advance() : Void;
}

typedef Flags = {
	var ignoreCase : Bool;
	var multiline : Bool;
	var global : Bool;
}
