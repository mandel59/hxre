package hxre;

import hxre.Types;

enum Inst {
	AddThread;
	Jump(x : Index<Inst>);
	Split(x : Index<Inst>, y : Index<Inst>);
	PassTurnstile(i : Index<Bool>);
	SaveBegin(i : Index<Index<Char>>);
	SaveEnd(i : Index<Index<Char>>);

	OneChar(c : Char);
	CharClass(ranges : Array<Range<Char>>);
	NegCharClass(ranges : Array<Range<Char>>);
	Begin;
	End;
}
