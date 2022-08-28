package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Rule_A :: 256
Rule_B :: 257

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example2.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle2.txt")
	assert(file_success)

	rules: [256][dynamic][dynamic]int
	defer {
		for rule in &rules {
			for seq in &rule {
				delete(seq)
			}
			delete(rule)
		}
	}

	section_iter := string(file_bytes)
	rules_section, _ := strings.split_iterator(&section_iter, "\r\n\r\n")

	for rule_str in strings.split_lines_iterator(&rules_section) {
		// fmt.println("Rule:", rule_str)
		fields_iter := rule_str

		index, _ := strings.split_iterator(&fields_iter, ": ")
		rule := &rules[strconv.atoi(index)]
		append(rule, [dynamic]int{})
		current_options := &rule[0]

		for field in strings.fields_iterator(&fields_iter) {
			// fmt.println("Field[", field, "]")

			if field[0] == '|' {
				append(rule, [dynamic]int{})
				current_options = &rule[len(rule) - 1]
			} else {
				if field[0] == '"' {
					if field[1] == 'a' {
						append(current_options, Rule_A)
					} else if field[1] == 'b' {
						append(current_options, Rule_B)
					} 
				} else {
					append(current_options, strconv.atoi(field))
				}
			}
		}
	}

	// fmt.println(rules)

	match_count := 0

	for message in strings.split_lines_iterator(&section_iter) {
		fmt.println("Message:", message)

		position_list := recursive_match(message, &rules, 0, 0, 0)
		fmt.println("Match result", position_list)

		for pos in position_list {
			if pos == len(message) {
				match_count += 1
				break
			}
		}

		delete(position_list)
	}

	fmt.println("Total matches:", match_count)
}

print_depth :: proc(depth: int) {
	for _ in 0..<depth {
		fmt.printf("  ")
	}
}

recursive_match :: proc(input: string, rules: ^[256][dynamic][dynamic]int, match_rule_index: int, input_pos: int, depth: int) -> (result: [dynamic]int) {
	match_rule := rules[match_rule_index]
	
	for seq in match_rule {
		position_list: [dynamic]int
		append(&position_list, input_pos)

		for rule in seq {
			new_positions: [dynamic]int

			for position in position_list {
				if rule >= Rule_A {
					if rule == Rule_A && input[position] == 'a' {
						append(&new_positions, position + 1)
					} else if rule == Rule_B && input[position] == 'b' {
						append(&new_positions, position + 1)
					}
				} else {
					if position < len(input) {
						match_result := recursive_match(input, rules, rule, position, depth + 6)
						append(&new_positions, ..match_result[:])
					}
				}
			}

			delete(position_list)
			position_list = new_positions
		}

		append(&result, ..position_list[:])
	}

	return
}