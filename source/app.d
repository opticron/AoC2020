import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:map, count;
import std.conv:to;
import std.ascii:isHexDigit;

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
item_loop:	foreach(item;entry.split()) {
			auto elements = item.split(":");
			auto element = elements[0];
			switch(element) {
			case "byr": {
				auto year = elements[1].to!(int);
				if (year < 1920 || year > 2002) {
					failed = true;
					break item_loop;
				}
				break;
			}
			case "iyr": {
				auto year = elements[1].to!(int);
				if (year < 2010 || year > 2020) {
					failed = true;
					break item_loop;
				}
				break;
			}
			case "eyr": {
				auto year = elements[1].to!(int);
				if (year < 2020 || year > 2030) {
					failed = true;
					break item_loop;
				}
				break;
			}
			case "hgt": {
				auto unit = elements[1][$-2..$];
				auto number = elements[1][0..$-2].to!(int);
				int upper = 193;
				int lower = 150;
				if (unit == "in") {
					upper = 76;
					lower = 59;
				}
				if (number < lower || number > upper) {
					failed = true;
					break item_loop;
				}
				break;
			}
			case "hcl": {
				string color = elements[1];
				if (color[0] != '#') {
					failed = true;
					break item_loop;
				}
				color = color[1..$];
				auto total_hex = color.count!(isHexDigit);
				if (total_hex != 6) {
					failed = true;
					break item_loop;
				}
				break;
			}
			case "ecl": {
				bool[string]valid_colors = ["amb":1, "blu":1, "brn":1, "gry":1, "grn":1, "hzl":1, "oth":1];
				if (elements[1] in valid_colors) break;
				failed = true;
				break item_loop;
			}
			case "pid": {
				// XXX may need to verify number?
				if (elements[1].length != 9) {
					failed = true;
					break item_loop;
				}
				break;
			}
			case "cid": {
			}
			default: break;
			}
			if (element !in data) {
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
