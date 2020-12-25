import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop;
import std.algorithm:map, sort, fold, swap, filter, minIndex;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;
import libdmathexpr.mathexpr:IMathObject,MathParseError,MOOperation,MONumber,MOOpType,getNextElem,getPrevElem,getCharType,NUMBER,PAREN,OPERATOR,SPACE;

const string tryEval =
"		try {
			return new MONumber(evaluate(vars));
		} catch {}";
// use a local version of MOParens to force use of local parseMathExpr by MOParens
class MOParens:IMathObject {
	IMathObject holder;
	/// Constructor that takes a pre-parsed object
	this(IMathObject obj) {
		holder = obj;
	}
	/// Constructor that eats an input string
	this(ref string input) {
		parse(input);
	}
	/// Return the string that was used to generate this node.
	override string toString() {
		return "("~holder.toString()~")";
	}
	/// Return the numeric data represented by this node.
	real evaluate(real[string]vars) {
		return holder.evaluate(vars);
	}
	/// This function parses a set of nodes out of an equation string.
	void parse(ref string input) {
		// find the end of the paren that opens here
		if (!input.length || input[0] != '(') {
			throw new MathParseError("Couldn't instantiate parens");
		}
		int count = 0;
		foreach (i,c;input) {
			switch (c) {
			case '(': count++; break;
			case ')': count--; break;
			default: break;
			}
			if (!count) {
				holder = parseMathExpr(input[1..i]);
				// skip the closing paren
				input = input[i+1..$];
				return;
			}
		}
		throw new MathParseError("Unexpected end of input: "~input);
	}
	/// Return the simplification of this node (where possible).
	IMathObject simplify(real[string]vars) {
		mixin(tryEval);
		// it only makes sense to pass the simplification up the tree here, parens perform no real ops
		holder = holder.simplify(vars);
		return this;
	}
}

IMathObject[]splitMathExpr(string input) {
	// respect parens and pass them back into parseMathExpr for further parsing
	IMathObject[]tmp;
	int slice = 0;
	while (input.length) {
		switch (getCharType(input[0])) {
		case NUMBER:
			// if the previous item was a number, barf, can't have adjacent numerics because it doesn't make sense
			if (tmp.length && cast(MONumber)tmp[$-1]) throw new MathParseError("Numerics can not be adjacent. Secondary starting at: "~input);
			// add mul op if necessary
			tmp ~= new MONumber(input);
			break;
		case OPERATOR:
			tmp ~= new MOOperation(input[0..1]);
			input = input[1..$];
			break;
		case PAREN:
			tmp ~= new MOParens(input);
			break;
		case SPACE:
			input = input[1..$];
			break;
		default:// assume identifier
			break;
		}
	}
	return tmp;
}

IMathObject parseMathExpr(string input) {
	// split the string into IMathObject tokens
	IMathObject[]tokens = splitMathExpr(input);
	// go through the process of turning this thing into a tree instead of a flat list
	// parens are already expanded
	// helper function
	void parseHelper(bool delegate(MOOpType) valid) {
		for (int i = 0;i < tokens.length;i++) {
			auto caster = cast(MOOperation)tokens[i];
			if (caster && valid(caster.op)) {
				// must not be at the beginning or end of the string
				if (i == 0 || i == tokens.length-1) {
					throw new MathParseError("Operators must have 2 operands");
				}
				// subitems must be parens or numbers
				int prev = getPrevElem(tokens,i),next = getNextElem(tokens,i);
				if (prev == -1) {
					throw new MathParseError("Operators must have 2 operands");
				}
				// if this param is an operation, both fields need to be filled
				auto ptmp = cast(MOOperation)tokens[prev];
				if (next == -1) {
					throw new MathParseError("Operators must have 2 operands");
				}
				// if this param is an operation, both fields need to be filled
				auto ntmp = cast(MOOperation)tokens[next];
				// move the adjacent objects into the tree
				caster.operands ~= tokens[prev];
				tokens[prev] = null;
				caster.operands ~= tokens[next];
				tokens[next] = null;
			}
		}
	}
	// multiplication or addition
	parseHelper((MOOpType o){return o == MOOpType.Addition;});
	parseHelper((MOOpType o){return o == MOOpType.Multiplication;});
	// verify that we're left with a single item in the list
	long count = 0;
	uint first;
	foreach(uint i,c;tokens) if (c) {count++;first=i;}
	if (count != 1) {
		throw new MathParseError("FUUUUUUUUUUU count="~to!string(count));
	}
	return tokens[first];
}



int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto raw_input = file.readText().split("\n");
	if (raw_input[$-1] == "") raw_input.popBack;

	auto expr = raw_input.map!(a => a.parseMathExpr.evaluate(null)).array();
	writeln(cast(ulong)expr.fold!((a,b) => a+b));
	return 0;
}
