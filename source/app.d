import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop;
import std.algorithm:map, sort, fold, swap, filter, minIndex;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;
import std.bitmanip:BitArray;

class Tile {
	Tile upNeighbor;
	Tile downNeighbor;
	Tile leftNeighbor;
	Tile rightNeighbor;
	BitArray upBorder;
	BitArray downBorder;
	BitArray leftBorder;
	BitArray rightBorder;
	ulong number;
	this(string tile) {
		auto parts = tile.split("\n");
		if (parts[$-1] == "") parts.popBack;
		string header = parts[0];
		parts = parts[1..$];
		header = header.chompPrefix("Tile ");
		header = header[0..$-1];
		number = header.to!ulong;

		// tiles are always square
		leftBorder.length = parts.length;
		rightBorder.length = parts.length;
		upBorder.length = parts.length;
		downBorder.length = parts.length;
		upBorder = BitArray(parts[0].map!(a => a == '#').array());
		downBorder = BitArray(parts[$-1].map!(a => a == '#').array());
		foreach (i, part;parts) {
			leftBorder[i] = (part[0] == '#');
			rightBorder[i] = (part[$-1] == '#');
		}
	}

	BitArray[]getBorders() { return [upBorder,downBorder,leftBorder,rightBorder]; }

	int findNeighbors() {
		int neighbors = 0;
		foreach (tile;tiles) {
			// don't match a tile against itself
			if (number == tile.number) continue;
			foreach (i, local_edge;getBorders) {
				foreach (remote_edge;tile.getBorders) {
					bool match = false;
					if (local_edge == remote_edge) {
						match = true;
					}
					remote_edge.reverse;
					if (match || local_edge == remote_edge) {
						neighbors++;
						switch (i) {
						case 0:
							upNeighbor = tile;
							break;
						case 1:
							downNeighbor = tile;
							break;
						case 2:
							leftNeighbor = tile;
							break;
						default:
							rightNeighbor = tile;
							break;
						}
					}
				}
			}
		}
		return neighbors;
	}
}

Tile[]tiles;

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto raw_input = file.readText().split("\n\n");
	if (raw_input[$-1] == "") raw_input.popBack;

	foreach (tiledef;raw_input) {
		tiles ~= new Tile(tiledef);
	}

	Tile[]corners;
	foreach (tile;tiles) {
		int neighbors = tile.findNeighbors();
		if (neighbors == 2) corners ~= tile;
		if (corners.length == 4) break;
	}
	ulong corner_mult = 1;
	foreach (tile;corners) {
		corner_mult *= tile.number;
	}
	writeln(corner_mult);
	return 0;
}
