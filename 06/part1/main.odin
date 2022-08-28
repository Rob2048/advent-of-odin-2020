package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)
	defer delete(file_bytes)

	answers := make(map[rune]int)
	defer delete(answers)

	total_unique_answers: int = 0

	group_iter := string(file_bytes)
	for group in strings.split_iterator(&group_iter, "\r\n\r\n") {
		line_iter := group
		for line in strings.split_lines_iterator(&line_iter) {
			fmt.println(line)
			
			for char in line {
				if !(char in answers) {
					answers[char] = 0
				}

				answers[char] = answers[char] + 1
			}
		}

		total_unique_answers += len(answers)

		fmt.println(answers)
		delete(answers)
		answers = make(map[rune]int)
		fmt.println("Group done")
	}

	fmt.println("Total answers", total_unique_answers)
}