package main

import "core:fmt"
import "core:os"
import "core:bytes"
import "core:strconv"

main :: proc() {
	// file_bytes, file_read_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_read_success := os.read_entire_file_from_filename("../puzzle.txt")
	if (file_read_success == false) {
		fmt.println("File open failed")
		return
	}

	fmt.println(file_bytes)
	
	nums : [dynamic]i64

	
	line_iter := file_bytes[:]
	for {
		line, res := bytes.split_iterator(&line_iter, []u8{'\r', '\n'})
		if (!res) {
			break
		}

		fmt.printf("%s\n", line)

		str_value := i64(strconv.atoi(string(line)))
		fmt.println(str_value)
		append(&nums, str_value)
	}

	fmt.println(nums)

	outer: for i := 0; i < len(nums); i += 1 {
		for j := i + 1; j < len(nums); j += 1 {
			if (nums[i] + nums[j] == 2020) {
				fmt.println(nums[i], " ", nums[j], " ", nums[i] * nums[j])
				break outer
			}
		}
	}
}