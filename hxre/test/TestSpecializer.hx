package hxre.test;

@:build(hxre.Specializer.build("abc"))
private class RegEx1 extends hxre.NfaVM {}

@:build(hxre.Specializer.build("^(?:ab|c)*$"))
private class RegEx2 extends hxre.NfaVM {}

@:build(hxre.Specializer.build("^(?:ab|c){0,2}$"))
private class RegEx3 extends hxre.NfaVM {}

class TestSpecializer extends haxe.unit.TestCase {
	public function testSpecializer1() {
		var re : hxre.Regex = new RegEx1();
		assertTrue(re.test("abc"));
	}

	public function testSpecializer2() {
		var re : hxre.Regex = new RegEx2();
		assertTrue(re.test("abc"));
	}

	public function testSpecializer3() {
		var re : hxre.Regex = new RegEx3();
		assertTrue(re.test("abc"));
	}
}
