import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop;
import std.algorithm:map, sort, fold, swap, filter, minIndex, canFind, countUntil, remove;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;
import std.bitmanip:BitArray;

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto raw_input = file.readText().split("\n");
	if (raw_input[$-1] == "") raw_input.popBack;

	string[][][string]allergen_lists;
	int[string]wordcounts;
	foreach (line;raw_input) {
		auto parts = line.split(" (contains ");
		auto allergens = parts[1][0..$-1].split(", ");
		auto ingredients = parts[0].split();
		foreach (allergen;allergens) {
			allergen_lists[allergen] ~= ingredients;
		}
		foreach (ingredient;ingredients) {
			if (ingredient !in wordcounts) {
				wordcounts[ingredient] = 0;
			}
			wordcounts[ingredient]++;
		}
	}

	foreach (allergen, ref lists;allergen_lists) {
		string[]common = lists.findCommon();
		lists = [common];
	}
	string[string]found_allergens;
	while (allergen_lists.keys.length) {
		// remove allergens that are known
		foreach (allergen;found_allergens.keys) {
			allergen_lists.remove(allergen);
		}
		// remove ingredients known to contain allergens
		foreach (allergen_ingredient;found_allergens.values()) {
			foreach (allergen, ref lists;allergen_lists) {
				if (lists[0].canFind(allergen_ingredient)) {
					lists[0] = lists[0].remove(lists[0].countUntil(allergen_ingredient));
				}
			}
		}
		// find new matches
		foreach (allergen, lists;allergen_lists) {
			if (lists[0].length == 1) {
				found_allergens[allergen] = lists[0][0];
			}
		}
	}

	foreach (allergen_ingredient;found_allergens.values) {
		 wordcounts.remove(allergen_ingredient);
	}
	int acc = 0;
	foreach (i;wordcounts.values) {
		acc+=i;
	}
	writeln(acc);
	return 0;
}

string[]findCommon(string[][]allergen_lists) {
	string[]common;
	foreach (ingredient;allergen_lists[0]) {
		bool missing = false;
		foreach (list;allergen_lists[1..$]) {
			if (!list.canFind(ingredient)) {
				missing = true;
				break;
			}
		}
		if (!missing) {
			common ~= ingredient;
		}
	}
	return common;
}
