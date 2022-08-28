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

reset_program :: proc(program: [dynamic]Instruction) {
	for _, i in program {
		program[i].count = 0
	}
}

execute_program :: proc(program: [dynamic]Instruction) -> (accumulator: int, success: bool) {
	reset_program(program)
	program_counter := 0
	accumulator = 0

	for {
		if program_counter == len(program) {
			fmt.println("Perfect")
			return accumulator, true
		}

		if program_counter > len(program) {
			fmt.println("Too much")
			return accumulator, false
		}

		inst := &program[program_counter]
		inst.count += 1

		if inst.count > 1 {
			fmt.println("Dupe")
			return accumulator, false
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

	for _, i in instructions {
		inst := &instructions[i]

		if strings.equal_fold(inst.opcode, "nop") {
			inst.opcode = "jmp"
			accum, success := execute_program(instructions)
			fmt.println(accum, success)
			inst.opcode = "nop"

			if success {
				break
			}
		} else if strings.equal_fold(inst.opcode, "jmp") {
			inst.opcode = "nop"
			accum, success := execute_program(instructions)
			fmt.println(accum, success)
			inst.opcode = "jmp"

			if success {
				break
			}
		}
	}
}
