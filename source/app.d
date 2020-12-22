import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf;
import std.algorithm:map, sort, reduce, count, swap;
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
	int ns = 0;
	int ew = 0;
	string directions = "NESW";
	char current_direction = 'E';
	foreach (entry;raw_input) {
		char command = entry[0];
		int value = entry[1..$].to!(int);
eval_f:		switch(command) {
		case 'N':
			ns += value;
			break;
		case 'S':
			ns -= value;
			break;
		case 'E':
			ew += value;
			break;
		case 'W':
			ew -= value;
			break;
		case 'R':
			value /= 90;
			current_direction = directions[(directions.indexOf(current_direction)+value)%4];
			break;
		case 'L':
			value /= 90;
			current_direction = directions[(directions.indexOf(current_direction)-value+4)%4];
			break;
		case 'F':
			command = current_direction;
			goto eval_f;
		default:
			break;
		}
	}
	writeln(abs(ns)+abs(ew));
	return 0;
}
