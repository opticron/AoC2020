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
int find_contains(string start) {
	// assume start has already been added to the total_bags list
	// if start isn't in ruleset, end condition because it contains nothing
	if (start !in ruleset) return 0;
	int total = 0;
	string[]search = ruleset[start].keys;
	foreach(item;search) {
		// add one for each of the top-level bags in this one
		total += ruleset[start][item];
		// add the number of bags it contains for each of the top-level bags in this one
		total += ruleset[start][item] * find_contains(item);
	}
	return total;
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
	int total_bags = find_contains("shiny gold");
	writeln(total_bags);
	return 0;
}
