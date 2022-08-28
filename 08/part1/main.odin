package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Instruction :: struct {
	opcode: string,
	value: int,
	count: int,
}

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	if !file_success {
		fmt.println("File failed to open")
		return
	}
	defer delete(file_bytes)

	instructions : [dynamic]Instruction

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		fmt.println(line)

		fields_iter := line
		opcode_str, _ := strings.fields_iterator(&fields_iter)
		value := strconv.atoi(fields_iter[1:])

		fmt.println(opcode_str, value)

		append(&instructions, Instruction{opcode = opcode_str, value = value, count = 0})
	}

	fmt.println(instructions)

	// Execute
	program_counter := 0
	accumulator := 0

	for {
		inst := &instructions[program_counter]
		inst.count += 1

		if inst.count > 1 {
			fmt.println("Repeated instruction", program_counter, accumulator)
			break
		}

		if strings.equal_fold(inst.opcode, "nop") {
			program_counter += 1
		} else if strings.equal_fold(inst.opcode, "acc") {
			accumulator += inst.value
			program_counter += 1
		} else if strings.equal_fold(inst.opcode, "jmp") {
			program_counter += inst.value
		}
	}
}
