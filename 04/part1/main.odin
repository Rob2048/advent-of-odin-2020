package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	if !file_success {
		fmt.println("File load failed.")
		return;
	}

	field_count: int = 0
	valid_passports : int = 0

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		// fmt.println("Line:", line)

		if len(line) == 0 {
			if field_count == 7 {
				valid_passports += 1
			}

			fmt.println("New passport")
			field_count = 0
		}
		
		field_iter := line
		for field in strings.fields_iterator(&field_iter) {
			fmt.println(field)

			if !strings.has_prefix(field, "cid") {
				field_count += 1
			}
		}
	}

	// Account for final passport
	if field_count == 7 {
		valid_passports += 1
	}

	fmt.println("Valid:", valid_passports)
}