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
		int[char]answers;
		// being lazy here...and it paid off
		foreach (answer;group) {
			if (answer >= 'a' && answer <= 'z') {
				if (answer !in answers) answers[answer] = 0;
				answers[answer]++;
			}
		}
		auto group_members = group.split("\n");
		ulong num_group = group_members.length;
		// handle trailing newline
		if (group_members[$-1] == "") num_group--;
		int all_answered = 0;
		foreach (key;answers.keys) {
			if (num_group == answers[key]) all_answered++;
		}
		accum += all_answered;
	}
	writeln(accum);
	return 0;
}
