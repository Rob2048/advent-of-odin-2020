package main

import "core:fmt"
import "core:os"
import "core:bytes"
import "core:strconv"
import "core:strings"

main :: proc() {
	// file_bytes, file_read_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_read_success := os.read_entire_file_from_filename("../puzzle.txt")
	if (file_read_success == false) {
		fmt.println("File open failed")
		return
	}

	file_str := string(file_bytes)

	valid_passwords : int = 0

	field_iter := file_str
	for  {
		min_str, _ := strings.split_iterator(&field_iter, "-");
		max_str, _ := strings.fields_iterator(&field_iter);
		char_str, _ := strings.fields_iterator(&field_iter);
		password_str, _ := strings.fields_iterator(&field_iter);
		
		_, err := strings.split_lines_iterator(&field_iter);

		num_min := strconv.atoi(min_str) - 1
		num_max := strconv.atoi(max_str) - 1
		char := char_str[0]

		if (password_str[num_min] == char || password_str[num_max] == char) {
			if (password_str[num_min] != char || password_str[num_max] != char) {
				valid_passwords += 1;
			}
		}

		// fmt.println(num_min, num_max, char_str[0:1], password_str)

		if (!err) {
			break;
		}
	}

	fmt.println("Valid:", valid_passwords)
}