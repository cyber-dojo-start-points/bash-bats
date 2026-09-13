#!/bin/bash

# The learner put a print inside a loop to see what was happening, and it
# prints far more than the 50K the runner keeps.
for i in $(seq 1 5000); do
  echo "debug: answer was called, i is ${i}"
done

answer()
{
  echo $((6 * 7))
}
