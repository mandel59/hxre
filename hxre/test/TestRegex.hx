package hxre.test;

class TestRegex extends haxe.unit.TestCase {
	public function testRegex1() {
		assertTrue(new Regex("a...b").test("abababbb"));
		assertTrue(new Regex("b?<(?:ab)*>a?").test("b<abab>a"));
		assertTrue(new Regex("^\\\\$").test("\\"));
	}

	public function testRegex2() {
		var re = new Regex("^(?:ab|c){3,5}$");
		assertFalse(re.test("abc"));
		assertTrue(re.test("abcab"));
		assertTrue(re.test("abccabab"));
		assertFalse(re.test("abcabcabc"));
	}

	public function testDigit() {
		assertTrue(new Regex("^\\d{10}$").test("0123456789"));
		assertFalse(new Regex("\\D").test("0123456789"));
	}
}
