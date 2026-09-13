#!/usr/bin/env bash

# One fixture dir per case, under fixtures/, each holding only the source and
# test files a learner would have. cyber-dojo.sh is never one of them: it
# arrives from start_point/ unchanged, because a learner never edits it and
# it is the thing under test. Each fixture dir is named for the colour it
# should reach, so the expectation travels with the case.
#
# A case runs exactly as a kata runs, in the image manifest.json names, and
# the colour is whatever start_point/red_amber_green.rb makes of the output.
#
# Two kinds of fault show up here. A case that keeps the shipped file layout
# and varies only what the tests report indicts the rag-lambda. A case that
# adds, nests or misnames a file indicts cyber-dojo.sh, and the fault worth
# hunting there is a file the learner is midway through writing that gets
# silently ignored. Green while the kata holds code that will not parse is
# the worst answer a kata can give.

readonly my_dir="$(cd "$(dirname "${0}")" && pwd)"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# green

test_green_1_test()
{
  run_fixture green_1_test
  assert_outcome_is green
  assert_tests_run 1
}

# Wording that says "1 test" in one run and "3 tests" in the next breaks a
# regex written against either one alone.
test_green_3_tests()
{
  run_fixture green_3_tests
  assert_outcome_is green
  assert_tests_run 3
}

# Ordinary refactoring. The learner moves a function into its own file and
# sources it.
test_green_extra_source_file_sourced()
{
  run_fixture green_extra_source_file_sourced
  assert_outcome_is green
  assert_tests_run 1
}

# bats discovers its own tests, so a second .bats file needs no wiring in and
# its tests run as soon as it exists. Where a framework has no discovery the
# honest answer is green with the count unchanged, because those tests
# genuinely did not run. Here the count goes up.
test_green_extra_test_file_discovered()
{
  run_fixture green_extra_test_file_discovered
  assert_outcome_is green
  assert_tests_run 2
}

# Renaming is often the first thing a learner does, because they are here to
# do FizzBuzz rather than hiker. Everything should keep working: the tests
# are still found, they still run, and the light is still the right colour.
#
# bats discovers by extension and the source is found by the path the test
# file sources, so neither name is tied to anything. Where a language ties a
# name to a file, as Java ties a public class and Go a package, the case is
# expected to fail the way it would on the learner's own machine.
test_green_renamed_source_and_test_files()
{
  run_fixture green_renamed_source_and_test_files
  assert_outcome_is green
  assert_tests_run 1
}

# Debug printing the learner has not taken out yet, on stderr rather than
# stdout. A lambda reading only stdout would not notice here, and would
# elsewhere, so the case belongs in every start-point rather than in none.
test_green_debug_output_on_stderr()
{
  run_fixture green_debug_output_on_stderr
  assert_outcome_is green
  assert_tests_run 1
}

# A shallow glob finds a test file beside the source and misses one a
# directory down.
test_green_nested_test_file()
{
  run_fixture green_nested_test_file
  assert_outcome_is green
  assert_tests_run 2
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# red
#
# An assertion failure is red: a test ran, and disagreed with the code.

test_red_1_failure()
{
  run_fixture red_1_failure
  assert_outcome_is red
  assert_tests_run 1
}

test_red_3_failures()
{
  run_fixture red_3_failures
  assert_outcome_is red
  assert_tests_run 3
}

# The passing tests print their own "ok" lines before the failing one prints
# "not ok", so a lambda greening on the first "ok" it sees calls this green
# and hands the learner a light saying their broken code works.
test_red_1_of_3_failures()
{
  run_fixture red_1_of_3_failures
  assert_outcome_is red
  assert_tests_run 3
}

# The count going up is what proves the new file's tests really ran. A colour
# that stays red proves nothing, because the shipped test could be failing on
# its own.
test_red_extra_test_file_one_failing()
{
  run_fixture red_extra_test_file_one_failing
  assert_outcome_is red
  assert_tests_run 2
}

# One process prints one summary, already counting every file. N processes
# print N summaries, and a lambda written for one reads the first and misses
# a failure in a later file.
test_red_two_test_files_one_failure()
{
  run_fixture red_two_test_files_one_failure
  assert_outcome_is red
  assert_tests_run 4
  assert_one_test_plan
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# amber
#
# An error is amber: the run never got as far as finding out what the tests
# would have said.

test_amber_1_error()
{
  run_fixture amber_1_error
  assert_outcome_is amber
}

test_amber_2_errors()
{
  run_fixture amber_2_errors
  assert_outcome_is amber
}

# An error and an assertion failure in the same run. Amber wins, because a
# run holding an error has not established what the failing test would have
# said once the error was fixed.
test_amber_error_and_failure()
{
  run_fixture amber_error_and_failure
  assert_outcome_is amber
}

test_amber_syntax_error_in_source_file()
{
  run_fixture amber_syntax_error_in_source_file
  assert_outcome_is amber
}

test_amber_syntax_error_in_test_file()
{
  run_fixture amber_syntax_error_in_test_file
  assert_outcome_is amber
}

# The commonest typo there is.
test_amber_undefined_name()
{
  run_fixture amber_undefined_name
  assert_outcome_is amber
}

# A test file holding no tests at all. Nothing passed, so green would be a
# lie, and nothing failed, so red would be one too.
test_amber_no_tests()
{
  run_fixture amber_no_tests
  assert_outcome_is amber
}

# The broken file is sourced by nothing, so following what the kata loads
# never reaches it. cyber-dojo.sh parse-checks every .sh file it can find
# instead, which is what stops it sitting there unnoticed.
test_amber_extra_source_file_not_sourced_broken()
{
  run_fixture amber_extra_source_file_not_sourced_broken
  assert_outcome_is amber
}

# The silent-ignore fault. The learner's first test file still passes, so a
# run that skips the file it cannot parse reports green over a kata holding
# code that does not work.
test_amber_extra_test_file_does_not_parse()
{
  run_fixture amber_extra_test_file_does_not_parse
  assert_outcome_is amber
}

# A learner who mistypes a name wants the file and the line it is on, not a
# page of frames from machinery they did not write.
test_amber_typo_in_source_file()
{
  run_fixture amber_typo_in_source_file
  assert_outcome_is amber
  assert_output_at_most_lines 10
}

# The runner keeps the first 50K of the output and drops the rest, so a
# learner printing inside a loop loses the summary line that came after it.
# Amber is the honest answer: their tests may well have passed, and nothing
# that reached the lambda says so.
test_amber_output_truncated()
{
  run_fixture amber_output_truncated
  assert_outcome_is amber
  assert_output_truncated
}

# bats finds files ending .bats and nothing else, so a test file named .sh
# does not run. That is the honest answer and a fair thing for a learner to
# discover. What it must not do is vanish: cyber-dojo.sh parse-checks every
# .sh file, so the bats syntax in it fails bash -n and scores amber.
test_amber_test_file_misnamed_sh()
{
  run_fixture amber_test_file_misnamed_sh
  assert_outcome_is amber
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# timed_out
#
# Not a colour. The runner stops a kata that runs past max_seconds and says
# so, and the lambda never sees it.

# A loop whose condition the learner never moves. Amber would be wrong here:
# it would say something went wrong inside a run that finished, when what
# actually happened is that the run never finished at all, and no edit to
# the lambda could tell the two apart.
test_timed_out_infinite_loop()
{
  run_fixture timed_out_infinite_loop
  assert_outcome_is timed_out
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

echo "::${0##*/}"
. "${my_dir}/shunit2_helpers.sh"
. "${my_dir}/fixture_helpers.sh"
. "${my_dir}/shunit2"
