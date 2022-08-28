package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)

	players: [2][dynamic]int
	defer {
		delete(players[0])
		delete(players[1])
	}

	player_index := 0
	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		fmt.println(line)

		if (len(line) == 0) {
			continue 
		}
		
		if strings.has_prefix(line, "Player") {
			player_index = strconv.atoi(line[7:]) - 1
			fmt.println("Set player to", player_index)
		} else {
			append(&players[player_index], strconv.atoi(line))
		}
	}

	fmt.println(players);

	// Simulate game
	for round := 0; len(players[0]) > 0 && len(players[1]) > 0 ; round += 1{
		fmt.println("-- Round", round + 1, "--")
		fmt.println("Player 1's deck:", players[0])
		fmt.println("Player 2's deck:", players[1])

		p1_plays := pop_front(&players[0])
		p2_plays := pop_front(&players[1])

		fmt.println("Player 1 plays:", p1_plays)
		fmt.println("Player 2 plays:", p2_plays)

		if p1_plays > p2_plays {
			append(&players[0], p1_plays)
			append(&players[0], p2_plays)
		} else {
			append(&players[1], p2_plays)
			append(&players[1], p1_plays)
		}
	}

	// Calculate winner's score
	winner_id := 0
	if len(players[0]) == 0 {
		winner_id = 1
	}
	fmt.println("Player", winner_id + 1, "wins with", players[winner_id])

	total_score := 0
	for card, index in players[winner_id] {
		total_score += card * (len(players[winner_id]) - index)
	}
	fmt.println("Total score:", total_score)
}