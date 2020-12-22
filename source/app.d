import std.stdio:writeln;
import std.file:readText;
import std.string:split;
import std.algorithm:map;
import std.conv:to;

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto entries = file.readText().split().map!("a.to!(int)");
	foreach (entry;entries) {
		foreach (entry2;entries) {
			if (entry+entry2 == 2020) {
				writeln(entry*entry2);
				return 0;
			}
		}
	}
	return 0;
}
