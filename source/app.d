import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop;
import std.algorithm:map, sort, fold, swap, filter, minIndex, canFind;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;
import std.bitmanip:BitArray;

interface IRule {
	// return of [] means no match
	int[]match(string);
}

// global mapping of ulongs to IRules
IRule[ulong]rule_mapping;

class AlternationRule:IRule {
	IRule opt1;
	IRule opt2;
	this(string specifier) {
		auto parts = specifier.split(" | ");
		if (parts.length != 2) throw new Exception("no pipe for alternation");
		opt1 = new ListRule(parts[0]);
		opt2 = new ListRule(parts[1]);
	}
	int[]match(string input) {
		int[]accs = opt1.match(input);
		accs ~= opt2.match(input);
		return accs;
	}
}

// matches a literal character
class LiteralRule:IRule {
	char matchChar;
	this(string specifier) {
		// frontline rules need to throw on bad input
		if (specifier.length != 3) throw new Exception("bad len for literal");
		if (specifier[0] != '"') throw new Exception("bad open quote for literal");
		if (specifier[2] != '"') throw new Exception("bad close quote for literal");
		matchChar = specifier[1];
	}
	int[]match(string input) {
		if (!input.length) return [];
		if (input[0] == matchChar) return [1];
		return [];
	}
}

// matches a list of other rules
class ListRule:IRule {
	ulong[]subrules;
	this(string specifier) {
		subrules = specifier.split(" ").map!(a => a.to!ulong).array();
	}
	int[]match(string input) {
		// measure of how many characters were consumed
		int[]accs = [0];
		foreach(rule;subrules) {
			int[]matches;
			foreach (acc;accs) {
				int[]consumed = rule_mapping[rule].match(input[acc..$]);
				if (!consumed.length) continue;
				consumed = consumed.map!(a => a+acc).array();
				matches ~= consumed;
			}
			// expand accs using found match lengths, PERMUTE
			accs = matches;
		}
		return accs;
	}
}


int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto raw_input = file.readText().split("\n\n");
	if (raw_input[$-1] == "") raw_input.popBack;
	auto rule_input = raw_input[0].split("\n");
	if (rule_input[$-1] == "") rule_input.popBack;
	auto message_input = raw_input[1].split("\n");
	if (message_input[$-1] == "") message_input.popBack;

	foreach (rule;rule_input) {
		auto parts = rule.split(": ");
		ulong rulenum = parts[0].to!ulong;
		try {
			IRule newrule = new LiteralRule(parts[1]);
			rule_mapping[rulenum] = newrule;
		} catch (Exception e) try {
			IRule newrule = new AlternationRule(parts[1]);
			rule_mapping[rulenum] = newrule;
		} catch (Exception e) try {
			IRule newrule = new ListRule(parts[1]);
			rule_mapping[rulenum] = newrule;
		} catch (Exception e) {
			// no matches?
			writeln("A bad time was had");
		}
	}

	int total_good = 0;
	foreach (message;message_input) {
		if (rule_mapping[0].match(message).canFind(message.length)) total_good++;
	}
	writeln(total_good);
	return 0;
}
