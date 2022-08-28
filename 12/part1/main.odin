package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)
	defer delete(file_bytes)

	ship_x := 0
	ship_y := 0
	ship_rot := 1

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		instruction := line[0]
		value := strconv.atoi(line[1:])
		fmt.println(line, instruction, value)

		switch instruction {
			case 'F': 
				switch ship_rot {
					case 0: ship_y += value
					case 1: ship_x += value
					case 2: ship_y -= value
					case 3: ship_x -= value
				}
			case 'L': ship_rot = (ship_rot - value / 90 + 4) % 4
			case 'R': ship_rot = (ship_rot + value / 90 + 4) % 4
			case 'N': ship_y += value
			case 'E': ship_x += value
			case 'S': ship_y -= value
			case 'W': ship_x -= value
		}

		fmt.println(ship_x, ship_y, ship_rot)
	}

	distance := abs(ship_x) + abs(ship_y)
	fmt.println(distance)
}