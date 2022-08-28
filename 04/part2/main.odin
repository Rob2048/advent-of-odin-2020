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
			name := field[0:3]
			param := field[4:]

			fmt.println(name, param)

			if strings.has_prefix(name, "byr") {
				if year := strconv.atoi(param); year >= 1920 && year <= 2002 {
					fmt.println("Valid")
					field_count += 1
				}
			} else if strings.has_prefix(name, "iyr") {
				if year := strconv.atoi(param); year >= 2010 && year <= 2020 {
					fmt.println("Valid")
					field_count += 1
				}
			} else if strings.has_prefix(name, "eyr") {
				if year := strconv.atoi(param); year >= 2020 && year <= 2030 {
					fmt.println("Valid")
					field_count += 1
				}
			} else if strings.has_prefix(name, "hgt") {
				min: int = 0
				max: int = 0

				if strings.contains(param, "in") {
					min = 59
					max = 76
				} else if strings.contains(param, "cm") {
					min = 150
					max = 193
				} else {
					continue
				}

				if height := strconv.atoi(param); height >= min && height <= max {
					fmt.println("Valid")
					field_count += 1
				}
			} else if strings.has_prefix(name, "hcl") {
				if len(param) != 7 {
					continue
				}

				valid := true
				for char in param[1:] {
					if !((char >= '0' && char <= '9') || (char >= 'a' && char <= 'f')) {
						valid = false
						break 
					}
				}

				if valid {
					fmt.println("Valid")
					field_count += 1
				}
			} else if strings.has_prefix(name, "ecl") {
				// amb blu brn gry grn hzl oth
				if strings.equal_fold(param, "amb") || 
					strings.equal_fold(param, "blu") ||
					strings.equal_fold(param, "brn") ||
					strings.equal_fold(param, "gry") ||
					strings.equal_fold(param, "grn") ||
					strings.equal_fold(param, "hzl") ||
					strings.equal_fold(param, "oth") {
						fmt.println("Valid")
						field_count += 1
				}
			} else if strings.has_prefix(name, "pid") {
				if len(param) != 9 {
					continue
				}

				valid := true
				for char in param {
					if !(char >= '0' && char <= '9') {
						valid = false
						break 
					}
				}

				if valid {
					fmt.println("Valid")
					field_count += 1
				}
			}
		}
	}

	// Account for final passport
	if field_count == 7 {
		valid_passports += 1
	}

	fmt.println("Valid:", valid_passports)
}