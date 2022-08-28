package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:sort"

Food :: struct {
	ingredients: [dynamic]string,
	allergens: [dynamic]string
}

main :: proc() {
	// file_bytes, file_success := os.read_entire_file_from_filename("../example.txt")
	file_bytes, file_success := os.read_entire_file_from_filename("../puzzle.txt")
	assert(file_success)

	foods: [dynamic]Food
	foods_by_allergens := make(map[string][dynamic]Food)
	allergen_candidates := make(map[string][dynamic]string)
	allergens := make(map[string]string)

	line_iter := string(file_bytes)
	for line in strings.split_lines_iterator(&line_iter) {
		// fmt.println(line)
		section_iter := line
		ingredients_list, _ := strings.split_iterator(&section_iter, " (contains ")

		food: Food

		for ingredient in strings.split_iterator(&ingredients_list, " ") {
			// fmt.println(ingredient)
			append(&food.ingredients, ingredient)
		}

		for allergen in strings.split_iterator(&section_iter, ", ") {
			parsed_allergen := allergen
			if allergen[len(allergen) - 1] == ')' {
				parsed_allergen = allergen[:len(allergen) - 1]
			}
			// fmt.println(parsed_allergen)

			append(&food.allergens, parsed_allergen)

			elem, ok := &foods_by_allergens[parsed_allergen]
			if !ok {
				foods_by_allergens[parsed_allergen] = {}
				elem = &foods_by_allergens[parsed_allergen]
			}

			append(elem, food)
			
		}

		append(&foods, food)
	}

	// fmt.println(foods)
	// fmt.println(foods_by_allergens)

	// Cross reference allergens
	for allergen, food_list in foods_by_allergens {
		// fmt.println(allergen)

		ingredient_counter := make(map[string]int)
		defer delete(ingredient_counter)

		// Find matching ingredients
		for food in food_list {
			for ingredient in food.ingredients {
				elem, ok := ingredient_counter[ingredient]
				if !ok {
					ingredient_counter[ingredient] = 0
				}

				ingredient_counter[ingredient] += 1
			}
		}

		// fmt.println(ingredient_counter)

		for ingredient, count in ingredient_counter {
			if count == len(food_list) {
				elem, ok := allergen_candidates[allergen] 
				if !ok {
					 allergen_candidates[allergen] = {}
				}

				append(&allergen_candidates[allergen], ingredient)
			}
		}
	}

	fmt.println(allergen_candidates)

	for len(allergens) < len(allergen_candidates) {
		// Update allergens
		for allergen, ingredient_list in allergen_candidates {
			if len(ingredient_list) == 1 {
				allergens[allergen] = ingredient_list[0]
			}
		}

		fmt.println("Updated allergens:", allergens)

		for allergen, ingredient_list in allergen_candidates {
			if len(ingredient_list) == 1 {
				continue
			}

			outer: for ingredient, ingredient_index in ingredient_list {
				for allergen_check, allergen_check_ingredient in allergens {
					if ingredient == allergen_check_ingredient {
						ordered_remove(&allergen_candidates[allergen], ingredient_index)
						break outer
					}
				} 
			}
		}
	}

	allergen_sorted_list := make([]string, len(allergens))
	defer delete(allergen_sorted_list)

	allergen_index := 0
	for allergen, index in allergens {
		allergen_sorted_list[allergen_index] = allergen
		allergen_index += 1
	}

	fmt.println(allergen_sorted_list)

	sort.bubble_sort(allergen_sorted_list)

	fmt.println(allergen_sorted_list)

	// Generate final output
	for allergen, index in allergen_sorted_list {
		fmt.printf("%s", allergens[allergen])

		if index == len(allergen_sorted_list) -1 {
			fmt.println()
		} else {
			fmt.printf(",")
		}
	}
}