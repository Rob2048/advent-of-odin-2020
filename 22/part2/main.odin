package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Game_State :: struct {
	players: [2][dynamic]int,
}

Sub_Game :: struct {
	id:           int,
	round:        int,
	states:       [dynamic]Game_State,
	player1_temp: int,
	player2_temp: int,
}

Game :: struct {
	sub_games:       [dynamic]Sub_Game,
	total_sub_games: int,
	total_wins:      int,
}

advance_game :: proc(game: ^Game) -> (concluded: bool) {
	latest_game := &game.sub_games[len(game.sub_games) - 1]
	latest_state := &latest_game.states[len(latest_game.states) - 1]
	decks := &latest_state.players
	latest_game.round += 1

	// fmt.println("-- Game", latest_game.id, ":: Round", latest_game.round, "--")
	// fmt.println("Player 1's deck:", decks[0])
	// fmt.println("Player 2's deck:", decks[1])

	if (check_previous_states(latest_game)) {
		fmt.println("INFINITE GAME")
		// Player 1 wins.

		if len(game.sub_games) > 1 {
			// Resolve previous game.

			cleanup_game := pop(&game.sub_games)
			// delete(cleanup_game.states)

			resolve_game := &game.sub_games[len(game.sub_games) - 1]
			resolve_state := &resolve_game.states[len(resolve_game.states) - 1]

			// fmt.println("\n...anyway, back to game", resolve_game.id)

			append(&resolve_state.players[0], resolve_game.player1_temp)
			append(&resolve_state.players[0], resolve_game.player2_temp)

			game.total_wins += 1

		} else {
			// All games are resolved.
			return true
		}

		return false
	}

	// Append new states before any changes made
	temp_decks := decks
	append(
		&latest_game.states,
		Game_State{{make([dynamic]int, len(decks[0])), make([dynamic]int, len(decks[1]))}},
	)
	latest_state = &latest_game.states[len(latest_game.states) - 1]
	decks = &latest_state.players
	copy(decks[0][:], temp_decks[0][:])
	copy(decks[1][:], temp_decks[1][:])

	p1_plays := pop_front(&decks[0])
	p2_plays := pop_front(&decks[1])

	// fmt.println("Player 1 plays:", p1_plays)
	// fmt.println("Player 2 plays:", p2_plays)

	// Check if a subgame needs to be spawned.
	if p1_plays <= len(decks[0]) && p2_plays <= len(decks[1]) {
		// fmt.println("Playing a sub-game to determine the winner...")

		latest_game.player1_temp = p1_plays
		latest_game.player2_temp = p2_plays

		game.total_sub_games += 1
		sub_game := Sub_Game{
			game.total_sub_games,
			0,
			{{{make([dynamic]int, len(decks[0])), make([dynamic]int, len(decks[1]))}}},
			0,
			0,
		}
		copy(sub_game.states[0].players[0][:], decks[0][:])
		copy(sub_game.states[0].players[1][:], decks[1][:])

		append(&game.sub_games, sub_game)

		return false
	}

	if p1_plays > p2_plays {
		append(&decks[0], p1_plays)
		append(&decks[0], p2_plays)
		// fmt.println("Player 1 wins round", latest_game.round, "of game", latest_game.id)
	} else {
		append(&decks[1], p2_plays)
		append(&decks[1], p1_plays)
		// fmt.println("Player 2 wins round", latest_game.round, "of game", latest_game.id)
	}

	// Check if game is won.
	if len(decks[0]) == 0 || len(decks[1]) == 0 {
		game.total_wins += 1

		winner_id := 0

		if len(decks[1]) == 0 {
			winner_id = 0
			// fmt.println("The winner of game", latest_game.id, "is player 1!")
		} else {
			winner_id = 1
			// fmt.println("The winner of game", latest_game.id, "is player 2!")
		}

		if len(game.sub_games) > 1 {
			// Resolve previous game.

			cleanup_game := pop(&game.sub_games)
			fmt.println("Delete state")
			for state in &cleanup_game.states {
				delete(state.players[0])
				delete(state.players[1])

				// state.players[0] = nil
				// state.players[1] = nil
			}
			fmt.println("Done delete")
			delete(cleanup_game.states)
			// cleanup_game.states = nil
			fmt.println("Done cleanup")

			resolve_game := &game.sub_games[len(game.sub_games) - 1]
			resolve_state := &resolve_game.states[len(resolve_game.states) - 1]

			// fmt.println("\n...anyway, back to game", resolve_game.id)

			if winner_id == 0 {
				append(&resolve_state.players[0], resolve_game.player1_temp)
				append(&resolve_state.players[0], resolve_game.player2_temp)
				// fmt.println("Player 1 wins round", resolve_game.round, "of game", resolve_game.id)
			} else {
				append(&resolve_state.players[1], resolve_game.player2_temp)
				append(&resolve_state.players[1], resolve_game.player1_temp)
				// fmt.println("Player 2 wins round", resolve_game.round, "of game", resolve_game.id)
			}
		} else {
			// All games are resolved.
			return true
		}
	}

	return false
}

check_previous_states :: proc(sub_game: ^Sub_Game) -> (match: bool) {
	if len(sub_game.states) == 1 {
		return false
	}

	target_state := sub_game.states[len(sub_game.states) - 1]

	// fmt.println("Compare", sub_game.states)

	outer: for src_state, state_index in sub_game.states {
		if state_index == len(sub_game.states) - 1 {
			continue
		}

		if len(src_state.players[0]) != len(target_state.players[0]) {
			continue
		}

		if len(src_state.players[1]) != len(target_state.players[1]) {
			continue
		}

		for card, card_index in src_state.players[0] {
			if card != target_state.players[0][card_index] {
				continue outer
			}
		}

		for card, card_index in src_state.players[1] {
			if card != target_state.players[1][card_index] {
				continue outer
			}
		}

		return true
	}

	return false
}

print_current_info :: proc(game: Game) {
	latest_game := &game.sub_games[len(game.sub_games) - 1]
	latest_state := &latest_game.states[len(latest_game.states) - 1]

	fmt.println("-- Game", latest_game.id, ":: Round", latest_game.round, "--")
	fmt.println("Player 1's deck:", latest_state.players[0])
	fmt.println("Player 2's deck:", latest_state.players[1])
}

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)

	game: Game

	append(&game.sub_games, Sub_Game{1, 0, {}, 0, 0})
	append(&game.sub_games[0].states, Game_State{})
	initial_game_state := &game.sub_games[0].states[0]
	game.total_sub_games = 1

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
			append(&initial_game_state.players[player_index], strconv.atoi(line))
		}
	}

	fmt.println(game)

	// for _ in 0..<24 {
	for {
		if advance_game(&game) {
			break
		}

		fmt.println("Wins:", game.total_wins, "/", game.total_sub_games, len(game.sub_games))
	}

	print_current_info(game)

	// Calculate winner's score
	// winner_id := 0
	// if len(players[0]) == 0 {
	// 	winner_id = 1
	// }
	// fmt.println("Player", winner_id + 1, "wins with", players[winner_id])

	// total_score := 0
	// for card, index in players[winner_id] {
	// 	total_score += card * (len(players[winner_id]) - index)
	// }
	// fmt.println("Total score:", total_score)
}
