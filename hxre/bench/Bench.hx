package hxre.bench;

import haxe.macro.Expr;
import Reflect;

@:keepSub
@:publicFields
class Bench {
	var n : Int;

	public function new() {
		n = 200;
	}

	public function run() {
		var cl = Type.getClass(this);
		var fields = Type.getInstanceFields(cl);

		for (f in fields) {
			if (!StringTools.startsWith(f,"benchmark")) {
				continue;
			}
			var field = Reflect.field(this, f);
			if (!Reflect.isFunction(field)) {
				continue;
			}
			var dt : Float = Reflect.callMethod(this, field, []);
			haxe.unit.TestRunner.print("* " + f + "\n  time : " + dt + " [sec/op]\n");
		}
	}

	function average(data : Array<Float>) {
		var total = 0.0;
		for (v in data) {
			total += v;
		}
		return total / data.length;
	}

	macro function benchmark(_this : Expr, e : Expr) {
		return macro {
			var total = 0.0;
			var f = function() ${e};
			var g = function() {};
			for (i in 0 ... n){
				var t1 = haxe.Timer.stamp();
				f();
				var t2 = haxe.Timer.stamp();
				g();
				var t3 = haxe.Timer.stamp();
				var dt = (t2 - t1) - (t3 - t2);
				total += dt;
			}
			return total / n;
		};
	}
}
