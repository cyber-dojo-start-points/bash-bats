# Your tests live in .bats files. Every one of them runs, however deeply
# nested. A test file with any other extension is not a test file and will
# not run, so name new test files .bats
#
# Every .sh file is checked for syntax errors first, even one you have not
# sourced yet, so a file that will not parse cannot sit there unnoticed.

for file in $(find . -name '*.sh'); do
  bash -n "${file}" || exit 1
done

bats --recursive .
