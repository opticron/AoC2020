import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:map, sort, reduce;
import std.conv:to;
import std.array:array;
import std.range;

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto raw_input = file.readText().split("\n");
	if (raw_input[$-1] == "") raw_input.popBack;
	ulong[]input = raw_input.map!("a.to!(ulong)").array();
	input.sort;
	auto input_dup = input.dup;
	input = 0 ~ input;
	input_dup ~= input.back+3;
	int three_diff = 0;
	int one_diff = 0;
	foreach (pair;zip(input, input_dup)) {
		auto diff = pair[1]-pair[0];
		if (diff == 3) three_diff++;
		if (diff == 1) one_diff++;
	}
	writeln(one_diff*three_diff);
	return 0;
}
