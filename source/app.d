import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop, chomp;
import std.algorithm:map, sort, fold, swap, filter, minIndex, canFind, countUntil, remove, reverse, maxElement;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;
import std.bitmanip:BitArray;

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto raw_input = file.readText().split("\n");
	if (raw_input[$-1] == "") raw_input.popBack;

	int[]cups = raw_input[0].map!(a => (""~cast(char)a).to!int).array();
	writeln(cups);
	foreach (i;10..1000001) cups ~= i;
	foreach (i; 0..10000000) {
		if (!(i%100)) writeln("iteration ",i);
		int current = cups.front;
		cups.popFront;
		int[]moving = cups[0..3];
		cups = cups[3..$];
		int dest = moving.getDestination(current);
		ulong destIndex = cups.countUntil(dest);
		cups = cups[0..destIndex+1]~moving~cups[destIndex+1..$]~current;
	}
	ulong one_loc = cups.countUntil(1);
	writeln(cups[one_loc+1],", ",cups[one_loc+2]);
	writeln(cast(ulong)cups[one_loc+1]*cast(ulong)cups[one_loc+2]);
	return 0;
}

int getDestination(int[]cups, int current) {
	do {
		current--;
		if (!current) current = 1000000;
	} while (current == cups[0] || current == cups[1] || current == cups[2]);
	return current;
}
