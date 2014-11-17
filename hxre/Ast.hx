package hxre;

import haxe.ds.Option;
import hxre.Types;

enum Ast {
	Dot;
	Literal(c : Char);
	AstClass(ranges : Array<Range<Char>>, negated : Bool);

	Begin;
	End;

	Cap(ast : Ast, name : Option<String>);

	Cat(asts : Array<Ast>);
	Alt(ast1 : Ast, ast2 : Ast);
	Rep(ast : Ast, repeater : Repeater, greed : Greed);
}

enum Repeater {
	ZeroOne;
	ZeroMore;
	OneMore;
	NRange(n : Int, m : Int);
	NMore(n : Int);
}

enum Greed {
	Greedy;
	Ungreedy;
}
