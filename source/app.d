import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:map;
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
		auto valid_pos = fields[0].split("-").map!("a.to!(int)");
		auto character = fields[1][0];
		auto password = fields[2];
		if ((character == password[valid_pos[0]-1]) ^ (character == password[valid_pos[1]-1])) good_count++;
	}
	writeln(good_count);
	return 0;
}
