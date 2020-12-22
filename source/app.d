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

	auto instruction_lists = raw_input.map!(a => a.tokenize).array();
	int max_instructions = 0;
	foreach (instruction_list;instruction_lists) {
		if (instruction_list.length > max_instructions) max_instructions = cast(int)instruction_list.length;
	}
	int origin_x = max_instructions;
	int origin_y = max_instructions;
	BitArray[]tiles;
	foreach (i; 0..2*max_instructions) {
		BitArray new_array;
		new_array.length = 2*max_instructions;
		tiles ~= new_array;
	}

	foreach (instruction_list;instruction_lists) {
		int current_x = origin_x;
		int current_y = origin_y;
		foreach (instruction;instruction_list) {
			final switch(instruction) {
			case "e":
				current_x++;
				break;
			case "w":
				current_x--;
				break;
			case "sw":
				current_y--;
				current_x--;
				break;
			case "nw":
				current_y++;
				break;
			case "se":
				current_y--;
				break;
			case "ne":
				current_y++;
				current_x++;
				break;
			}
		}
		tiles[current_y][current_x] = !tiles[current_y][current_x];
	}

	writeln("tiles set: ",tiles.countTiles);
	return 0;
}

int countTiles(BitArray[]tiles) {
	int acc = 0;
	foreach (tile;tiles) {
		acc+= tile.bitsSet.array().length;
	}
	return acc;
}

string[]tokenize(string instructions) {
	string[]instruction_list;
	while (instructions.length) {
		final switch (instructions[0]) {
		case 'e','w':
			instruction_list ~= instructions[0..1];
			instructions.popFront;
			break;
		case 's','n':
			instruction_list ~= instructions[0..2];
			instructions.popFront;
			instructions.popFront;
			break;
		}
	}
	return instruction_list;
}
