import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop;
import std.algorithm:map, sort, reduce, count, swap, filter, minIndex;
import std.conv:to;
import std.array:array;
import std.range;
import std.math:abs;

void parse_mask(string mask, ref ulong ones_mask, ref ulong floating_mask_bits, ref ulong[]floating_mask_values) {
	ones_mask = 0;
	floating_mask_bits = 0;
	ulong[]floating_bit_positions = [];
	foreach (i, mask_element;mask) {
		ones_mask <<= 1;
		floating_mask_bits <<= 1;
		switch(mask_element) {
		default:
			break;
		case '1':
			ones_mask |= 1;
			break;
		case 'X':
			floating_bit_positions ~= mask.length-i-1;
			floating_mask_bits |= 1;
			break;
		}
	}
	floating_mask_values = [];
	// generate floating masks
	const ulong ulong_one = 1;
	foreach (ulong index; 0..(ulong_one<<floating_bit_positions.length)) {
		// generate mask one bit at a time
		ulong floating_mask = 0;
		foreach (j, floating_bit_position; floating_bit_positions) {
			// pull the bit from the iterator
			ulong generated_bit_mask = ulong_one<<j;
			bool floating_bit_is_one = cast(bool)(index&generated_bit_mask);
			if (floating_bit_is_one) {
				// apply the bit to the mask
				ulong floating_bit_mask = ulong_one<<floating_bit_position;
				floating_mask |= floating_bit_mask;
			}
		}
		floating_mask_values ~= floating_mask;
	}
}

ulong[]apply_mask(ulong value, ulong ones_mask, ulong floating_mask_bits, ulong[]floating_mask_values) {
	value |= ones_mask;
	// clear all floating mask bits
	value &= ~floating_mask_bits;
	// do floating mask magic here
	ulong[]values = [];
	foreach (mask;floating_mask_values) {
		values ~= value | mask;
	}
	return values;
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
	ulong ones_mask, floating_mask_bits;
	ulong[]floating_mask_values;
	ulong[ulong]address_space;
	foreach (command;raw_input) {
		auto parts = command.split(" = ");
		if (parts[0] == "mask") {
			parse_mask(parts[1], ones_mask, floating_mask_bits, floating_mask_values);
			continue;
		}
		ulong[]addresses = parts[0].chompPrefix("mem[").chop.to!ulong.apply_mask(ones_mask, floating_mask_bits, floating_mask_values);
		ulong value = parts[1].to!ulong;
		foreach (address;addresses) {
			address_space[address] = value;
		}
	}
	ulong acc = 0;
	foreach (value;address_space.values) {
		acc += value;
	}
	writeln(acc);
	return 0;
}
