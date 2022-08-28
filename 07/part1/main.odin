package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)
	defer delete(file_bytes)

	contains := make(map[string]map[string]int)
	// defer delete(contains)

	held_by := make(map[string]map[string]int)

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		fmt.println(line)

		container_iter := line
		container_str, _ := strings.split_iterator(&container_iter, " bags contain ")
		fmt.println("[", container_str, "]")

		contains[container_str] = nil
		list := &contains[container_str]

		for bag_str in strings.split_iterator(&container_iter, ", ") {
			fmt.println("[", bag_str, "]")

			if strings.contains(bag_str, "no other bags") {
				break
			}	

			trimmed_bag_str := bag_str[0:strings.index(bag_str, " bag")]
			fmt.println("[", trimmed_bag_str, "]")

			count_str, _ := strings.split_iterator(&trimmed_bag_str, " ")
			count := strconv.atoi(count_str)
			fmt.println("[", count_str, "]", count)
			fmt.println("[", trimmed_bag_str, "]")
			list[trimmed_bag_str] = count

			if !(trimmed_bag_str in held_by) {
				held_by[trimmed_bag_str] = nil
			}

			(&held_by[trimmed_bag_str])[container_str] += 1
		}
	}

	fmt.println(contains)
	fmt.println(held_by)

	// Trace shiny gold
	valid_bags := make(map[string]int)

	bag_stack: [dynamic]string
	bag_stack_pos := 0

	append(&bag_stack, "shiny gold")

	for bag_stack_pos < len(bag_stack) {
		current_bag := held_by[bag_stack[bag_stack_pos]]
		bag_stack_pos += 1

		for bag in current_bag {
			if bag in valid_bags {
				continue
			}

			valid_bags[bag] = 1
			append(&bag_stack, bag)
		}
	}

	fmt.println(valid_bags)
	fmt.println("Valid bag count:", len(valid_bags))
}

