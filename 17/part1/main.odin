package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math/bits"

Vec3 :: struct {
	x: i32,
	y: i32,
	z: i32,
}

CellAccum :: struct {
	active: bool,
	neighbours: int
}

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)

	current_view := make(map[Vec3]bool)
	defer delete(current_view)

	accumulation_view := make(map[Vec3]CellAccum)
	defer delete(accumulation_view)

	line_count := 0
	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		for char, x in line {
			if char == '#' {
				current_view[Vec3{i32(x), i32(line_count), 0}] = true
			}
		}

		line_count += 1
	}

	// fmt.println(current_view)
	draw_grid(current_view)

	for step_iter := 0; step_iter < 6; step_iter += 1 {
		// Perform a scatter
		for src_pos, src_value in current_view {
			{
				entry, ok := &accumulation_view[src_pos]
				if ok {
					entry.active = true
				} else {
					accumulation_view[src_pos] = CellAccum{true, 0}
				}
			}

			for x := src_pos.x - 1; x <= src_pos.x + 1; x += 1 {
				for y := src_pos.y - 1; y <= src_pos.y + 1; y += 1 {
					for z := src_pos.z - 1; z <= src_pos.z + 1; z += 1 {
						dst_pos := Vec3{x, y, z}

						if dst_pos == src_pos {
							continue
						}

						entry, ok := &accumulation_view[dst_pos]
						if ok {
							entry.neighbours += 1
						} else {
							accumulation_view[dst_pos] = CellAccum{false, 1}
						}
					}
				}
			}
		}

		// fmt.println(accumulation_view)
		
		// Perform a gather
		delete(current_view)
		current_view = make(map[Vec3]bool)

		for src_pos, src_value in accumulation_view {
			if src_value.active && (src_value.neighbours == 2 || src_value.neighbours == 3) {
				current_view[src_pos] = true
			} else if !src_value.active && src_value.neighbours == 3 {
				current_view[src_pos] = true
			}
		}

		delete(accumulation_view)
		accumulation_view = make(map[Vec3]CellAccum)

		fmt.println("Step", step_iter + 1, "Active", len(current_view))
		// fmt.println(current_view)
		draw_grid(current_view)
	}
}

draw_grid :: proc(grid: map[Vec3]bool) {
	bounds_min := Vec3{bits.I32_MAX, bits.I32_MAX, bits.I32_MAX}
	bounds_max := Vec3{bits.I32_MIN, bits.I32_MIN, bits.I32_MIN}

	for cell in grid {
		bounds_min.x = min(bounds_min.x, cell.x)
		bounds_min.y = min(bounds_min.y, cell.y)
		bounds_min.z = min(bounds_min.z, cell.z)

		bounds_max.x = max(bounds_max.x, cell.x)
		bounds_max.y = max(bounds_max.y, cell.y)
		bounds_max.z = max(bounds_max.z, cell.z)
	}

	for z := bounds_min.z; z <= bounds_max.z; z += 1 {
		fmt.printf("z=%d\n", z)
		
		for y := bounds_min.y; y <= bounds_max.y; y += 1 {
			for x := bounds_min.x; x <= bounds_max.x; x += 1 {

				ok := Vec3{x, y, z} in grid

				if ok {
					fmt.printf("#")
				} else {
					fmt.printf(".")
				}
			}

			fmt.printf("\n")
		}

		fmt.printf("\n")
	}
}