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
	int good_count = 0;
	foreach (line;lines) {
		if (!line.length) continue;
		auto fields = line.split(" ");
		auto range = fields[0].split("-").map!("a.to!(int)");
		auto character = fields[1][0..1];
		auto password = fields[2];
		auto total = count(password, character[0]);
		if (total >= range[0] && total <= range[1]) good_count++;
	}
	writeln(good_count);
	return 0;
}
