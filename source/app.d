import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:map, sort, reduce;
import std.conv:to;
import std.array:array;
import std.range;

ulong[][]break_input(ulong[]input) {
	ulong[][]input_sets = [];
	int set_run = 0;
	while (input.length > set_run+1) {
		if (input[set_run+1] - input[set_run] < 3) {
			set_run++;
			continue;
		}
		// break the set off
		if (set_run > 1) {
			input_sets ~= input[0..set_run+1];
		}
		input = input[set_run+1..$];
		set_run = 0;
	}
	// add the final set
	if (input.length > 2) input_sets ~= input;
	return input_sets;
}

ulong[]generate_bitarray(int i, ulong[]input) {
	ulong[]generated = [];
	int position = 0;
	while(i > 0) {
		if (i&1) generated ~= input[position];
		i>>=1;
		position++;
	}
	return generated;
}

bool is_valid_sequence(ulong[]generated) {
	foreach (pair;zip(generated[0..$-1], generated[1..$])) {
		if (pair[1]-pair[0] > 3) return false;
	}
	return true;
}

ulong get_traversals(ulong[]input) {
	ulong initial = input.front;
	input.popFront;
	ulong terminal = input.back;
	input.popBack;
	ulong count = 0;
	foreach (i;0..(1<<input.length)) {
		ulong[]generated = [initial] ~ generate_bitarray(i, input) ~ [terminal];
		if (is_valid_sequence(generated)) {
			count++;
		}
	}
	return count;
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
	ulong[]input = raw_input.map!("a.to!(ulong)").array();
	input.sort;
	auto input_dup = input.dup;
	input = 0 ~ input;
	ulong[][]input_sets = break_input(input);
	ulong[]set_traversals = input_sets.map!(get_traversals)().array();
	writeln(reduce!"a*b"(cast(ulong)1, set_traversals));
	return 0;
}
