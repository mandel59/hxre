package hxre.test;

class TestRegex extends haxe.unit.TestCase {
	public function testRegex() {
		assertTrue(new Regex("a...b").test("abababbb"));
		assertTrue(new Regex("b?<(?:ab)*>a?").test("b<abab>a"));
		{
			var re = new Regex("^(?:ab|c){3,5}$");
			assertFalse(re.test("abc"));
			assertTrue(re.test("abcab"));
			assertTrue(re.test("abccabab"));
			assertFalse(re.test("abcabcabc"));
		}
		assertTrue(new Regex("^\\\\$").test("\\"));
	}
}
