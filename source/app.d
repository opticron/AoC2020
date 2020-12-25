import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop;
import std.algorithm:map, sort, fold, count, swap, filter, minIndex, startsWith;
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
	// map out the rulesets
	uint[][][string]rulesets;
	foreach (rule;rules) {
		auto rule_parts = rule.split(": ");
		auto constraints = rule_parts[1].split(" or ").map!(a => a.split("-").map!(a => a.to!uint).array()).array();
		rulesets[rule_parts[0]] = constraints;
	}

	auto my_ticket = raw_input[1].split("\n")[1].split(",").map!(a => a.to!uint).array();

	auto nearby_tickets = raw_input[2].split("\n");
	if (nearby_tickets[$-1] == "") nearby_tickets.popBack;
	// drop header line
	nearby_tickets.popFront;

	// process rules
	// start by dropping rule name since it's not important and condensing each rule to 4 numbers
	auto rule_pairs = rules.map!"a.split(\": \")[1]".map!"a.split(\" or \")";
	string[]seed;
	//uint[][]rulesets = rule_pairs.fold!((a,b) => a ~ b[0] ~ b[1]).map!(a => a.split("-").map!(a => a.to!uint).array()).array();
	// only need to process each ticket once, might as well do it live
	int bad_values = 0;
	uint[][]good_tickets;
	foreach (nearby_ticket;nearby_tickets) {
		bool ticket_good = true;
		uint[]ticket_values = nearby_ticket.split(",").map!(a => a.to!uint).array();
		foreach (value; ticket_values) {
			//if (!matches_something(rulesets, value)) {
			if (!matches_something(rulesets.values.fold!((a,b) => a ~ b[0] ~ b[1]), value)) {
				ticket_good = false;
				break;
			}
		}
		if (!ticket_good) continue;
		good_tickets ~= ticket_values;
	}
	// iterate across the indices available in all tickets
	string[uint]index_to_class;
	uint[][][string]used_classes;
	bool any_changes = true;
	while (any_changes) {
		any_changes = false;
		foreach (i; 0..good_tickets[0].length) {
			// already matched
			if (cast(uint)i in index_to_class) continue;
			// test all values for a given index against each class to see if it matches just one
			// it's guaranteed to match at least one given that the baddies were weeded out
			string matched_class = "";
			foreach (key, value; rulesets) {
				uint all_match = 1;
				// iterate across the given index on each tickets
				foreach (j; 0..good_tickets.length) {
					all_match &= value.matches_something(good_tickets[j][i])?1:0;
				}
				if (all_match) {
					if (matched_class != "") {
						// no singular match, move to next index
						matched_class = "";
						break;
					}
					matched_class = key;
				}
			}
			if (matched_class != "") {
				// singular match, store mapping and remove from pool to match
				index_to_class[cast(uint)i] = matched_class;
				used_classes[matched_class] = rulesets[matched_class];
				rulesets.remove(matched_class);
				any_changes = true;
			}
		}
	}
	ulong acc = 1;
	foreach (i, value; index_to_class) {
		if (value.startsWith("departure")) {
			acc*=my_ticket[i];
		}
	}
	writeln(acc);
	return 0;
}
