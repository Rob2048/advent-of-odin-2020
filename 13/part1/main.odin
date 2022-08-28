package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math/bits"

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)

	line_iter := string(file_bytes)
	start_str, _ := strings.split_lines_iterator(&line_iter)
	schedule_str, _ := strings.split_lines_iterator(&line_iter)

	start_time := strconv.atoi(start_str)
	fmt.println("Start time:", start_time)

	shortest_time := bits.I64_MAX
	shortest_bus := 0

	for bus in strings.split_iterator(&schedule_str, ",") {
		if strings.equal_fold(bus, "x") {
			continue
		}

		bus_time := strconv.atoi(bus)
		fmt.println("Bus time:", bus, bus_time)

		wait_time := bus_time - (start_time % bus_time)
		fmt.println("Wait:", wait_time)

		if wait_time < shortest_time {
			shortest_time = wait_time
			shortest_bus = bus_time
		}
	}

	fmt.println(shortest_time, shortest_bus, shortest_bus * shortest_time)
}