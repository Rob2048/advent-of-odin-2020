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

	for i := 0; i < len(values) - 1; i += 1 {
		diff := values[i + 1] - values[i]

		if diff == 1 {
			one_jolt += 1
		} else if diff == 3 {
			three_jolt += 1
		} else {
			assert(false)
		}

		// fmt.println(values[i], values[i + 1], diff)
	}

	final := one_jolt * three_jolt
	fmt.println(one_jolt, three_jolt, final)
}