import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf;
import std.algorithm:map, sort, reduce, count, swap, filter, minIndex, maxIndex;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;

// this works eventually on the full input, but is unbearably slow on a laptop CPU for the final answer of 1012171816131114
// look into diophantine soutions that provide integer answers to systems of equations
// (az+b)%c == 0 can be rewritten as az+b == cx and then solved as a line
// put all 8 of these into a matrix, get RREF form, see wiki page for solution from that point

bool constraints_valid(ulong[]bus_ids, ulong i) {
	ulong stamp = i*bus_ids[0];
	foreach (j,id;bus_ids) {
		if (!id) continue;
		if ((stamp+j)%id) return false;
	}
	return true;
}

int main(string[]argv) {
	string file = "input/sample.txt";
	ulong start = 1;
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
		start = 130000000000;
	}
	auto raw_input = file.readText().split("\n");
	if (raw_input[$-1] == "") raw_input.popBack;
	ulong[]bus_ids = raw_input[1].split(",").map!(a => a == "x"?"0":a).map!"a.to!ulong".array();
	ulong max_index = bus_ids.maxIndex;
	for (ulong i = start; true; i++) {
		if (i%100000000 == 0) writeln(i*bus_ids[max_index]);
		// quick check
		ulong max_stamp = i*bus_ids[max_index];
		if ((max_stamp-max_index)%bus_ids[0]) continue;
		if (constraints_valid(bus_ids, (max_stamp-max_index)/bus_ids[0])) {
			writeln(max_stamp-max_index);
			break;
		}
	}
	return 0;
}
