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
	int ns = 1;
	int ew = 10;
	int ship_ns = 0;
	int ship_ew = 0;
	string directions = "NESW";
	char current_direction = 'E';
	foreach (entry;raw_input) {
		char command = entry[0];
		int value = entry[1..$].to!(int);
		final switch(command) {
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
			final switch(value) {
			case 1:
				swap(ew,ns);
				ns *= -1;
				break;
			case 2:
				ew *= -1;
				ns *= -1;
				break;
			case 3:
				swap(ew,ns);
				ew *= -1;
				break;
			}
			break;
		case 'L':
			value /= 90;
			final switch(value) {
			case 1:
				swap(ew,ns);
				ew *= -1;
				break;
			case 2:
				ew *= -1;
				ns *= -1;
				break;
			case 3:
				swap(ew,ns);
				ns *= -1;
				break;
			}
			break;
		case 'F':
			ship_ns += ns * value;
			ship_ew += ew * value;
			break;
		}
	}
	writeln(abs(ship_ns)+abs(ship_ew));
	return 0;
}
