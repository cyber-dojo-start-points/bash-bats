
# Runs one fixture through the same services the red|amber|green lights run
# through: image_hiker hands the fixture's files to the runner together with
# the manifest, and the runner is what applies red_amber_green.rb. So a
# colour here is reached exactly as it is reached for a learner, and the
# harness-level outcomes, timed_out and faulty, can be seen as well.
#
# red_amber_green_test.sh starts those services and exports these, so the
# tests run inside it rather than on their own.

readonly helpers_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly repo_dir="${CYBER_DOJO_START_POINT_REPO_DIR}"
readonly network="${CYBER_DOJO_TRAFFIC_LIGHT_NETWORK}"
readonly image_hiker="${CYBER_DOJO_IMAGE_HIKER}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Runs the named fixture and records image_hiker's JSON, its stderr, and its
# exit status.
#
# The volume-mount is what lets image_hiker read the fixture's files, and it
# is mounted read-only at the path it already has, so a fixture is never
# written to and the path needs no translating.
run_fixture()
{
  local -r name="${1}"
  docker run \
    --env NO_PROMETHEUS=true \
    --env SRC_DIR="${repo_dir}" \
    --init \
    --network "${network}" \
    --read-only \
    --restart no \
    --rm \
    --tmpfs /tmp \
    --user nobody \
    --volume "${repo_dir}:${repo_dir}:ro" \
      "${image_hiker}" \
        --fixture "${repo_dir}/test/fixtures/${name}" > "${stdoutF}" 2> "${stderrF}"
  echo $? > "${statusF}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Echoes one value from image_hiker's JSON.
hiked()
{
  jq --raw-output "${1}" "${stdoutF}"
}

# Echoes everything cyber-dojo.sh printed, on stdout and on stderr both,
# which is what the rag-lambda reads.
hiked_output()
{
  hiked '.["cyber-dojo.sh"].stdout.content + .["cyber-dojo.sh"].stderr.content | join("")'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Fails unless the run reached the named outcome. Each fixture dir is named
# for the outcome it should reach, so the name and this argument agree.
#
# Three of the outcomes are the traffic-light colours. The other two,
# timed_out and faulty, are the runner saying the kata never got far enough
# for the lambda to have a view.
assert_outcome_is()
{
  local -r expected="${1}"
  local -r actual="$(hiked '.summary.colour')"
  assertEquals "outcome:$(dump_sss)" "${expected}" "${actual}"
}

# Fails unless exactly the given number of tests ran.
#
# bats speaks TAP, which opens with a plan line "1..N" naming how many tests
# it is about to run. Asserting on N is what distinguishes a test file that
# really ran from one that was gathered and silently skipped, so a case
# adding a test file checks the count rather than only the colour.
assert_tests_run()
{
  local -r expected="${1}"
  local -r actual="$(hiked_output | grep --count "^1\.\.${expected}$")"
  assertEquals "test-plan-1..${expected}:$(dump_sss)" 1 "${actual}"
}

# Fails unless the whole run printed a single TAP plan line.
#
# One plan line is the evidence that every test file ran in one process. N
# processes print N plans, and a lambda reading the first would miss a
# failure in a later file.
assert_one_test_plan()
{
  local -r actual="$(hiked_output | grep --count '^1\.\.')"
  assertEquals "test-plans:$(dump_sss)" 1 "${actual}"
}

# Fails unless the runner had to cut the output short.
#
# It keeps the first 50K and drops the rest, so a learner printing inside a
# loop loses the summary line that comes after it. What the lambda must not
# do is call that green.
assert_output_truncated()
{
  local -r actual="$(hiked '.["cyber-dojo.sh"].stdout.truncated')"
  assertEquals "stdout-truncated:$(dump_sss)" 'true' "${actual}"
}

# Fails if the output runs to more than the given number of lines.
#
# A learner who mistypes a name wants the file and the line it is on. A page
# of the framework's own stack frames scrolls that away, and every frame in
# it is inside machinery they did not write and cannot fix.
assert_output_at_most_lines()
{
  local -r expected="${1}"
  local -r actual="$(hiked '.["cyber-dojo.sh"].stdout.content + .["cyber-dojo.sh"].stderr.content | length')"
  if [ "${actual}" -gt "${expected}" ]; then
    dump_sss
    fail "expected at most ${expected} lines of output, got ${actual}"
  fi
}
