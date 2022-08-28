package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Tile_Pixel_Size :: 10
Tile_Pixel_Count :: Tile_Pixel_Size * Tile_Pixel_Size

Border :: struct {
	pixels: [Tile_Pixel_Size]int,
	matched_tile_id: int,
}

Tile :: struct {
	id: int,
	pixels: [Tile_Pixel_Count]int,
	borders: [4]Border,
}

match_border :: proc(src: Border, dst: Border) -> (matched: bool) {
	forward_match := true
	reverse_match := true

	for i in 0..<Tile_Pixel_Size {
		if src.pixels[i] != dst.pixels[i] {
			forward_match = false
		}

		if src.pixels[i] != dst.pixels[Tile_Pixel_Size - i - 1] {
			reverse_match = false
		}
	}
	
	return forward_match || reverse_match
}

create_borders :: proc(tile: ^Tile) {
	for i in 0..<4 {
		tile.borders[i].matched_tile_id = 0
	}

	for i in 0..<Tile_Pixel_Size {
		// Top
		tile.borders[0].pixels[i] = tile.pixels[i]
		// Right
		tile.borders[1].pixels[i] = tile.pixels[(Tile_Pixel_Size - 1) + i * Tile_Pixel_Size]
		// Bottom
		tile.borders[2].pixels[i] = tile.pixels[i + (Tile_Pixel_Size - 1) * Tile_Pixel_Size]
		// Left
		tile.borders[3].pixels[i] = tile.pixels[i * Tile_Pixel_Size]
	}
}

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)

	tiles: [dynamic]Tile
	defer {
		// ...
	}

	current_tile: ^Tile = nil
	current_row := 0

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		fmt.println(line)
		if strings.has_prefix(line, "Tile") {
			append(&tiles, Tile{strconv.atoi(line[5:]), {}, {}})
			current_tile = &tiles[len(tiles) - 1]
			current_row = 0
		} else if len(line) == 0 {
			// ...
		} else {
			assert(len(line) == 10)

			for char, char_index in line {
				current_tile.pixels[char_index + current_row * Tile_Pixel_Size] = int(char)
			}

			current_row += 1
		}
	}

	fmt.println(tiles)

	for tile in &tiles {
		create_borders(&tile)
	}

	fmt.println(tiles[0])

	for src_tile, src_tile_index in &tiles {
		for src_border in &src_tile.borders {
			dst_tile_loop: for dst_tile, dst_tile_index in tiles {
				if src_tile_index == dst_tile_index {
					// Can't match against self.
					continue
				}

				for dst_border in dst_tile.borders {
					if match_border(src_border, dst_border) {
						src_border.matched_tile_id = dst_tile.id
						break dst_tile_loop
					}
				}
			}
		}
	}

	final_value := 1

	for tile in tiles {
		fmt.println("Tile", tile.id)

		missing_matches := 0

		for border, border_index in tile.borders {
			if border.matched_tile_id == 0 {
				missing_matches += 1
			}
			fmt.println("  Border", border_index, border.matched_tile_id)
		}

		if missing_matches == 2 {
			final_value *= tile.id
		}
	}

	fmt.println("Final value", final_value)
}