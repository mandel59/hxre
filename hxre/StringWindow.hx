package hxre;

import haxe.ds.Option;
import hxre.Types;

class StringWindow implements Window {
	public var index : Index<Char>;
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
