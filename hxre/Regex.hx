package hxre;

abstract Regex(NfaVM) from NfaVM {
	public function new(s : String, ?opt : String) {
		var ast = Parser.parse(s);
		var flags = Parser.parseFlags(opt);
		var prog = Compiler.compile(ast);
		this = new NfaVM(prog, flags);
	}

	public function test(s : String) {
		return this.match(new StringWindow(s));
	}

	public function exec(s : String) {
		var w = new StringWindow(s);
		var m = this.exec(w);
		switch (m) {
			case None:
				return null;
			case Some(arr):
				return [for (o in arr) switch (o) {
					case Some(r):
						s.substring(r.begin, r.end);
					default:
						null;
				}];
		}
	}
}
