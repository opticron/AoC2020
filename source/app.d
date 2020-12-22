import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split;
import std.algorithm:canFind;
import std.conv:to;

struct op {
	char type;
	int param;
	bool visited = false;
	static op opCall(string raw_op) {
		op this_op;
		auto op_parts = raw_op.split;
		this_op.type = op_parts[0][0];
		this_op.param = op_parts[1].to!(int);
		return this_op;
	}
	void execute() {
		if (visited) throw new Exception("Loop detected");
		switch(type) {
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
	void toggle_type() {
		switch(type) {
		case 'n':
			type = 'j';
			break;
		case 'a':
			throw new Exception("Untoggleable");
		case 'j':
			type = 'n';
			break;
		default:
			break;
		}
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
	// modify each instruction and try running it
	foreach(i; 0..ops.length) {
		try {
			auto mod_ops = ops.dup;
			mod_ops[i].toggle_type();
			acc = 0;
			current_op = 0;
			while(current_op < mod_ops.length) {
				// execute current instruction
				mod_ops[current_op].execute();
			}
			// execution successful
			break;
		} catch (Exception e) {
			// either it failed to run or it threw on modification
		}
	}
	writeln(acc);
	return 0;
}
