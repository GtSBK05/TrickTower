extends Node

var scroll := 0
var adik_dialogue_done := false

# Floor 1: 2 puzzle
var floor1_puzzles := [false, false] # [switch, plate]

func floor1_complete() -> bool:
	return floor1_puzzles[0] and floor1_puzzles[1]

func floor1_mark(idx: int) -> void:
	floor1_puzzles[idx] = true
