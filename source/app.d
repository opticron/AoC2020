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
		player_decks ~= cards.map!(a => a.to!ulong).array();
	}

	ulong[]winning_deck;
	int winner = player_decks.playGame(winning_deck);
	// calculate score
	winning_deck.reverse;
	ulong acc = 0;
	foreach (i,card; winning_deck) {
		acc += card*(i+1);
	}
	writeln(acc);
	return 0;
}

struct PreviousRound {
	ulong[]p1_deck;
	ulong[]p2_deck;
}

// returns 0 for p1, 1 for p2 and winner's deck ref arg
int playGame(ulong[][]player_decks, ref ulong[]winning_deck) {
	PreviousRound[]previousRounds;
game:	while (player_decks[0].length && player_decks[1].length) {
		// check for previous rounds
		foreach (round;previousRounds) {
			if (round.p1_deck == player_decks[0] && round.p2_deck == player_decks[1]) {
				winning_deck = player_decks[0];
				break game;
			}
		}
		previousRounds ~= PreviousRound(player_decks[0], player_decks[1]);
		// get top two cards
		ulong p1card = player_decks[0].front;
		player_decks[0].popFront;
		ulong p2card = player_decks[1].front;
		player_decks[1].popFront;
		ulong winner = 0;
		if (p1card <= player_decks[0].length && p2card <= player_decks[1].length) {
			// RECURSIVE COMBAT
			ulong[]dummy;
			ulong[][]new_decks;
			new_decks ~= player_decks[0][0..p1card];
			new_decks ~= player_decks[1][0..p2card];
			winner = new_decks.playGame(dummy);
		} else {
			if (p2card > p1card) winner = 1;
		}

		if (winner == 0) {
			player_decks[0] ~= [p1card, p2card];
		} else {
			player_decks[1] ~= [p2card, p1card];
		}
	}
	if (player_decks[0].length) {
		winning_deck = player_decks[0];
		return 0;
	}
	winning_deck = player_decks[1];
	return 1;
}
