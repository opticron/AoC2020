import std.stdio:writeln;
import std.file:readText;
import std.string:strip, split, indexOf, chompPrefix, chop, chomp;
import std.algorithm:map, sort, fold, swap, filter, minIndex, canFind, countUntil, remove, reverse;
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
	auto raw_input = file.readText().split("\n\n");
	if (raw_input[$-1] == "") raw_input.popBack;

	ulong[][]player_decks;
	foreach (deck;raw_input) {
		auto cards = deck.chomp.split("\n")[1..$];
		writeln(cards);
		player_decks ~= cards.map!(a => a.to!ulong).array();
	}

	while (player_decks[0].length && player_decks[1].length) {
		// get top two cards
		ulong p1card = player_decks[0].front;
		player_decks[0].popFront;
		ulong p2card = player_decks[1].front;
		player_decks[1].popFront;

		if (p1card > p2card) {
			player_decks[0] ~= [p1card, p2card];
		} else {
			player_decks[1] ~= [p2card, p1card];
		}
		writeln("P1 deck: ",player_decks[0]);
		writeln("P2 deck: ",player_decks[1]);
	}
	auto winner = player_decks[0];
	if (player_decks[1].length) winner = player_decks[1];
	// calculate score
	winner.reverse;
	ulong acc = 0;
	foreach (i,card; winner) {
		acc += card*(i+1);
	}
	writeln(acc);
	return 0;
}
