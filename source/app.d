import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:map, count;
import std.conv:to;

int[][]slopes = [
	// right, down, result
	[1, 1, 0],
	[3, 1, 0],
	[5, 1, 0],
	[7, 1, 0],
	[1, 2, 0]
];

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto lines = file.readText().split("\n");
	foreach (i, line;lines) {
		if (!line.length) continue;
		for(int j = 0; j < slopes.length;j++) {
			// skip steeper slopes that won't match
			if (i%slopes[j][1]) {
				continue;
			}
			ulong index = i*slopes[j][0]/slopes[j][1];
			if (line[index%line.length] == '#') slopes[j][2]++;
		}
	}

	// get answer
	int macc = 1;
	for(int i = 0; i < slopes.length;i++) {
		writeln(slopes[i][2]);
		macc *= slopes[i][2];
	}
	writeln(macc);
	return 0;
}
