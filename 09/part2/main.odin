package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math/bits"

find_sum :: proc(target: int, list: []int) -> bool {
	for outer_index := 0; outer_index < len(list); outer_index += 1 {
		for inner_index := outer_index + 1; inner_index < len(list); inner_index += 1 {
			if list[outer_index] == list[inner_index] {
				continue
			}

			if list[outer_index] + list[inner_index] == target {
				return true
			}
		}
	}

	return false
}

main :: proc() {
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	if !file_success {
		fmt.println("File open failed")
		return
	}

	values: [dynamic]int
	defer delete(values)

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		value := strconv.atoi(line)
		append(&values, value)
	}

	assert(len(values) > 25)

	invalid_number := 0

	for value, index in values[25:] {
		if !find_sum(value, values[index:index + 25]) {
			invalid_number = value
			break
		}
	}

	fmt.println("Invalid:", invalid_number)

	outer: for start_value, start_index in values {
		sum := 0
		min_v := bits.I64_MAX
		max_v := bits.I64_MIN

		for current_value, current_index in values[start_index:] {
			sum += current_value

			min_v = min(min_v, current_value)
			max_v = max(max_v, current_value)

			if sum == invalid_number {
				fmt.println("Found sum", start_index, current_index + start_index)
				fmt.println(min_v, max_v, min_v + max_v)
				break outer
			}
		}
	}
}