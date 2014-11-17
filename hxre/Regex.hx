package hxre;

abstract Regex(NfaVM) from NfaVM {
	public function new(s : String) {
		var ast = Parser.parse(s);
		var prog = Compiler.compile(ast);
		this = new NfaVM(prog);
	}

	public function test(s : String) {
		return this.exec(new StringWindow(s));
	}
}
