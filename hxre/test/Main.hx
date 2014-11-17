package hxre.test;

class Main {
	static function main() {
		var r = new haxe.unit.TestRunner();
		r.add(new TestRegex());
		r.add(new TestSpecializer());
		r.run();
	}
}
