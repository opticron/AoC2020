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
	int origin_x = max_instructions+100;
	int origin_y = max_instructions+100;
	BitArray[]tilesa;
	BitArray[]tilesb;
	foreach (i; 0..2*origin_y) {
		BitArray new_arraya;
		new_arraya.length = 2*origin_x;
		tilesa ~= new_arraya;
		BitArray new_arrayb;
		new_arrayb.length = 2*origin_x;
		tilesb ~= new_arrayb;
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
		tilesa[current_y][current_x] = !tilesa[current_y][current_x];
	}
	foreach (n;0..100) {
		if (n%2) {
			// tilesb origination
			tilesa.clearTiles();
			foreach (i;0..tilesa.length) foreach (j;0..tilesa.length) {
				int neighbors = tilesb.countNeighbors(j, i);
				if (tilesb[j][i]) {
					if (neighbors == 1 || neighbors == 2) {
						tilesa[j][i] = true;
					} else {
						tilesa[j][i] = false;
					}
				} else {
					if (neighbors == 2) {
						tilesa[j][i] = true;
					} else {
						tilesa[j][i] = false;
					}
				}
			}
		} else {
			// tilesa origination
			tilesb.clearTiles();
			foreach (i;0..tilesa.length) foreach (j;0..tilesa.length) {
				int neighbors = tilesa.countNeighbors(j, i);
				if (tilesa[j][i]) {
					if (neighbors == 1 || neighbors == 2) {
						tilesb[j][i] = true;
					} else {
						tilesb[j][i] = false;
					}
				} else {
					if (neighbors == 2) {
						tilesb[j][i] = true;
					} else {
						tilesb[j][i] = false;
					}
				}
			}
		}
	}
	writeln(tilesa.countTiles);
	return 0;
}

void clearTiles(ref BitArray[]tiles) {
	foreach (i;0..tiles.length) foreach (j;0..tiles.length) tiles[j][i] = false;
}

int countNeighbors(BitArray[]tiles, ulong current_y, ulong current_x) {
	return countNeighbors(tiles, cast(int)current_y, cast(int)current_x);
}
int countNeighbors(BitArray[]tiles, int current_y, int current_x) {
	int acc = 0;
	foreach(i;current_x-1..current_x+2) foreach(j;current_y-1..current_y+2) {
		// not neighbors because reasons
		if ((i < current_x && j > current_y) || (i > current_x && j < current_y)) continue;
		// skip self
		if (i == current_x && j == current_y) continue;
		// out of bounds
		if (i < 0 || j < 0 || i >= tiles.length || j >= tiles.length) continue;
		if (tiles[j][i]) acc++;
	}
	return acc;
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
