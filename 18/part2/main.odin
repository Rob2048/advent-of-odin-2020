package main
 
import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
	// example_str := "1 + (2 * 3)"
	// example_str := "2 * 3 + (4 * 5)"
	// example_str := "5 + (8 * 3 + 9 + 3 * 4 * 3)"
	// example_str := "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"
	// example_str := "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"
	// evaluate(example_str)

	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)

	total_sum := 0

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		total_sum += evaluate(line)
	}

	fmt.println("Result", total_sum)
}

evaluate_operator :: proc(operator: int, operand_stack: ^[dynamic]int) {
	if operator == '+' {
		operand0 := pop(operand_stack)
		operand1 := pop(operand_stack)
		append(operand_stack, operand0 + operand1)
	} else if operator == '*' {
		operand0 := pop(operand_stack)
		operand1 := pop(operand_stack)
		append(operand_stack, operand0 * operand1)
	}
}

evaluate :: proc(input: string) -> (int) {
	operator_stack: [dynamic]int
	defer delete(operator_stack)

	operand_stack: [dynamic]int
	defer delete(operand_stack)

	fmt.println("Evaluate:", input)

	for char, char_index in input {
		if char == ' ' {
			continue
		} else if char >= '0' && char <= '9' {
			append(&operand_stack, int(char - '0'))
		} else if char == '(' {
			append(&operator_stack, '(')
		} else if char == ')' {
			for operator_stack[len(operator_stack) - 1] != '(' {
				evaluate_operator(pop(&operator_stack), &operand_stack)
			}

			pop(&operator_stack)
		} else if char == '+' {
			append(&operator_stack, '+')
		} else if char == '*' {
			for len(operator_stack) > 0 && operator_stack[len(operator_stack) - 1] == '+' {
				evaluate_operator(pop(&operator_stack), &operand_stack)
			} 
		
			append(&operator_stack, '*')
		}

		// fmt.println(char)
		// fmt.println(operator_stack)
		// fmt.println(operand_stack)
	}

	// Evaluate remaining operators
	for len(operator_stack) != 0 {
		evaluate_operator(pop(&operator_stack), &operand_stack)
	}

	// fmt.println(operator_stack)
	// fmt.println(operand_stack)

	assert(len(operator_stack) == 0)
	assert(len(operand_stack) == 1)
	
	return operand_stack[0]
}