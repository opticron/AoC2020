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
	// volume[w][x][y][z]
	BitArray[][][]volume;
	ulong x_len, y_len, z_len, w_len;
	this (ulong w, ulong x, ulong y, ulong z) {
		w_len = w;
		x_len = x;
		y_len = y;
		z_len = z;
		foreach (h; 0..w) {
			BitArray[][]arrarrarr;
			foreach (i; 0..x) {
				BitArray[]arrarr;
				foreach (j; 0..y) {
					BitArray arr;
					arr.length = z;
					arrarr ~= arr;
				}
				arrarrarr ~= arrarr;
			}
			volume ~= arrarrarr;
		}
	}

	uint countAliveNeighbors(ulong w, ulong x, ulong y, ulong z) {
		return countAliveNeighbors(cast(long)w,cast(long)x,cast(long)y,cast(long)z);
	}

	uint countAliveNeighbors(long w, long x, long y, long z) {
		uint acc = 0;
		foreach (h; w-1..w+2) foreach (i; x-1..x+2) foreach (j; y-1..y+2) foreach (k; z-1..z+2) {
			if (h < 0 || i < 0 || j < 0 || k < 0 || h > w_len-1 || i > x_len-1 || j > y_len-1 || k > z_len-1) continue;
			if (h == w && i == x && j == y && k == z) continue;
			if (volume[h][i][j][k]) acc++;
		}
		return acc;
	}

	uint countAlive() {
		uint acc = 0;
		foreach (h; 0..w_len) foreach (i; 0..x_len) foreach (j; 0..y_len) foreach (k; 0..z_len) {
			acc += volume[h][i][j][k]?1:0;
		}
		return acc;
	}

	bool opIndex(ulong w, ulong x, ulong y, ulong z) {
		if (w > w_len-1 || x > x_len-1 || y > y_len-1 || z > z_len-1) return false;
		return volume[w][x][y][z];
	}

	bool opIndexAssign(bool value, ulong w, ulong x, ulong y, ulong z) {
		if (w > w_len-1 || x > x_len-1 || y > y_len-1 || z > z_len-1) return false;
		volume[w][x][y][z] = value;
		return value;
	}

	void clear() {
		foreach (h; 0..w_len) foreach (i; 0..x_len) foreach (j; 0..y_len) foreach (k; 0..z_len) {
			volume[h][i][j][k] = false;
		}
	}

	bool anyAliveZ(ulong z) {
		foreach (h; 0..w_len) foreach (i; 0..x_len) foreach (j; 0..y_len) {
			if (volume[h][i][j][z]) return true;
		}
		return false;
	}

	bool anyAliveX(ulong x) {
		foreach (h; 0..w_len) foreach (k; 0..z_len) foreach (j; 0..y_len) {
			if (volume[h][x][j][k]) return true;
		}
		return false;
	}

	bool anyAliveW(ulong w) {
		foreach (i; 0..x_len) foreach (k; 0..z_len) foreach (j; 0..y_len) {
			if (volume[w][i][j][k]) return true;
		}
		return false;
	}

	bool anyAliveY(ulong y) {
		foreach (h; 0..w_len) foreach (k; 0..z_len) foreach (i; 0..x_len) {
			if (volume[h][i][y][k]) return true;
		}
		return false;
	}

	override string toString() {
		// narrow required range of output
		ulong wmin=0, wmax=w_len, xmin=0, xmax=x_len, ymin=0, ymax=y_len, zmin=0, zmax=z_len;
		foreach (i; 0..w_len) {
			if (anyAliveW(i)) break;
			wmin++;
		}
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
		foreach_reverse (i; 0..w_len) {
			if (anyAliveW(i)) break;
			wmax--;
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
		foreach (h; wmin..wmax) {
			foreach (k; zmin..zmax) {
				output ~= "w=" ~ h.to!string ~ ", z=" ~ k.to!string ~ ", x=" ~ xmin.to!string ~ "-" ~ (xmax-1).to!string ~ ", y=" ~ ymin.to!string ~ "-" ~ (ymax-1).to!string ~ "\n";
				foreach (i; xmin..xmax) {
					foreach (j; ymin..ymax) {
						output ~= volume[h][i][j][k]?"#":".";
					}
					output ~= "\n";
				}
				output ~= "\n";
			}
		}
		return output;
	}

	void stepAutomata(SimuVol newSim) {
		// assumed same dimensions...
		newSim.clear();
		foreach (h; 0..w_len) foreach (i; 0..x_len) foreach (j; 0..y_len) foreach (k; 0..z_len) {
			ulong acc = countAliveNeighbors(h, i, j, k);
			bool state = volume[h][i][j][k];
			if (state) {
				switch (acc) {
				case 2, 3:
					newSim[h,i,j,k] = true;
					break;
				default:
					// state cleared, nothing to do here
					break;
				}
			} else {
				switch (acc) {
				case 3:
					newSim[h,i,j,k] = true;
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
	ulong w = 1+2*buffer;

	// need two sims to go back and forth easily for each stage
	SimuVol sim1 = new SimuVol(w, x, y, z);
	SimuVol sim2 = new SimuVol(w, x, y, z);

	// parse input and load into sim1
	foreach (i, line;raw_input) {
		foreach (j, bit;line) {
			sim1[1+buffer-1, i+buffer-1, j+buffer-1, 1+buffer-1] = bit=='#';
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
