package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Entry :: struct {
	last_diff: int,
	last_turn: int,
	first: bool
}

main :: proc() {
	// turn_list := []int{0,3,6}
	turn_list := []int{14,8,16,0,1,17}
	nums := make(map[int]Entry)
	defer delete(nums)

	last_spoken := 0
	turn_num := 0
	// Prime starting numbers
	for num in turn_list {
		turn_num += 1
		nums[num] = Entry{-1, turn_num, true}
		last_spoken = num
	}

	fmt.println("Prime", nums, last_spoken)
	
	for {
		turn_num += 1
		src_number := last_spoken
		new_spoken := 0

		{
			entry, found := nums[src_number]
			if found {
				if entry.first {
					new_spoken = 0
				} else {
					new_spoken = entry.last_diff
				}
			}
		}

		// fmt.println(nums)
		// fmt.println(turn_num, src_number, new_spoken)

		{
			entry, found := &nums[new_spoken]
			if found {
				entry.last_diff = turn_num - entry.last_turn
				entry.last_turn = turn_num
				entry.first = false
			} else {
				nums[new_spoken] = Entry{-1, turn_num, true}
			}
		}

		if turn_num == 30000000 {
			fmt.println(new_spoken)
			break
		}

		last_spoken = new_spoken
	}
}