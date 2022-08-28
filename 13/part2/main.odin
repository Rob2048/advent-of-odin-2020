package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math/bits"

Bus :: struct {
	id: int,
	offset: int
}

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)

	line_iter := string(file_bytes)
	start_str, _ := strings.split_lines_iterator(&line_iter)
	schedule_str, _ := strings.split_lines_iterator(&line_iter)

	start_time := strconv.atoi(start_str)
	fmt.println("Start time:", start_time)

	busses := make([dynamic]Bus)
	defer delete(busses)

	bus_iter := 0
	for bus_str in strings.split_iterator(&schedule_str, ",") {
		defer bus_iter += 1

		if strings.equal_fold(bus_str, "x") {
			continue
		}

		bus_time := strconv.atoi(bus_str)
		fmt.println("Bus time:", bus_str, bus_time)
		fmt.println("Wait:", bus_iter)

		append(&busses, Bus{bus_time, bus_iter})
	}

	fmt.println(busses)

	start := busses[0].offset
	increment := busses[0].id
	total_iters := 0

	for bus in busses[1:] {
		check_value := bus.id
		offset := bus.offset

		n := start
		
		// Find initial match (start).
		for {
			total_iters += 1

			if (n + offset) % check_value == 0 {
				break;
			}

			n += increment
		}

		start = n
		n += increment

		// Find next match (increment).
		for {
			total_iters += 1

			if (n + offset) % check_value == 0 {
				break;
			}

			n += increment
		}

		increment = n - start
		fmt.println(start, increment)
	}

	fmt.println("Start time:", start, total_iters)
}