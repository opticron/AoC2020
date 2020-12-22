import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop;
import std.algorithm:map, sort, reduce, count, swap, filter, minIndex;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;

void parse_mask(string mask, ref ulong ones_mask, ref ulong zeroes_mask) {
	ones_mask = 0;
	zeroes_mask = 0;
	foreach (mask_element;mask) {
		ones_mask <<= 1;
		zeroes_mask <<= 1;
		switch(mask_element) {
		default:
			break;
		case '1':
			ones_mask |= 1;
			break;
		case '0':
			zeroes_mask |= 1;
			break;
		}
	}
}

ulong apply_mask(ulong value, ulong ones_mask, ulong zeroes_mask) {
	value |= ones_mask;
	value &= ~zeroes_mask;
	return value;
}

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto raw_input = file.readText().split("\n");
	if (raw_input[$-1] == "") raw_input.popBack;
	ulong ones_mask, zeroes_mask;
	ulong[ulong]address_space;
	foreach (command;raw_input) {
		auto parts = command.split(" = ");
		if (parts[0] == "mask") {
			parse_mask(parts[1], ones_mask, zeroes_mask);
			continue;
		}
		ulong address = parts[0].chompPrefix("mem[").chop.to!ulong;
		ulong value = parts[1].to!ulong.apply_mask(ones_mask, zeroes_mask);
		address_space[address] = value;
	}
	ulong acc = 0;
	foreach (value;address_space.values) {
		acc += value;
	}
	writeln(address_space);
	writeln(acc);
	return 0;
}
