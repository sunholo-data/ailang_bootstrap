# Challenge: Conway's Game of Life

Build Conway's Game of Life in AILANG with visual output.

## Difficulty: Intermediate
## Features: Arrays, ADTs, Pattern Matching, Pure Functions, File I/O

---

## The Rules

Conway's Game of Life is a cellular automaton on a 2D grid:

1. **Survival:** A live cell with 2-3 neighbors survives
2. **Death:** A live cell with <2 or >3 neighbors dies
3. **Birth:** A dead cell with exactly 3 neighbors becomes alive

## Your Goal

Create an AILANG program that:
- [ ] Represents a grid of cells
- [ ] Implements the Game of Life rules
- [ ] Computes multiple generations
- [ ] Produces visual output showing evolution

## Discovery Steps

### Step 1: Explore AILANG's Capabilities

```bash
# What's available?
ailang builtins list --verbose --by-module | head -80

# Check array operations
ailang builtins list --verbose --by-module | grep -A 50 "std/array"
```

Or view the stdlib on GitHub: https://github.com/sunholo-data/ailang/tree/main/std

### Step 2: Load the Syntax Reference

```
/ailang-prompt
```

### Step 3: Design Your Data Structures

Think about:
- How to represent a cell (alive vs dead)
- How to store a 2D grid using 1D arrays
- How to convert (x, y) coordinates to array index

### Step 4: Implement the Algorithm

Consider:
- Counting neighbors for each cell
- Applying Conway's rules
- Creating the next generation

### Step 5: Create Visual Output

AILANG can't render graphics directly. But it can:
- Print to console (`std/io`)
- Write files (`std/fs`)

**Key insight:** What if you computed all the data in AILANG, then output something that can be visualized?

## Interesting Patterns to Try

- **Blinker:** 3 cells in a row (oscillates)
- **Glider:** 5 cells that move diagonally
- **R-pentomino:** 5 cells that evolve chaotically

## Run Your Solution

```bash
ailang run --relax-modules --caps IO,FS --entry main examples/my_game_of_life.ail
```

## Success Criteria

Your solution demonstrates AILANG as a real programming language:
- Game logic runs in AILANG (not JavaScript or another language)
- Uses AILANG features: ADTs, pattern matching, pure functions, arrays
- Produces output you can watch evolve

---

Good luck! Start by exploring, then build incrementally.
