.PHONY: all lights-only matrix-only

# The three traffic-lights, then the case matrices in test/
all:
	./run_tests.sh

# The three traffic-lights only, and how long each took
lights-only:
	./run_tests.sh --lights-only

# The case matrices in test/ only, skipping the three traffic-lights
matrix-only:
	./run_tests.sh --matrix-only
