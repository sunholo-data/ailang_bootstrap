# AILANG Challenge

Load and run an AILANG coding challenge.

## Challenge: $ARGUMENTS

---

## Available Challenges

If no challenge specified, list available challenges:

```bash
ls challenges/
```

Current challenges:
- `game-of-life` - Conway's Game of Life (Arrays, ADTs, Pattern Matching)
- More coming soon...

---

## Loading a Challenge

Read the challenge prompt from the library:

```bash
cat challenges/$ARGUMENTS/challenge.md
```

Then follow the instructions in the challenge.

---

## Rules

1. **Don't peek at the solution** - The solution is at `challenges/$ARGUMENTS/solution.ail` but try to solve it yourself first

2. **Use hints progressively** - If stuck, check `challenges/$ARGUMENTS/hints.md` one hint at a time

3. **The goal is learning** - These challenges teach AILANG features through building real programs

---

## After Completing

Run the reference solution to compare:

```bash
ailang run --relax-modules --caps IO,FS --entry main challenges/$ARGUMENTS/solution.ail
```

---

Now load the challenge for: **$ARGUMENTS**
