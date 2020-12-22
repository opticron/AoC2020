import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:canFind;
import std.conv:to;

string sanitize_rule_content(string content) {
	content = content.strip;
	if (content[$-1] == '.') content = content[0..$-1];
	if (content[$-1] == 's') content = content[0..$-1];
	// blindly remove " bag"
	content = content[0..$-4];
	return content;
}

int[string][string]ruleset;
string[][string]contains;
void find_contains(string start, ref string[]total_bags) {
	// assume start has already been added to the total_bags list
	// if start isn't in contains, end condition because nothing contains it
	if (start !in contains) return;
	string[]search = contains[start];
	foreach(item;search) {
		// bag already searched
		if (canFind(total_bags, item)) continue;
		// add bag and continue search
		total_bags ~= item;
		find_contains(item, total_bags);
	}
}

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto rules = file.readText().split("\n");
	// structure of a rules entry "desc" : ["desc":1, "desc": 2]
	// desc contains no numbers or "bag(s)"
	foreach (rule;rules) {
		if (!rule.length) continue;
		auto rule_parts = rule.split(" bags contain ");
		auto rule_name = rule_parts[0];
		auto rule_contents = rule_parts[1].split(",");
		foreach (content;rule_contents) {
			content = sanitize_rule_content(content);
			auto content_parts = content.split;
			if (content_parts[0] == "no") continue;
			string content_name = content_parts[1]~" "~content_parts[2];
			ruleset[rule_name][content_name] = content_parts[0].to!(int);
			contains[content_name] ~= rule_name;
		}
	}
	string[]total_bags = [];
	find_contains("shiny gold", total_bags);
	writeln(total_bags.length);
	return 0;
}
