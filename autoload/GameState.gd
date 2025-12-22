extends Node

var scroll := 0
var adik_dialogue_done := false

# Floor 1: 2 puzzle
var floor1_puzzles := [false, false] # [switch, plate]
var floor1_done := false

func floor1_complete() -> bool:
	return floor1_puzzles[0] and floor1_puzzles[1]

func floor1_mark(idx: int) -> void:
	floor1_puzzles[idx] = true
	floor1_done = floor1_complete()

# Floor 2: 2 puzzle
var floor2_puzzles := [false, false] # [ButtonSequencePuzzle, PuzzleKedua]
var floor2_done := false

func floor2_complete() -> bool:
	return floor2_puzzles[0] and floor2_puzzles[1]

func floor2_mark(idx: int) -> void:
	floor2_puzzles[idx] = true
	floor2_done = floor2_complete()
