package main

import "core:fmt"
import "core:os"
import "core:strings"

Travel :: struct {
	x: int,
	y: int
}

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

	travels := []Travel{
		{ 1, 1 },
		{ 3, 1 },
		{ 5, 1 },
		{ 7, 1 },
		{ 1, 2 },
	}

	tree_count : int = 1

	for travel in travels {
		tree_count *= check_slope(grid[:], grid_width, grid_height, travel.x, travel.y)
	}

	fmt.println("Trees:", tree_count)
}

check_slope :: proc(grid: []u8, grid_width: int, grid_height: int, travel_x: int, travel_y: int) -> (int) {
	pos_x: int = 0
	pos_y: int = 0
	result: int = 0

	for pos_y < grid_height {
		pos_x = (pos_x + travel_x) % grid_width
		pos_y += travel_y

		grid_index := pos_x + pos_y * grid_width

		if grid_index >= grid_width * grid_height {
			break
		}

		if grid[grid_index] == '#' {
			result += 1
		}
	}

	return result
}