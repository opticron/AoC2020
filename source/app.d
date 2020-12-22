import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:map, count;
import std.conv:to;

int convert(string input, char high) {
	int row = 0;
	foreach(loc;input) {
		row <<= 1;
		if (loc == high) row |= 1;
	}
	return row;
}

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto groups = file.readText().split("\n\n");
	int accum = 0;
	foreach (group;groups) {
		if (!group.length) continue;
		bool[char]answers;
		foreach (answer;group) {
			if (answer >= 'a' && answer <= 'z') {
				answers[answer] = true;
			}
		}
		accum += answers.keys.length;
	}
	writeln(accum);
	return 0;
}
