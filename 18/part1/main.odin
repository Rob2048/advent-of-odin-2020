package main
 
import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
	// example_str := "2 * 3 + (4 * 5)"
	// example_str := "5 + (8 * 3 + 9 + 3 * 4 * 3)"
	// example_str := "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"
	// example_str := "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"

	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)

	total_sum := 0

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		eval_str := line
		total_sum += evaluate(&eval_str)
	}

	fmt.println("Result", total_sum)
}

evaluate :: proc(input: ^string) -> (int) {
	// fmt.println("Eval:[", input^, "]")
	current_value := 0
	operator := 0

	for {
		// Find operand
		operand := 0

		char_index := 0
		for {
			if char_index == len(input) {
				fmt.println("Expected operand, found end of string")
				return current_value
			}
			char := input[char_index]
			// fmt.println("  Operand: ", char)
			char_index += 1

			if char == ' ' {
				continue
			} else if char == '(' {
				input^ = input[char_index:]
				operand = evaluate(input)
				break
			} else if char >= '0' && char <= '9' {
				input^ = input[char_index:]
				operand = int(char - '0');
				break
			}
		}

		// fmt.println("  Operand:", operand, "Operator:", operator)
		// fmt.println(current_value, "(", operator, ")", operand)

		if operator == 0 {
			current_value = operand
		} else if operator == 1 {
			current_value += operand
		} else if operator == 2 {
			current_value *= operand
		}

		operator = 0

		// Find operator
		char_index = 0
		for {
			if char_index == len(input) {
				return current_value
			}
			char := input[char_index]
			// fmt.println("  Operator", char)
			char_index += 1

			if char == ' ' {
				continue
			} else if char == ')' {
				input^ = input[char_index:]
				return current_value
			} else if char == '+' {
				input^ = input[char_index:]
				operator = 1
				break
			} else if char == '*' {
				input^ = input[char_index:]
				operator = 2
				break
			}
		}
	}

	return 0
}