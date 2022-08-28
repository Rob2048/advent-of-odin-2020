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

match_border_forwards :: proc(src: Border, dst: Border) -> (matched: bool) {
	for i in 0..<Tile_Pixel_Size {
		if src.pixels[i] != dst.pixels[i] {
			return false
		}
	}

	return true
}

match_border_reverse :: proc(src: Border, dst: Border) -> (matched: bool) {
	for i in 0..<Tile_Pixel_Size {
		if src.pixels[i] != dst.pixels[Tile_Pixel_Size - i - 1] {
			return false
		}
	}

	return true
}

match_border :: proc(src: Border, dst: Border) -> (matched: bool) {
	return match_border_forwards(src, dst) || match_border_reverse(src, dst)
}

tile_flip_horizontal :: proc(tile: ^Tile) {
	temp := tile.pixels

	for y in 0..<Tile_Pixel_Size {
		for x in 0..<Tile_Pixel_Size {
			src_index := (Tile_Pixel_Size - x - 1) + y * Tile_Pixel_Size
			dst_index := x + y * Tile_Pixel_Size
			tile.pixels[dst_index] = temp[src_index]
		}
	}

	border_temp := tile.borders
	create_borders(tile)
	tile.borders[0].matched_tile_id = border_temp[0].matched_tile_id
	tile.borders[1].matched_tile_id = border_temp[3].matched_tile_id
	tile.borders[2].matched_tile_id = border_temp[2].matched_tile_id
	tile.borders[3].matched_tile_id = border_temp[1].matched_tile_id
}

tile_flip_vertical :: proc(tile: ^Tile) {
	temp := tile.pixels

	for y in 0..<Tile_Pixel_Size {
		for x in 0..<Tile_Pixel_Size {
			src_index := x + (Tile_Pixel_Size - y - 1) * Tile_Pixel_Size
			dst_index := x + y * Tile_Pixel_Size
			tile.pixels[dst_index] = temp[src_index]
		}
	}

	border_temp := tile.borders
	create_borders(tile)
	tile.borders[0].matched_tile_id = border_temp[2].matched_tile_id
	tile.borders[1].matched_tile_id = border_temp[1].matched_tile_id
	tile.borders[2].matched_tile_id = border_temp[0].matched_tile_id
	tile.borders[3].matched_tile_id = border_temp[3].matched_tile_id
}

