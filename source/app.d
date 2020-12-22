import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:map, count;
import std.conv:to;

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto lines = file.readText().split("\n");
	int tree_count = 0;
	int stride = 3;
	foreach (i, line;lines) {
		if (!line.length) continue;
		if (line[(i*stride)%line.length] == '#') tree_count++;
	}
	writeln(tree_count);
	return 0;
}
