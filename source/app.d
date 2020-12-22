import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:map;
import std.conv:to;
import std.array:array;
import std.range;

ulong[]input = [];
ulong preamble = 5;

bool verify_match() {
	ulong[]adds = input[0..preamble];
	ulong match = input[preamble];
	foreach (i, value1;adds) foreach (j, value2;adds) {
		if (i == j) continue;
		if (value1+value2==match) return true;
	}
	return false;
}

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		preamble = 25;
		file = argv[1];
	}
	auto raw_input = file.readText().split("\n");
	if (raw_input[$-1] == "") raw_input.popBack;
	input = raw_input.map!("a.to!(ulong)").array();
	while(verify_match()) {
		input.popFront;
	}
	writeln(input[preamble]);
	return 0;
}