tile_rotate :: proc(tile: ^Tile, times: int) {
	rotate_times := times % 4

	if rotate_times < 0 {
		rotate_times = rotate_times + 4
	}

	fmt.println("Rotate", times, "times =", rotate_times)

	for i in 0..<rotate_times {
		temp := tile.pixels

		for y in 0..<Tile_Pixel_Size {
			for x in 0..<Tile_Pixel_Size {
				dst_index := x + y * Tile_Pixel_Size
				src_index := y + (Tile_Pixel_Size - x - 1) * Tile_Pixel_Size

				tile.pixels[dst_index] = temp[src_index]
			}
		}

		border_temp := tile.borders
		create_borders(tile)
		tile.borders[0].matched_tile_id = border_temp[3].matched_tile_id
		tile.borders[1].matched_tile_id = border_temp[0].matched_tile_id
		tile.borders[2].matched_tile_id = border_temp[1].matched_tile_id
		tile.borders[3].matched_tile_id = border_temp[2].matched_tile_id
	}
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

get_tile_from_id :: proc(tiles: ^[dynamic]Tile, id: int) -> (^Tile) {
	assert(id != 0)

	for tile in tiles {
		if tile.id == id {
			return &tile
		}
	}

	return nil
}

draw_tile :: proc(tile: Tile) {
	for y in 0..<Tile_Pixel_Size {
		for x in 0..<Tile_Pixel_Size {
			index := x + y * Tile_Pixel_Size

			fmt.printf("%c", tile.pixels[index])
		}

		fmt.printf("\n")
	}
	fmt.printf("\n")
}

draw_image :: proc(image: []int, width: int, height: int) {
	for y in 0..<height {
		for x in 0..<width {
			index := x + y * width

			fmt.printf("%c", image[index])
		}

		fmt.printf("\n")
	}
	fmt.printf("\n")
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

	// fmt.println(tiles)

	for tile in &tiles {
		create_borders(&tile)
	}

	// fmt.println(tiles[0])

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

	corner_tile: ^Tile = nil

	// Find a corner to start with
	for tile, tile_index in &tiles {
		fmt.println("Tile", tile.id)

		missing_matches := 0

		for border, border_index in tile.borders {
			if border.matched_tile_id == 0 {
				missing_matches += 1
			}
			fmt.println("  Border", border_index, border.matched_tile_id)
		}

		if missing_matches == 2 {
			corner_tile = &tile
			break
		}
	}

	// fmt.println("Start corner", corner_tile.id)
	// fmt.println(corner_tile.borders)
	// draw_tile(corner_tile^)

	// rotate so that the 2 unused borders are top and left
	if corner_tile.borders[0].matched_tile_id != 0 {
		tile_flip_vertical(corner_tile)
	}

	if corner_tile.borders[3].matched_tile_id != 0 {
		tile_flip_horizontal(corner_tile)
	}

	fmt.println("Start corner", corner_tile.id)
	draw_tile(corner_tile^)
	// fmt.println(corner_tile.borders)

	// Match row

	src_tile := corner_tile

	grid_width := 0
	grid: [dynamic]^Tile

	tile_x := 1
	tile_y := 0

	append(&grid, src_tile)
	
	for {
		if src_tile.borders[1].matched_tile_id == 0 {
			// Done matching row
			if (grid_width == 0) {
				grid_width = tile_x
				fmt.println("Set width to", grid_width)
			} else {
				fmt.println("Assert width", tile_x)
				assert(grid_width == tile_x)
			}

			src_tile = grid[tile_y * grid_width]
			if src_tile.borders[2].matched_tile_id == 0 {
				// Done matching entire grid
				fmt.println("Done matching grid")
				break
			}

			fmt.println("Getting next row first tile")
			
			next_tile := get_tile_from_id(&tiles, src_tile.borders[2].matched_tile_id)

			// Find the matched edge
			matched_border := -1
			for border, border_index in next_tile.borders {
				if border.matched_tile_id == src_tile.id {
					matched_border = border_index
				}
			}
			assert(matched_border != -1)
			fmt.println("2 ->", matched_border)

			// Rotate to get border 3 to left
			if matched_border != 0 {
				fmt.println("Need to rotate")
				tile_rotate(next_tile, 0 - matched_border)
			}

			if !match_border_forwards(src_tile.borders[2], next_tile.borders[0]) {
				tile_flip_horizontal(next_tile)
			}

			src_tile = next_tile
			tile_x = 1
			tile_y += 1
			append(&grid, src_tile)

			draw_tile(next_tile^)
		}

		// fmt.println(src_tile.id, src_tile.borders)
		next_tile := get_tile_from_id(&tiles, src_tile.borders[1].matched_tile_id)

		// Find the matched edge
		matched_border := -1
		for border, border_index in next_tile.borders {
			if border.matched_tile_id == src_tile.id {
				matched_border = border_index
			}
		}
		assert(matched_border != -1)
		fmt.println("1 ->", matched_border)
		
		// Rotate to get border 3 to left
		if matched_border != 3 {
			fmt.println("Need to rotate")
			tile_rotate(next_tile, 3 - matched_border)
		}

		if !match_border_forwards(src_tile.borders[1], next_tile.borders[3]) {
			tile_flip_vertical(next_tile)
		}

		fmt.println(next_tile.id)
		draw_tile(next_tile^)

		src_tile = next_tile

		append(&grid, next_tile)

		tile_x += 1
	}

	grid_height := tile_y + 1
	fmt.println("Grid - Width:", grid_width, "Len:", len(grid), "Rows:", grid_height)

	for tile in grid {
		fmt.println(tile.id)
	}

	// Copy tiles into final array.
	full_image_width := (Tile_Pixel_Size - 2) * grid_width
	full_image_height := (Tile_Pixel_Size - 2) * grid_height
	full_image := make([]int, full_image_width * full_image_height)
	defer delete(full_image)

	for tile_y in 0..<grid_width {
		for tile_x in 0..<grid_width {

			for cell_y in 1..<Tile_Pixel_Size - 1 {
				for cell_x in 1..<Tile_Pixel_Size - 1 {
					tile_root_index := tile_x * (Tile_Pixel_Size - 2) + (tile_y * (Tile_Pixel_Size - 2)) * full_image_width
					dst_index := tile_root_index + (cell_x - 1) + (cell_y - 1) * full_image_width

					// fmt.println(tile_x, tile_y, "::", cell_x, cell_y, "::", dst_index)

					full_image[dst_index] = grid[tile_x + tile_y * grid_width].pixels[cell_x + cell_y * Tile_Pixel_Size]
				}
			}
		}
	}

	for r in 0..<3 {
		if cancel_sea_monster(&full_image, full_image_width, full_image_height) {
			break
		}

		flip_horizontal(&full_image, full_image_width)
		if cancel_sea_monster(&full_image, full_image_width, full_image_height) {
			break
		}
		flip_horizontal(&full_image, full_image_width)

		flip_vertical(&full_image, full_image_width)
		if cancel_sea_monster(&full_image, full_image_width, full_image_height) {
			break
		}
		flip_vertical(&full_image, full_image_width)

		rotate(&full_image, full_image_width)
	}
	
	draw_image(full_image, full_image_width, full_image_height)

	// Final count
	final_count := 0
	for char in full_image {
		if char == '#' {
			final_count += 1
		}
	}

	fmt.println("Final count:", final_count)
}

cancel_sea_monster :: proc(image: ^[]int, image_width: int, image_height: int) -> (bool) {
	sea_monster_str := "                  # #    ##    ##    ### #  #  #  #  #  #   "
	sea_monster_width := 20
	sea_monster_height := 3

	result := false

	for start_y in 0..<image_height - sea_monster_height {
		for start_x in 0..<image_width - sea_monster_width {

			found_monster := true

			monster_loop: for y in 0..<sea_monster_height {
				for x in 0..<sea_monster_width {
					monster_index := x + y * sea_monster_width
					src_index := (start_x + x) + (start_y + y) * image_width

					if sea_monster_str[monster_index] == '#' {
						if image[src_index] != '#' {
							found_monster = false
							break monster_loop
						}
					}
				}
			}

			if found_monster {
				fmt.println("Found monster!")
				result = true

				for y in 0..<sea_monster_height {
					for x in 0..<sea_monster_width {
						monster_index := x + y * sea_monster_width
						src_index := (start_x + x) + (start_y + y) * image_width

						if sea_monster_str[monster_index] == '#' {
							image[src_index] = 'O'
						}
					}
				}
			}
		}
	}

	return result
}

flip_horizontal :: proc(image: ^[]int, image_size: int) {
	temp := make([]int, len(image))
	defer delete(temp)
	copy(temp, image^)

	for y in 0..<image_size {
		for x in 0..<image_size {
			src_index := (image_size - x - 1) + y * image_size
			dst_index := x + y * image_size
			image[dst_index] = temp[src_index]
		}
	}
}

flip_vertical :: proc(image: ^[]int, image_size: int) {
	temp := make([]int, len(image))
	defer delete(temp)
	copy(temp, image^)

	for y in 0..<image_size {
		for x in 0..<image_size {
			src_index := x + (image_size - y - 1) * image_size
			dst_index := x + y * image_size
			image[dst_index] = temp[src_index]
		}
	}
}

rotate :: proc(image: ^[]int, image_size: int) {
	temp := make([]int, len(image))
	defer delete(temp)
	copy(temp, image^)

	for y in 0..<image_size {
		for x in 0..<image_size {
			dst_index := x + y * image_size
			src_index := y + (image_size - x - 1) * image_size

			image[dst_index] = temp[src_index]
		}
	}
}