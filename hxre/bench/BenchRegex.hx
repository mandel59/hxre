package hxre.bench;

@:build(hxre.Specializer.build("b?<(?:ab)*>a?"))
private class RegexS extends hxre.NfaVM {}

class BenchRegex extends Bench {
	var regex1 = new Regex("b?<(?:ab)*>a?");
	var regex2 : hxre.Regex = new RegexS();
	var ereg = new EReg("b?<(ab)*>a?", "");
	var str = [for (i in 0 ... 100) "0123456789"].join("") + "b?<(ab)*>a?";
	function benchmarkRegex1()
		benchmark(regex1.test(str));
	function benchmarkRegex2()
		benchmark(regex2.test(str));
	function benchmarkEReg()
		benchmark(ereg.match(str));
}
