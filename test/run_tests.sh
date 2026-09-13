#!/usr/bin/env bash
set -Eeu

# Runs the shunit2 tests holding this start-point to the cases a learner
# reaches that the three traffic-lights cannot express: a second test file, a
# file half-written, a test that errors rather than fails, a kata that hangs.
# Each test runs one fixture dir through image_hiker and
# the runner, exactly as the red|amber|green lights are run, and checks the
# colour that comes back.
#
# red_amber_green_test.sh starts those services, and runs this once the
# three lights have been checked. There is nothing to run against until it
# does, so the env-vars it exports are required rather than defaulted.

readonly my_dir="$(cd "$(dirname "${0}")" && pwd)"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

show_use()
{
  local -r my_name="$(basename "${0}")"
  echo "Use: ${my_name} [-h]"
  echo ''
  echo '  Runs this start-point against the cases in test/fixtures/.'
  echo '  Run from red_amber_green_test.sh, which starts the services these'
  echo '  tests need and exports the env-vars naming them.'
  echo ''
  echo 'Example:'
  echo '  ./run_tests.sh'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_non_zero_unless_set()
{
  local name
  for name in "$@"; do
    if [ -z "${!name:-}" ]; then
      >&2 echo "ERROR: ${name} is not set"
      >&2 echo 'These tests run from red_amber_green_test.sh, which sets it.'
      exit 42
    fi
  done
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_non_zero_unless_installed()
{
  local name
  for name in "$@"; do
    if ! hash "${name}" 2> /dev/null; then
      >&2 echo "ERROR: ${name} is not installed"
      exit 42
    fi
  done
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Runs every test file, and reports a failure in any of them. They all run
# even when an earlier one fails, so one run shows the whole picture.
run_all_test_files()
{
  local test_file
  local failed=0
  echo
  for test_file in "${my_dir}"/test_*.sh; do
    bash "${test_file}" || failed=1
  done
  return "${failed}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "${1:-}" == '-h' ] || [ "${1:-}" == '--help' ]; then
  show_use
  exit 0
fi

exit_non_zero_unless_installed docker jq
exit_non_zero_unless_set \
  CYBER_DOJO_START_POINT_REPO_DIR \
  CYBER_DOJO_TRAFFIC_LIGHT_NETWORK \
  CYBER_DOJO_IMAGE_HIKER
run_all_test_files
