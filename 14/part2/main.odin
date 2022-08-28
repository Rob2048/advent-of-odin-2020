package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

pow :: proc(base: int, exponent: int) -> (int) {
	result := base

	for _ in 0..<exponent - 1 {
		result *= base
	}

	return result
}

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example2.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)

	mask_check: [36]int
	mask_check_size := 0
	mask_or: u64 = 0
	mask_and: u64 = 0
	memory := make(map[int]u64)
	defer delete(memory)

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		fmt.println(line)

		if strings.has_prefix(line, "mask") {
			param_iter := line
			strings.split_iterator(&param_iter, "= ")
			mask_or = 0
			mask_and = ~u64(0)
			mask_check_size = 0

			for mask_char, index in param_iter {
				if mask_char == '1' {
					mask_or |= (1 << u32(35 - index))
				} else if mask_char == 'X' {
					mask_check[mask_check_size] = 35 - index
					mask_check_size += 1
					mask_and ~= (1 << u32(35 - index))
				}
			}

			// fmt.printf("Mask %s %b %b %d\n", param_iter, mask_and, mask_or, mask_check[:mask_check_size])
		} else if strings.has_prefix(line, "mem") {
			location := u64(strconv.atoi(line[4:]))
			param_iter := line
			strings.split_iterator(&param_iter, "= ")
			value := u64(strconv.atoi(param_iter))

			// fmt.println("Mem", location, value)

			starting_mem := (location | mask_or) & mask_and
			total_count := pow(2, mask_check_size)

			// fmt.printf("Starting: %b %b %d\n", location, starting_mem, total_count)

			for i in 0..<total_count {
				offset: u64 = 0
				for bit in 0..<mask_check_size {
					offset |= ((u64(i) >> u32(bit)) & 0x1) << u32(mask_check[mask_check_size - bit - 1])
				}

				offset_mem := starting_mem | offset
				memory[int(offset_mem)] = value
			}
		}
	}

	final_result: u64 = 0
	for mem_key, mem_value in memory {
		final_result += mem_value
	}
	fmt.println(final_result)
}