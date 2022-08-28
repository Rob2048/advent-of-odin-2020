package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:sort"

find_seat_id :: proc(pass: string) -> (int) {
	current_min: int = 0
	current_max: int = 127
	for char in pass[0:7] {
		if (char == 'F') {
			diff := current_max - current_min
			current_max -= diff / 2 + 1
		} else if (char == 'B') {
			diff := current_max - current_min
			current_min += diff / 2 + 1
		}
	}

	row := current_min

	current_min = 0
	current_max = 7
	for char in pass[7:] {
		if (char == 'L') {
			diff := current_max - current_min
			current_max -= diff / 2 + 1
		} else if (char == 'R') {
			diff := current_max - current_min
			current_min += diff / 2 + 1
		}
	}

	column := current_min
	seat_id := row * 8 + column
	fmt.println("Pass:", pass, row, column, seat_id)

	return seat_id
}

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)
	defer delete(file_bytes)

	seats: [dynamic]int
	
	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		append(&seats, find_seat_id(line))
	}

	sort.bubble_sort(seats[:])

	fmt.println(seats)

	for seat, index in seats[1:] {
		if seats[index] != seat - 1 {
			fmt.println("Skip at", seat, "(", seat - 1, ")")
			break
		}
	}
}