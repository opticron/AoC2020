import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:map, sum, minElement, maxElement;
import std.conv:to;
import std.array:array;
import std.range;


bool verify_match(ulong[]input, int preamble) {
	ulong[]adds = input[0..preamble];
	ulong match = input[preamble];
	foreach (i, value1;adds) foreach (j, value2;adds) {
		if (i == j) continue;
		if (value1+value2==match) return true;
	}
	return false;
}

ulong[]get_run(ulong[]input, ulong match) {
	while (input.length) {
		int run_len = 2;
		ulong total;
		do {
			auto run = input[0..run_len];
			total = run.sum;
			if (total == match) return run;
			run_len++;
		} while (total < match);
		input.popFront;
	}
	return null;
}

int main(string[]argv) {
	string file = "input/sample.txt";
	int preamble = 5;
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		preamble = 25;
		file = argv[1];
	}
	auto raw_input = file.readText().split("\n");
	if (raw_input[$-1] == "") raw_input.popBack;
	ulong[]input = raw_input.map!("a.to!(ulong)").array();
	auto input_mod = input.dup;
	while(verify_match(input_mod, preamble)) {
		input_mod.popFront;
	}
	ulong match = input_mod[preamble];
	ulong[]run = get_run(input, match);
	writeln(minElement(run)+maxElement(run));
	return 0;
}
