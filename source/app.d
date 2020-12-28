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
	foreach (j,id;bus_ids) {
		if (!id) continue;
		if ((i+j)%id) return false;
	}
	return true;
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
	ulong[]bus_ids = raw_input[1].split(",").map!(a => a == "x"?"0":a).map!"a.to!ulong".array();
	// drop 0s off the end
	while (!bus_ids[$-1]) bus_ids = bus_ids[0..$-1];
	ulong step_size = bus_ids[0];
	ulong search_target_index = 1;
	for (ulong i = 0; true; i+=step_size) {
		while (search_target_index < bus_ids.length && !bus_ids[search_target_index]) search_target_index++;
		// skip 0s
		if (!((i+search_target_index)%bus_ids[search_target_index])) {
			step_size *= bus_ids[search_target_index];
			search_target_index++;
			if (search_target_index == bus_ids.length) {
				writeln(i);
				break;
			}
		}
	}
	return 0;
}
