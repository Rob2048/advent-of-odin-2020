package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Range :: struct {
	min: int,
	max: int,
}

Rule :: struct {
	name: string,
	ranges: [2]Range,
	fields: [dynamic]int,
	final_field: int
}

Ticket :: struct {
	fields: [dynamic]int,
}

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example2.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)

	rules: [dynamic]Rule
	your_ticket: Ticket
	nearby_tickets: [dynamic]Ticket
	defer {
		for rule in rules {
			delete(rule.fields)
		}
		delete(rules)
		delete(your_ticket.fields)
		for ticket in nearby_tickets {
			delete(ticket.fields)
		}
		delete(nearby_tickets)
	}

	parse_type := 0
	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		if (len(line) == 0) {
			continue
		}

		// fmt.println(line)

		if strings.equal_fold(line, "your ticket:") {
			// fmt.println("Parsing your ticket")
			parse_type = 1
			continue
		} else if strings.equal_fold(line, "nearby tickets:") {
			// fmt.println("Parsing nearby tickets")
			parse_type = 2
			continue
		}

		if parse_type == 0 {
			field_iter := line
			name, _ := strings.split_iterator(&field_iter, ": ")
			range0_min, _ := strings.split_iterator(&field_iter, "-")
			range0_max, _ := strings.split_iterator(&field_iter, " or ")
			range1_min, _ := strings.split_iterator(&field_iter, "-")
			range1_max := field_iter

			new_rule := Rule {
				name, {
					Range{ strconv.atoi(range0_min), strconv.atoi(range0_max) },
					Range{ strconv.atoi(range1_min), strconv.atoi(range1_max) },
				},
				{},
				-1
			}

			append(&rules, new_rule)

			// fmt.println("Rule", new_rule)
		} else if parse_type == 1 || parse_type == 2 {
			new_ticket := Ticket{}

			field_iter := line
			for field in strings.split_iterator(&field_iter, ",") {
				append(&new_ticket.fields, strconv.atoi(field))
			}

			// fmt.println("Ticket", new_ticket)

			assert(len(new_ticket.fields) == len(rules))

			if parse_type == 1 {
				delete(your_ticket.fields)
				your_ticket = new_ticket
			} else {
				append(&nearby_tickets, new_ticket)
			}
		}
	}

	// fmt.println("Rules", rules)
	// fmt.println("Your ticket", your_ticket)
	// fmt.println("Nearby tickets", nearby_tickets)

	scanning_error_rate := 0

	valid_tickets: [dynamic]Ticket
	defer delete(valid_tickets)

	// Find invalid nearby tickets
	for ticket in nearby_tickets {
		invalid_count := 0

		for field in ticket.fields {
			rule_loop: {
				for rule in rules {
					if field >= rule.ranges[0].min && field <= rule.ranges[0].max || field >= rule.ranges[1].min && field <= rule.ranges[1].max {
						break rule_loop
					}
				}

				invalid_count += field
			}
		}

		if invalid_count == 0 {
			append(&valid_tickets, ticket)
		}

		scanning_error_rate += invalid_count
		// fmt.println(invalid_count)
	}

	fmt.println("Scanning error rate:", scanning_error_rate)
	append(&valid_tickets, your_ticket)
	// fmt.println(valid_tickets)

	total_field_count := len(rules)

	// Find field order
	for rule, rule_index in rules {
		// fmt.println("Check rule", rule_index)

		for field_iter in 0..<total_field_count {
			// fmt.println("  Check field", field_iter)

			ticket_loop: {
				for ticket in valid_tickets {
					field_value := ticket.fields[field_iter]
					
					if !(field_value >= rule.ranges[0].min && field_value <= rule.ranges[0].max || field_value >= rule.ranges[1].min && field_value <= rule.ranges[1].max) {
						// fmt.println("    Invalid")
						break ticket_loop;
						// Invalid, so this field is wrong
					}
				}
				append(&rules[rule_index].fields, field_iter)
				// fmt.println("    Valid")
			}
		}
	}

	fmt.println(rules)

	all_placed := false
	for all_placed == false {
		all_placed = true
		// fmt.println("Start prune step")

		for rule, rule_index in rules {
			// fmt.println("  Rule", rule_index)

			if len(rule.fields) > 1 {
				all_placed = false

				for field := 0; field < len(rules[rule_index].fields); field += 1 {
					// fmt.println("    Check field", field, rule.fields[field])
					// Check if field taken

					for check_rule, check_rule_index in rules {
						if check_rule_index == rule_index {
							continue
						}

						// fmt.println("      Check against rule", check_rule_index, rule.fields[field], "?=", check_rule.final_field)

						if check_rule.final_field == rule.fields[field] {
							unordered_remove(&rules[rule_index].fields, field)
							field -= 1
							break
						}
					}
				}
			} else {
				rules[rule_index].final_field = rule.fields[0]
				// fmt.println("    Done")
			}
		}
	}

	final_value := 0

	for rule, rule_index in rules {
		if strings.has_prefix(rule.name, "departure") {
			fmt.println("Rule", rule_index, rule.final_field)
			
			value := your_ticket.fields[rule.final_field]

			if final_value == 0 {
				final_value = value
			} else {
				final_value *= value
			}
		}
	}

	fmt.println(final_value)
}