package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Rule_A :: 256
Rule_B :: 257

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)

	rules: [256][dynamic][dynamic]int
	defer {
		// ...
	}

	section_iter := string(file_bytes)
	rules_section, _ := strings.split_iterator(&section_iter, "\r\n\r\n")

	for rule_str in strings.split_lines_iterator(&rules_section) {
		fmt.println("Rule:", rule_str)
		fields_iter := rule_str

		index, _ := strings.split_iterator(&fields_iter, ": ")
		rule := &rules[strconv.atoi(index)]
		append(rule, [dynamic]int{})
		current_options := &rule[0]

		for field in strings.fields_iterator(&fields_iter) {
			fmt.println("Field[", field, "]")

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

	fmt.println(rules)

	match_count := 0

	for message in strings.split_lines_iterator(&section_iter) {
		fmt.println("Message:", message)

		result, pos := recursive_match(message, &rules, 0, 0)
		// fmt.println("Matched", result, pos)

		if !result {
			fmt.println("  Failed to match")
		} else {
			if pos == len(message) {
				fmt.println("  Full match")
				match_count += 1
			} else {
				fmt.println("  Only matched to char", pos)
			}
		}
	}

	fmt.println("Total matches:", match_count)
}

print_depth :: proc(depth: int) {
	for _ in 0..<depth {
		fmt.printf("  ")
	}
}

recursive_match :: proc(input: string, rules: ^[256][dynamic][dynamic]int, rule_index: int, depth: int) -> (bool, int) {
	//print_depth(depth)
	//fmt.println("Match", input, "Rule:", rule_index)

	rule := rules[rule_index]
	
	// Match each option
	for option, option_index in rule {
		//print_depth(depth)
		//fmt.println("  Option", option_index)
		str_pos := 0

		seq_match := true
		// Match each sequence
		for seq, seq_index in option {
			//print_depth(depth)
			//fmt.println("    Seq", seq_index)

			if seq >= Rule_A {
				// Direct match
				if seq == Rule_A && input[str_pos] == 'a' {
					//print_depth(depth)
					//fmt.println("      Matched 'a' at", str_pos)
					str_pos += 1
				} else if seq == Rule_B && input[str_pos] == 'b' {
					//print_depth(depth)
					//fmt.println("      Matched 'b' at", str_pos)
					str_pos += 1
				} else {
					//print_depth(depth)
					//fmt.println("      Failed match at", str_pos)
					seq_match = false
					break
				}
			} else {
				match, consumed_count := recursive_match(input[str_pos:], rules, seq, depth + 6)
				seq_match = match
				str_pos += consumed_count
				if !seq_match {
					break
				}
			}
		}

		if (seq_match) {
			return true, str_pos
		}
	}

	return false, 0
}