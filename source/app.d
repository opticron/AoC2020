import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop;
import std.algorithm:map, sort, reduce, count, swap, filter, minIndex;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;

ulong get_next_number(ulong last_number_prev_iteration, bool last_number_new, ulong iteration) {
	if (last_number_new) {
		return 0;
	}
	return iteration - last_number_prev_iteration - 1;
}

void process_number(ref ulong[ulong]elf_memory, ulong number, ulong iteration, ref bool last_number_new, ref ulong last_number_prev_iteration) {
	last_number_new = false;
	if (number !in elf_memory) {
		last_number_new = true;
	} else {
		last_number_prev_iteration = elf_memory[number];
	}
	elf_memory[number] = iteration;
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
	ulong[]starting_numbers = raw_input[0].split(",").map!"a.to!ulong".array();
	// process starting numbers
	ulong[ulong]elf_memory;
	bool last_number_new = false;
	ulong last_number_prev_iteration = 0;
	ulong iterations = 0;
	foreach (number;starting_numbers) {
		process_number(elf_memory, number, iterations, last_number_new, last_number_prev_iteration);
		iterations++;
	}
	// run through the iterations, <30000000 is fine here since we start at 0
	ulong next;
	for (;iterations < 30000000; iterations++) {
		next = get_next_number(last_number_prev_iteration, last_number_new, iterations);
		process_number(elf_memory, next, iterations, last_number_new, last_number_prev_iteration);
	}
	writeln(next);
	return 0;
}
