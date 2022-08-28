package main

import "core:os"
import "core:fmt"
import "core:strings"

draw_grid :: proc(grid: []u8, grid_width: int, grid_height: int) {
	for char, index in grid {
		if index != 0 && index % grid_width == 0 {
			fmt.printf("\n")
		}
		fmt.printf("%c", char)
	}
	fmt.printf("\n")
}

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	if !file_success {
		fmt.panicf("File open failed")
	}

	grid_width := 0
	grid_height := 0

	grid: [dynamic]u8
	defer delete(grid)

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		if grid_width == 0 {
			grid_width = len(line)
		}
		assert(grid_width == len(line))

		for char, index in line {
			append(&grid, u8(char))
		}

		grid_height += 1
	}

	scratch := make([dynamic]u8, len(grid))
	defer delete(scratch)
	
	fmt.println(grid_width, grid_height)
	draw_grid(grid[:], grid_width, grid_height)

	step_iter := 0
	for {
		occupied_seats := 0
		seat_changes := 0

		// Simulation step
		for char, src_index in grid {
			x := src_index % grid_width
			y := src_index / grid_width

			adjacent_count := 0

			for x_iter := -1; x_iter <= 1; x_iter += 1 {
				for y_iter := -1; y_iter <= 1; y_iter += 1 {
					if x_iter == 0 && y_iter == 0 {
						continue 
					}
			
					if trace_seat(grid[:], grid_width, grid_height, x, y, x_iter, y_iter) {
						adjacent_count += 1
					}
				}
			}

			if char == 'L' {
				// No adjacent seats, then sit.
				if adjacent_count == 0 {
					scratch[src_index] = '#'
					occupied_seats += 1
					seat_changes += 1
				} else {
					scratch[src_index] = 'L'
				}
			} else if char == '#' {
				// 4 or more adjacent is get up.
				if adjacent_count >= 5 {
					scratch[src_index] = 'L'
					seat_changes += 1
				} else {
					scratch[src_index] = '#'
					occupied_seats += 1
				}
			} else if char == '.' {
				scratch[src_index] = '.'
			}
		}

		temp_grid := grid
		grid = scratch
		scratch = temp_grid

		step_iter += 1
		fmt.println("Step:", step_iter, "Seats:", occupied_seats, "Changes:", seat_changes)
		// draw_grid(grid[:], grid_width, grid_height)

		if seat_changes == 0 {
			break
		}
	}
}

trace_seat :: proc(grid: []u8, grid_width: int, grid_height: int, start_x: int, start_y: int, dir_x: int, dir_y: int) -> (bool) {
	pos_x := start_x
	pos_y := start_y

	for {
		pos_x += dir_x
		pos_y += dir_y

		if pos_x < 0 || pos_x >= grid_width || pos_y < 0 || pos_y >= grid_height {
			return false
		}

		index := pos_x + pos_y * grid_width
		if grid[index] == 'L' {
			return false
		} else if grid[index] == '#' {
			return true
		}
	}
}