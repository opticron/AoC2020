import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:map, count;
import std.conv:to;

int convert(string input, char high) {
	int row = 0;
	foreach(loc;input) {
		row <<= 1;
		if (loc == high) row |= 1;
	}
	return row;
}

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto entries = file.readText().split("\n");
	int max = 0;
	foreach (entry;entries) {
		if (!entry.length) continue;
		int row = convert(entry[0..7], 'B');
		int seat = convert(entry[7..$], 'R');
		int id = row*8+seat;
		if (id > max) max = id;
	}
	writeln(max);
	return 0;
}
