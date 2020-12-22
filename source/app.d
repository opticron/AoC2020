import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop;
import std.algorithm:map, sort, reduce, count, swap, filter, minIndex;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;

bool matches_something(uint[][]rulesets, uint value) {
	foreach (ruleset; rulesets) {
		if (value >= ruleset[0] && value <= ruleset[1]) return true;
	}
	return false;
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
	auto rules = raw_input[0].split("\n");
	if (rules[$-1] == "") rules.popBack;

	// ignored for now
	auto my_ticket = raw_input[1].split("\n")[1];

	auto nearby_tickets = raw_input[2].split("\n");
	if (nearby_tickets[$-1] == "") nearby_tickets.popBack;
	// drop header line
	nearby_tickets.popFront;

	// process rules
	// start by dropping rule name since it's not important and condensing each rule to 4 numbers
	auto rule_pairs = rules.map!"a.split(\": \")[1]".map!"a.split(\" or \")";
	string[]seed;
	uint[][]rulesets = rule_pairs.reduce!((a,b) => a ~ b[0] ~ b[1]).map!(a => a.split("-").map!(a => a.to!uint).array()).array();
	// only need to process each ticket once, might as well do it live
	int bad_values = 0;
	foreach (nearby_ticket;nearby_tickets) {
		foreach (value; nearby_ticket.split(",").map!(a => a.to!uint)) {
			if (!matches_something(rulesets, value)) {
				bad_values+=value;
			}
		}
	}
	writeln(bad_values);
	return 0;
}
