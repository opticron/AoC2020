import std.stdio:writeln,write;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop, chomp;
import std.algorithm:map, sort, fold, swap, filter, minIndex, canFind, countUntil, remove, reverse, maxElement;
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

	int[]cups = raw_input[0].map!(a => (""~cast(char)a).to!int).array();
	writeln(cups);
	DListCircular dcups = new DListCircular(cups);
	int max = 1000000;
	int iterations = 10000000;
	foreach (i;10..max+1) dcups ~= i;
	DListCircular[int]index;
	// iterate over the cups only a single time ever
	foreach (cup;dcups) {
		index[cup.number] = cup;
	}
	int current = dcups.number;
	foreach (i; 0..iterations) {
		if (!(i%100000)) writeln("iteration ",i);
		DListCircular moving = index[current].next.take(3);
		int destination = current;
		do {
			destination--;
			destination += max;
			destination %= max;
			if (!destination) destination = max;
		} while (destination in moving);
		index[destination].insertAfter(moving);
		current = index[current].next.number;
	}
	int one_after = index[1].next.number;
	int two_after = index[1].next.next.number;
	writeln(one_after,", ",two_after);
	writeln(cast(ulong)one_after*cast(ulong)two_after);
	return 0;
}

class DListCircular {
	int number;
	DListCircular prev, next;
	this(int num) {
		number = num;
		prev = this;
		next = this;
	}
	this(int[]nums) {
		this(nums[0]);
		nums.popFront;
		DListCircular local = this;
		foreach (num;nums) {
			local ~= num;
		}
	}
	void opOpAssign(string op)(int num) if (op == "~") {
		DListCircular new_item = new DListCircular(num);
		new_item.next = this;
		new_item.prev = this.prev;
		this.prev.next = new_item;
		this.prev = new_item;
	}
	bool opBinaryRight(string op)(int num) if (op == "in") {
		foreach (cup;this) if (cup.number == num) return true;
		return false;
	}
	DListCircular take(int num) {
		DListCircular head = this;
		DListCircular tail = this;
		foreach (i; 0..num-1) {
			tail = tail.next;
		}
		DListCircular after_tail = tail.next;
		DListCircular before_head = this.prev;
		head.prev = tail;
		tail.next = head;
		before_head.next = after_tail;
		after_tail.prev = before_head;
		return head;
	}
	void insertAfter(DListCircular chunk) {
		auto chunk_end = chunk.prev;
		chunk.prev.next = this.next;
		chunk.prev = this;
		this.next.prev = chunk_end;
		this.next = chunk;
	}
	int opApply(int delegate(DListCircular) dg) {
		DListCircular current = this;
		int res = 0;
		do {
			res = dg(current);
			current = current.next;
		} while (current != this && !res);
		return res;
	}
}
