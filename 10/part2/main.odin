package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:sort"

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	if !file_success {
		fmt.println("File open failed")
		return
	}

	values: [dynamic]int
	defer delete(values)
	append(&values, 0)

	lines_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&lines_iter) {
		append(&values, strconv.atoi(line))
	}

	sorted := values[:]
	sort.bubble_sort(sorted)
	append(&values, values[len(values) - 1] + 3)
	fmt.println(values)

	one_jolt := 0
	three_jolt := 0

	refs:= make(map[int]int)
	defer delete(refs)

	for value, index in values {
		// Branch for each value behind?
		// fmt.println("Compare", index, value, "to:")
		multiplier: int = 0

		if (index == 0) {
			multiplier = 1
		}
		
		for target_index := index - 1; target_index >= 0; target_index -= 1 {
			target_value := values[target_index]

			if (target_value < value - 3) {
				continue
			}

			multiplier += refs[target_value]
			// fmt.println(target_index, target_value)
		}

		refs[value] = multiplier;

		if index == len(values) - 1 {
			fmt.println("Total combinations:", multiplier)
		}
	}
}