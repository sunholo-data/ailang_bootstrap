# Hints for Game of Life Challenge

Use these progressively if you get stuck. Try to solve it yourself first!

---

## Hint 1: Cell Representation

Use an Algebraic Data Type (ADT):

```ailang
type Cell = Alive | Dead
```

This lets you use pattern matching later.

---

## Hint 2: Grid Storage

AILANG has 1D arrays. Map 2D → 1D with:

```ailang
pure func toIndex(x: int, y: int) -> int {
    y * gridSize() + x
}
```

For a 10x10 grid, cell (3, 2) is at index `2 * 10 + 3 = 23`.

---

## Hint 3: Counting Neighbors

Check all 8 directions around a cell:

```ailang
pure func countNeighbors(grid: Array[Cell], x: int, y: int) -> int {
    -- Sum up the 8 surrounding cells
    -- Handle bounds checking (out of bounds = Dead)
}
```

---

## Hint 4: Pure Computation

Make your generation step a pure function:

```ailang
pure func nextGeneration(grid: Array[Cell]) -> Array[Cell] {
    -- Create new grid
    -- For each cell, compute its next state based on neighbors
    -- Return the new grid
}
```

Pure functions have no side effects - they just transform data.

---

## Hint 5: Visualization Strategy

AILANG can write files. The breakthrough insight:

1. Compute N generations in AILANG
2. Serialize each generation to a string (e.g., "0101001...")
3. Write an HTML file with the pre-computed data embedded
4. HTML/JS just *displays* what AILANG already calculated

```ailang
import std/fs (writeFile)

export func main() -> () ! {IO, FS} {
    let frames = computeAllGenerations(...);
    let html = buildHTML(frames);
    writeFile("output.html", html)
}
```

---

## Hint 6: Serialization

Convert grid to a string:

```ailang
pure func cellToChar(cell: Cell) -> string {
    match cell { Alive => "1", Dead => "0" }
}
```

Then concatenate all cells into one string per generation.

---

## Still Stuck?

Check the solution at `challenges/game-of-life/solution.ail`

But try the hints first - you'll learn more by struggling a bit!
