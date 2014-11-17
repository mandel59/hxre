package hxre.test;

@:build(hxre.Specializer.build("abc"))
private class RegEx1 extends hxre.NfaVM {}

class TestSpecializer extends haxe.unit.TestCase {
	public function testSpecializer() {
		var re = new RegEx1();
		assertTrue(re.exec(new StringWindow("abc")));
	}
}
