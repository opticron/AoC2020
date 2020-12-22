import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop;
import std.algorithm:map, sort, reduce, swap, filter, minIndex;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;
import std.bitmanip:BitArray;

class SimuVol {
	// volume[x][y][z]
	BitArray[][]volume;
	ulong x_len, y_len, z_len;
	this (ulong x, ulong y, ulong z) {
		x_len = x;
		y_len = y;
		z_len = z;
		foreach (i; 0..x) {
			BitArray[]arrarr;
			foreach (j; 0..y) {
				BitArray arr;
				arr.length = z;
				arrarr ~= arr;
			}
			volume ~= arrarr;
		}
	}

	uint countAliveNeighbors(ulong x, ulong y, ulong z) {
		return countAliveNeighbors(cast(long)x,cast(long)y,cast(long)z);
	}

	uint countAliveNeighbors(long x, long y, long z) {
		uint acc = 0;
		foreach (i; x-1..x+2) foreach (j; y-1..y+2) foreach (k; z-1..z+2) {
			if (i < 0 || j < 0 || k < 0 || i > x_len-1 || j > y_len-1 || k > z_len-1) continue;
			if (i == x && j == y && k == z) continue;
			if (volume[i][j][k]) acc++;
		}
		return acc;
	}

	uint countAlive() {
		uint acc = 0;
		foreach (i; 0..x_len) foreach (j; 0..y_len) foreach (k; 0..z_len) {
			acc += volume[i][j][k]?1:0;
		}
		return acc;
	}

	bool opIndex(ulong x, ulong y, ulong z) {
		if (x < 0 || y < 0 || z < 0 || x > x_len-1 || y > y_len-1 || z > z_len-1) return false;
		return volume[x][y][z];
	}

	bool opIndexAssign(bool value, long x, long y, long z) {
		if (x < 0 || y < 0 || z < 0 || x > x_len-1 || y > y_len-1 || z > z_len-1) return false;
		volume[x][y][z] = value;
		return value;
	}

	void clear() {
		foreach (i; 0..x_len) foreach (j; 0..y_len) foreach (k; 0..z_len) {
			volume[i][j][k] = false;
		}
	}

	bool anyAliveZ(ulong z) {
		foreach (i; 0..x_len) foreach (j; 0..y_len) {
			if (volume[i][j][z]) return true;
		}
		return false;
	}

	bool anyAliveX(ulong x) {
		foreach (k; 0..z_len) foreach (j; 0..y_len) {
			if (volume[x][j][k]) return true;
		}
		return false;
	}

	bool anyAliveY(ulong y) {
		foreach (k; 0..z_len) foreach (i; 0..x_len) {
			if (volume[i][y][k]) return true;
		}
		return false;
	}

	override string toString() {
		// narrow required range of output
		ulong xmin=0, xmax=x_len, ymin=0, ymax=y_len, zmin=0, zmax=z_len;
		foreach (i; 0..x_len) {
			if (anyAliveX(i)) break;
			xmin++;
		}
		foreach (i; 0..y_len) {
			if (anyAliveY(i)) break;
			ymin++;
		}
		foreach (i; 0..z_len) {
			if (anyAliveZ(i)) break;
			zmin++;
		}
		foreach_reverse (i; 0..x_len) {
			if (anyAliveX(i)) break;
			xmax--;
		}
		foreach_reverse (i; 0..y_len) {
			if (anyAliveY(i)) break;
			ymax--;
		}
		foreach_reverse (i; 0..z_len) {
			if (anyAliveZ(i)) break;
			zmax--;
		}

		// now that extents have been minimized, display output
		string output;
		foreach (k; zmin..zmax) {
			output ~= "z=" ~ k.to!string ~ ", x=" ~ xmin.to!string ~ "-" ~ (xmax-1).to!string ~ ", y=" ~ ymin.to!string ~ "-" ~ (ymax-1).to!string ~ "\n";
			foreach (i; xmin..xmax) {
				foreach (j; ymin..ymax) {
					output ~= volume[i][j][k]?"#":".";
				}
				output ~= "\n";
			}
			output ~= "\n";
		}
		return output;
	}

	void stepAutomata(SimuVol newSim) {
		// assumed same dimensions...
		newSim.clear();
		foreach (i; 0..x_len) foreach (j; 0..y_len) foreach (k; 0..z_len) {
			ulong acc = countAliveNeighbors(i, j, k);
			bool state = volume[i][j][k];
			if (state) {
				switch (acc) {
				case 2, 3:
					newSim[i,j,k] = true;
					break;
				default:
					// state cleared, nothing to do here
					break;
				}
			} else {
				switch (acc) {
				case 3:
					newSim[i,j,k] = true;
					break;
				default:
					// state cleared, nothing to do here
					break;
				}
			}
		}
	}
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

	// 6 cycles, start with 1 z layer
	// each dimension needs to be at least starting size+2*buffer
	ulong cycles = 6;
	ulong buffer = 2*cycles;
	ulong x = raw_input.length+2*buffer;
	ulong y = raw_input[0].length+2*buffer;
	ulong z = 1+2*buffer;

	// need two sims to go back and forth easily for each stage
	SimuVol sim1 = new SimuVol(x, y, z);
	SimuVol sim2 = new SimuVol(x, y, z);

	// parse input and load into sim1
	foreach (i, line;raw_input) {
		foreach (j, bit;line) {
			sim1[i+buffer-1, j+buffer-1, 1+buffer-1] = bit=='#';
		}
	}
	//writeln(sim1);
	sim1.stepAutomata(sim2);
	sim2.stepAutomata(sim1);
	sim1.stepAutomata(sim2);
	sim2.stepAutomata(sim1);
	sim1.stepAutomata(sim2);
	//writeln(sim2);
	//writeln(sim2.countAlive);
	sim2.stepAutomata(sim1);
	//writeln(sim1);
	writeln(sim1.countAlive);
	return 0;
}
