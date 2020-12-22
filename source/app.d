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

	ulong card_key = raw_input[0].to!ulong;
	ulong door_key = raw_input[1].to!ulong;
	ulong card_loops = card_key.getLoopNumber();
	ulong door_loops = door_key.getLoopNumber();
	writeln("card loop: ", card_loops);
	writeln("door loop: ", door_loops);
	ulong enc_card = door_key.performLoops(card_loops);
	ulong enc_door = card_key.performLoops(door_loops);
	writeln("card enc: ",enc_card);
	writeln("door enc: ",enc_door);
	return 0;
}

ulong getLoopNumber(ulong key) {
	ulong subject = 7;
	ulong value = 1;
	ulong loops = 0;
	while (value != key) {
		value *= subject;
		value %= 20201227;
		loops++;
	}
	return loops;
}

ulong performLoops(ulong subject, ulong loops) {
	ulong value = 1;
	foreach (i; 0..loops) {
		value *= subject;
		value %= 20201227;
	}
	return value;
}
