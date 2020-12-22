import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:canFind;
import std.conv:to;

struct op {
	string type;
	int param;
	bool visited = false;
	static op opCall(string raw_op) {
		op this_op;
		auto op_parts = raw_op.split;
		this_op.type = op_parts[0];
		this_op.param = op_parts[1].to!(int);
		return this_op;
	}
	void execute() {
		if (visited) throw new Exception("Loop detected");
		switch(type[0]) {
		case 'n':
			current_op++;
			break;
		case 'a':
			current_op++;
			acc += param;
			break;
		case 'j':
			current_op += param;
			break;
		default:
			break;
		}
		visited = true;
	}
}

int acc = 0;
int current_op = 0;
op[]ops = [];

int main(string[]argv) {
	string file = "input/sample.txt";
	if (argv.length < 2) {
		writeln("defaulting to sample");
	} else {
		file = argv[1];
	}
	auto raw_ops = file.readText().split("\n");
	// read ops
	foreach(raw_op;raw_ops) {
		if (!raw_op.length) continue;
		ops ~= op(raw_op);
	}
	// execute code
	try {
		while(true) {
			// execute current instruction
			ops[current_op].execute();
		}
	} catch (Exception e) {
		writeln(acc);
	}
	return 0;
}
