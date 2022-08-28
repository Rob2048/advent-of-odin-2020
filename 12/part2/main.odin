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
	
	waypoint_x := 10
	waypoint_y := 1

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		instruction := line[0]
		value := strconv.atoi(line[1:])
		fmt.println(line, instruction, value)

		switch instruction {
			case 'F':
				ship_x += waypoint_x * value
				ship_y += waypoint_y * value
			case 'L': 
				for value != 0 {
					value -= 90
					waypoint_x, waypoint_y = -waypoint_y, waypoint_x
				}
			case 'R': 
				for value != 0 {
					value -= 90
					waypoint_x, waypoint_y = waypoint_y, -waypoint_x
				}
			case 'N': waypoint_y += value
			case 'E': waypoint_x += value
			case 'S': waypoint_y -= value
			case 'W': waypoint_x -= value
		}

		fmt.println(ship_x, ship_y)
	}

	distance := abs(ship_x) + abs(ship_y)
	fmt.println(distance)
}