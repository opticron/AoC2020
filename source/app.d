import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf;
import std.algorithm:map, sort, reduce, count, swap, filter, minIndex;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto raw_input = file.readText().split("\n");
	if (raw_input[$-1] == "") raw_input.popBack;
	ulong startstamp = raw_input[0].to!ulong;
	ulong[]bus_ids = raw_input[1].split(",").filter!(a => a != "x").map!"a.to!ulong".array();
	ulong[]next_departures;
	foreach (bus_id;bus_ids) {
		next_departures ~= bus_id - (startstamp%bus_id);
	}
	long min_wait_index = next_departures.minIndex;
	writeln(bus_ids[min_wait_index] * next_departures[min_wait_index]);
	return 0;
}
