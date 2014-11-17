package hxre;

import haxe.ds.Option;
import haxe.macro.Expr;
import hxre.Types;
import hxre.Ast;
import hxre.Inst;

abstract Regex(NfaVM) {
	public function new(s : String) {
		var ast = Parser.parse(s);
		var prog = Compiler.compile(ast);
		this = new NfaVM(prog);
	}

	public function test(s : String) {
		return this.exec(new StringWindow(s));
	}
}

private class StringWindow implements Window {
	public var index (default, null) : Index<Char>;
	public var prev (default, null) : Option<Char>;
	public var curr (get, null) : Char;
	var str : String;

	public function new(s : String) {
		str = s;
		index = 0;
		prev = None;
	}

	function get_curr() : Char {
		return str.charCodeAt(index);
	}

	public function terminal() : Bool {
		return str.length <= index;
	}

	public function advance() : Void {
		var c = curr;
		prev = Some(c);
		index++;
	}
}
