import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop, chomp;
import std.algorithm:map, sort, fold, swap, filter, minIndex, canFind, reverse, count;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;
import std.bitmanip:BitArray;

class Tile {
	Tile upNeighbor = null;
	BitArray upBorder;

	Tile downNeighbor = null;
	BitArray downBorder;

	Tile leftNeighbor = null;
	BitArray leftBorder;

	Tile rightNeighbor = null;
	BitArray rightBorder;

	ulong number;
	string[]original_image;
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
		original_image = parts;
		generateBorders();
	}

	void generateBorders() {
		upBorder = BitArray(original_image[0].map!(a => a == '#').array());
		downBorder = BitArray(original_image[$-1].map!(a => a == '#').array());
		foreach (i, part;original_image) {
			leftBorder[i] = (part[0] == '#');
			rightBorder[i] = (part[$-1] == '#');
		}
	}

	// directions used: 0 up, 1 down, 2 left, 3 right
	BitArray[]getBorders() { return [upBorder,downBorder,leftBorder,rightBorder]; }

	int findNeighbors() {
		upNeighbor = null;
		downNeighbor = null;
		leftNeighbor = null;
		rightNeighbor = null;
		int neighbors = 0;
		foreach (tile;tiles) {
			// don't match a tile against itself
			if (number == tile.number) continue;
			foreach (i, local_edge;getBorders) {
				foreach (j, remote_edge;tile.getBorders) {
					bool match = false;
					if (local_edge == remote_edge) {
						match = true;
					}
					remote_edge = remote_edge.reverse;
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

	void flipHorizontal() {
		swap(leftNeighbor,rightNeighbor);
		// flip image
		string[]rev;
		foreach (ref line;original_image) {
			auto dup = line.dup;
			dup.reverse;
			rev ~= dup.idup;
		}
		original_image = rev;
		generateBorders();
	}

	void flipVertical() {
		swap(upNeighbor,downNeighbor);
		// flip image
		original_image.reverse;
		generateBorders();
	}

	void rotateLeft() {
		// because I'm a lazy loch ness monster and I demand tree fiddy
		flipVertical();
		flipHorizontal();
		rotateRight();
	}

	void rotateRight() {
		swap(upNeighbor,rightNeighbor);
		swap(upNeighbor,leftNeighbor);
		swap(downNeighbor,leftNeighbor);
		original_image = original_image.rotateRight();
		generateBorders();
	}

	static bool neighborsUnset(Tile tile) {
		return tile && !tile.upNeighbor && !tile.downNeighbor && !tile.leftNeighbor && !tile.rightNeighbor;
	}

	static void spinNeighbor(BitArray border, Tile neighbor, BitArray function(Tile) remote_border) {
		neighbor.flipHorizontal();
		BitArray remote = remote_border(neighbor);
		if (border == remote) return;
		neighbor.flipVertical();
		remote = remote_border(neighbor);
		if (border == remote) return;
		neighbor.flipHorizontal();
		remote = remote_border(neighbor);
		if (border == remote) return;
		// restore to original orientation
		neighbor.flipVertical();
		neighbor.rotateRight();
		remote = remote_border(neighbor);
		if (border == remote) return;
		neighbor.flipHorizontal();
		remote = remote_border(neighbor);
		if (border == remote) return;
		neighbor.flipVertical();
		remote = remote_border(neighbor);
		if (border == remote) return;
		neighbor.flipHorizontal();
		remote = remote_border(neighbor);
		if (border == remote) return;
		throw new Exception("no rotation succeeded?");
	}

	void alignAll() {
		// assume this tile is already properly aligned
		// find all 4 neighbors, if a neighbor has any set neighbors, skip alignment for it since it has already been aligned
		writeln(this);
		ulong[]neighbors;
		findNeighbors();
		if (upNeighbor) neighbors ~= upNeighbor.number;
		if (downNeighbor) neighbors ~= downNeighbor.number;
		if (leftNeighbor) neighbors ~= leftNeighbor.number;
		if (rightNeighbor) neighbors ~= rightNeighbor.number;
		writeln("found neighbors: ",neighbors);
		if (neighborsUnset(upNeighbor)) {
			if (upBorder != upNeighbor.downBorder) {
				// work to do aligning upper border tile
				spinNeighbor(upBorder, upNeighbor, (a => a.downBorder));
			}
			writeln("from ",number);
			upNeighbor.alignAll();
		}
		if (neighborsUnset(downNeighbor)) {
			if (downBorder != downNeighbor.upBorder) {
				// work to do aligning lower border tile
				spinNeighbor(downBorder, downNeighbor, (a => a.upBorder));
			}
			writeln("from ",number);
			downNeighbor.alignAll();
		}
		if (neighborsUnset(leftNeighbor)) {
			if (leftBorder != leftNeighbor.rightBorder) {
				// work to do aligning right border tile
				spinNeighbor(leftBorder, leftNeighbor, (a => a.rightBorder));
			}
			writeln("from ",number);
			leftNeighbor.alignAll();
		}
		if (neighborsUnset(rightNeighbor)) {
			if (rightBorder != rightNeighbor.leftBorder) {
				// work to do aligning left border tile
				spinNeighbor(rightBorder, rightNeighbor, (a => a.leftBorder));
			}
			writeln("from ",number);
			rightNeighbor.alignAll();
		}

	}

	override string toString() {
		string output = "Tile "~number.to!string~"\n";
		foreach (line;original_image) output ~= line ~ "\n";
		return output;
	}

	string[]toStrippedString() {
		string[]output;
		foreach (line;original_image[1..$-1]) output ~= line[1..$-1];
		return output;
	}
}

string[]rotateRight(string[]original_matrix) {
	string[]new_matrix;
	foreach (j; 0..original_matrix[0].length) {
		string new_line;
		foreach_reverse (i, line;original_matrix) {
			new_line ~= original_matrix[i][j];
		}
		new_matrix ~= new_line;
	}
	return new_matrix;
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

	writeln("aligning all");
	tiles[0].alignAll();
	writeln("done aligning all");
	Tile topLeft;
	foreach (tile;tiles) {
		if (tile.downNeighbor && tile.rightNeighbor && !tile.upNeighbor && !tile.leftNeighbor) topLeft = tile;
	}
	Tile output = topLeft;
	string[]total_output;
	while (output) {
		Tile rightput = output;
		string[]row;
		while (rightput) {
			string[]tileoutput = rightput.toStrippedString();
			if (!row.length) {
				row = tileoutput;
			} else {
				// append to the existing rows
				foreach (i, line;tileoutput) {
					row[i] = row[i];
					row[i] ~= line;
				}
			}
			rightput = rightput.rightNeighbor;
			if (!rightput) break;
		}
		total_output ~= row;
		output = output.downNeighbor;
	}
	int nessies_obliterated = 0;
	foreach (i;0..4) {
		// test, then rotate right
		nessies_obliterated = total_output.rip_and_tear_nessie;
		if (nessies_obliterated) break;
		total_output = total_output.rotateRight();
	}
	if (!nessies_obliterated) {
		// flip the tileset
		total_output.reverse;
		foreach (i;0..4) {
			// test, then rotate right
			nessies_obliterated = total_output.rip_and_tear_nessie;
			if (nessies_obliterated) break;
			total_output = total_output.rotateRight();
		}
	}
	foreach (line;total_output) {
		writeln(line);
	}
	ulong total_set = 0;
	foreach (line;total_output) foreach (pixel;line) {
		total_set += (pixel == '#')?1:0;
	}
	writeln(total_set);
	return 0;
}

//                  #
//#    ##    ##    ###
// #  #  #  #  #  #

int[][]nessie = [
	[18],
	[0,5,6,11,12,17,18,19],
	[1,4,7,10,13,16]
];

// search single orientation, other orientations will be searched by flipping/rotating the arrays
// returns the number of nessies obliterated
int rip_and_tear_nessie(ref string[]haystack) {
	int nessies_obliterated = 0;
	foreach (i;1..haystack.length-1) {
restart_hunt:	int pattern_start = haystack[i].find_pattern(nessie[1]);
		if (pattern_start) {
			bool nessie_found = false;
			if (haystack[i-1][pattern_start..$].pattern_exists(nessie[0]) && haystack[i+1][pattern_start..$].pattern_exists(nessie[2])) {
				// blow away nessie
				foreach (offset; -1..2) {
					char[]mutastack = haystack[i+offset].dup;
					foreach(index; nessie[offset+1]) {
						mutastack[pattern_start+index] = 'O';
					}
					haystack[i+offset] = mutastack.idup;
				}
				nessies_obliterated++;
				nessie_found = true;
			}
			// find additional nessies on this line
			if (nessie_found) goto restart_hunt;
		}
	}
	return nessies_obliterated;
}

int find_pattern(string haystack, int[]pattern) {
	foreach (i;0..haystack.length-pattern[$-1]) {
		if (haystack[i..$].pattern_exists(pattern)) return cast(int)i;
	}
	return 0;
}

bool pattern_exists(string haystack, int[]pattern) {
	foreach (i;pattern) {
		if (haystack[i] != '#') return false;
	}
	return true;
}
