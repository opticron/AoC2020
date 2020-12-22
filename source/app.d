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
	auto entries = file.readText().split("\n\n");
	int good_count = 0;
	foreach (entry;entries) {
		if (!entry.length) continue;
		int[string]data;
		int total_elements = 0;
		bool failed = false;
		foreach(item;entry.split()) {
			auto element = item.split(":")[0];
			if (!(element in data)) {
				data[element] = 0;
			}
			data[element]++;
			// don't count cid in the local total
			if (element != "cid") total_elements++;
			if (data[element] > 1) {
				// duplicate elements, fail
				failed = true;
				break;
			}
		}
		if (failed) continue;
		if (total_elements != 7) continue;
		good_count++;
	}
	writeln(good_count);
	return 0;
}
