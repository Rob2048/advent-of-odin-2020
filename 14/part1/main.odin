package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)


	mask_and: u64 = 0
	mask_or: u64 = 0
	memory := make(map[int]u64)
	defer delete(memory)

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		fmt.println(line)

		if strings.has_prefix(line, "mask") {
			param_iter := line
			strings.split_iterator(&param_iter, "= ")
			mask_and = ~u64(0)
			mask_or = 0

			for mask_char, index in param_iter {
				if mask_char == '1' {
					mask_or |= (1 << u32(35 - index))
				} else if mask_char == '0' {
					mask_and ~= (1 << u32(35 - index))
				}
			}

			fmt.printf("Mask %s %b %b\n", param_iter, mask_and, mask_or)
			// fmt.println("Mask", param_iter, mask_and, mask_or)
		} else if strings.has_prefix(line, "mem") {
			location := strconv.atoi(line[4:])
			param_iter := line
			strings.split_iterator(&param_iter, "= ")
			value := u64(strconv.atoi(param_iter))

			fmt.println("Mem", location, value)

			// fmt.printf("%b %b\n", value, mask_and)
			memory[location] = (value & mask_and) | mask_or
		}
	}

	final_result: u64 = 0
	for mem_key, mem_value in memory {
		final_result += mem_value
	}
	fmt.println(final_result)
}