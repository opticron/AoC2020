import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:map, sort, reduce, count, swap;
import std.conv:to;
import std.array:array;
import std.range;

bool apply_change(char[][]seats, ref char[][]new_seats, ulong i_orig, ulong j_orig) {
	int occupied_adj = 0;
	long i = i_orig;
	long j = j_orig;
	foreach (i_adj; (i-1)..(i+2)) foreach (j_adj; (j-1)..(j+2)) {
		if (i_adj == i && j_adj == j) continue;
		if (i_adj < 0) continue;
		if (j_adj < 0) continue;
		if (i_adj >= seats.length) continue;
		if (j_adj >= seats[i].length) continue;
		if (seats[i_adj][j_adj] == '#') occupied_adj++;
	}
	bool changed = true;
	if (seats[i][j] == '#' && occupied_adj >= 4) {
		new_seats[i][j] = 'L';
	} else if (seats[i][j] == 'L' && occupied_adj == 0) {
		new_seats[i][j] = '#';
	} else {
		new_seats[i][j] = seats[i][j];
		changed = false;
	}
	return changed;
}

bool adjust_seats(char[][]seats, ref char[][]new_seats) {
	bool changed = false;
	foreach (i, row; seats) foreach (j, column; row) {
		if (apply_change(seats, new_seats, i, j)) {
			changed = true;
		}
	}
	return changed;
}

int count_occupied(char[][]seats) {
	int acc = 0;
	foreach (i, row; seats) {
		acc += row.count("#");
	}
	return acc;
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
	char[][]seats = cast(char[][])raw_input;
	char[][]new_seats = [];
	// deep copy input
	foreach (row;seats) new_seats ~= row.dup;
	while(adjust_seats(seats, new_seats)) {
		swap(seats, new_seats);
	}
	writeln(new_seats.count_occupied());
	return 0;
}
