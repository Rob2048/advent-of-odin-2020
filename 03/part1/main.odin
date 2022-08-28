package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	// file_bytes, file_read_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_read_success := os.read_entire_file_from_filename("../puzzle.txt")
	if !file_read_success {
		fmt.println("File open failed")
		return
	}

	file_str := string(file_bytes)

	grid_width: int = 0
	grid_height: int = 0
	grid: [dynamic]u8

	line_iter := file_str
	for line in strings.split_lines_iterator(&line_iter) {
		if grid_width == 0 {
			grid_width = len(line)
			fmt.println("Width", grid_width)
		}

		grid_height += 1

		append(&grid, line)
	}

	fmt.println("Height", grid_height)
	// fmt.println(grid)

	pos_x: int = 0
	pos_y: int = 0
	tree_count: int = 0

	for pos_y < grid_height {
		pos_x = (pos_x + 3) % grid_width
		pos_y += 1

		grid_index := pos_x + pos_y * grid_width

		if grid_index >= grid_width * grid_height {
			break
		}

		if grid[grid_index] == '#' {
			tree_count += 1
		}
	}

	fmt.println("Trees:", tree_count)
}